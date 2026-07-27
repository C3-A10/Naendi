import MapKit
import SwiftUI

struct SelectLocationView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedLocationName: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var radius: Double

    @State private var query = ""
    @State private var submittedSearchQuery = ""
    @State private var cameraPosition: MapCameraPosition
    @State private var showsUserLocation = true
    @State private var isMapExpanded = false
    @State private var searchState = LocationSearchState.idle
    @State private var suggestionProvider = LocationSuggestionProvider()

    init(
        selectedLocationName: Binding<String>,
        selectedCoordinate: Binding<CLLocationCoordinate2D>,
        radius: Binding<Double>
    ) {
        _selectedLocationName = selectedLocationName
        _selectedCoordinate = selectedCoordinate
        _radius = radius
        _cameraPosition = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: selectedCoordinate.wrappedValue,
                    span: MKCoordinateSpan(latitudeDelta: 0.026, longitudeDelta: 0.026)
                )
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ZStack(alignment: .top) {
                LocationMapView(
                    cameraPosition: $cameraPosition,
                    selectedLocationName: $selectedLocationName,
                    selectedCoordinate: $selectedCoordinate,
                    radius: $radius,
                    submittedSearchQuery: $submittedSearchQuery,
                    showsUserLocation: $showsUserLocation,
                    searchState: $searchState
                )
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                PreferenceSearchField(
                    query: $query,
                    placeholder: "Search location",
                    suggestions: suggestionProvider.suggestions
                ) { suggestion in
                    query = suggestion.title
                    suggestionProvider.clear()
                    search(for: [suggestion.title, suggestion.subtitle]
                        .filter { !$0.isEmpty }
                        .joined(separator: ", "))
                }
                .onSubmit(submitSearch)
                .onChange(of: query) { _, newValue in
                    suggestionProvider.update(query: newValue)
                }
                .padding(20)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            CircleIconButton(
                                systemName: "location.fill",
                                accessibilityLabel: "Go to current location",
                                backgroundColor: Color(.systemBackground),
                                size: 48
                            ) { recenterOnUser() }

                            CircleIconButton(
                                systemName: "arrow.up.left.and.arrow.down.right",
                                accessibilityLabel: "Expand map",
                                backgroundColor: Color(.systemBackground),
                                size: 48
                            ) { isMapExpanded = true }
                        }
                    }
                }
                .padding(18)
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 20)

            radiusControl
                .padding(.horizontal, 44)
                .padding(.top, 28)
                .padding(.bottom, 36)
        }
        .background {
            GreenBlurBackground()
        }
        .fullScreenCover(isPresented: $isMapExpanded) {
            ExpandedLocationMapView(
                cameraPosition: $cameraPosition,
                selectedLocationName: $selectedLocationName,
                selectedCoordinate: $selectedCoordinate,
                radius: $radius,
                submittedSearchQuery: $submittedSearchQuery,
                showsUserLocation: $showsUserLocation,
                searchState: $searchState
            )
        }
        .alert(searchAlertTitle, isPresented: isShowingSearchAlert) {
            Button("OK", role: .cancel) {
                searchState = .idle
            }
        } message: {
            Text(searchAlertMessage)
        }
    }

    private var header: some View {
        HStack {
            CircleIconButton(
                systemName: "chevron.left",
                accessibilityLabel: "Back",
                backgroundColor: Color(.systemBackground)
            ) {
                dismiss()
            }

            Spacer()

            Text("Select your Location")
                .font(.headline)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            CircleIconButton(
                systemName: "checkmark",
                accessibilityLabel: "Confirm location",
                backgroundColor: Color(.systemBackground)
            ) {
                confirmLocation()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private var radiusControl: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Custom local radius (km)")
                .font(.body)

            RadiusSlider(value: $radius, range: 0.25...10, step: 0.25)
        }
    }

    private func submitSearch() {
        suggestionProvider.clear()
        search(for: query)
    }

    private func search(for text: String) {
        let trimmedQuery = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        submittedSearchQuery = ""
        Task { @MainActor in
            submittedSearchQuery = trimmedQuery
        }
    }

    private func recenterOnUser() {
        withAnimation(.smooth(duration: 0.45)) {
            cameraPosition = .userLocation(fallback: .automatic)
        }
    }

    private func confirmLocation() {
        if let centerCoordinate = currentCameraCenter {
            selectedCoordinate = centerCoordinate
        }
        dismiss()
    }

    private var currentCameraCenter: CLLocationCoordinate2D? {
        if let camera = cameraPosition.camera {
            return camera.centerCoordinate
        }
        if let region = cameraPosition.region {
            return region.center
        }
        return nil
    }

    private var isShowingSearchAlert: Binding<Bool> {
        Binding(
            get: {
                switch searchState {
                case .emptyResult, .failure:
                    true
                case .idle, .searching, .success:
                    false
                }
            },
            set: { isPresented in
                if !isPresented {
                    searchState = .idle
                }
            }
        )
    }

    private var searchAlertTitle: String {
        switch searchState {
        case .emptyResult:
            String(localized: "Location Not Found")
        case .failure:
            String(localized: "Unable to Search")
        case .idle, .searching, .success:
            ""
        }
    }

    private var searchAlertMessage: String {
        switch searchState {
        case .emptyResult:
            String(localized: "Try a different city, place, or address.")
        case .failure(let message):
            message
        case .idle, .searching, .success:
            ""
        }
    }
}

@MainActor
@Observable
final class LocationSuggestionProvider: NSObject, MKLocalSearchCompleterDelegate {
    private(set) var suggestions: [SearchSuggestion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    func update(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmedQuery.count >= 2 else {
            clear()
            return
        }

        completer.queryFragment = trimmedQuery
    }

    func clear() {
        completer.cancel()
        suggestions = []
    }

    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results.prefix(5).map {
            SearchSuggestion(title: $0.title, subtitle: $0.subtitle)
        }
        MainActor.assumeIsolated { suggestions = results }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        MainActor.assumeIsolated { suggestions = [] }
    }
}

private struct ExpandedLocationMapView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var cameraPosition: MapCameraPosition
    @Binding var selectedLocationName: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var radius: Double
    @Binding var submittedSearchQuery: String
    @Binding var showsUserLocation: Bool
    @Binding var searchState: LocationSearchState

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LocationMapView(
                cameraPosition: $cameraPosition,
                selectedLocationName: $selectedLocationName,
                selectedCoordinate: $selectedCoordinate,
                radius: $radius,
                submittedSearchQuery: $submittedSearchQuery,
                showsUserLocation: $showsUserLocation,
                searchState: $searchState
            )
            .ignoresSafeArea()

            CircleIconButton(
                systemName: "arrow.down.right.and.arrow.up.left",
                accessibilityLabel: "Collapse map",
                backgroundColor: Color(.systemBackground),
                size: 48
            ) { dismiss() }
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .overlay(alignment: .bottomTrailing) {
            CircleIconButton(
                systemName: "location.fill",
                accessibilityLabel: "Go to current location",
                backgroundColor: Color(.systemBackground),
                size: 48
            ) {
                withAnimation(.smooth(duration: 0.45)) {
                    cameraPosition = .userLocation(fallback: .automatic)
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    @Previewable @State var locationName = "Search Location"
    @Previewable @State var coordinate = CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787)
    @Previewable @State var radius = 1.0

    SelectLocationView(
        selectedLocationName: $locationName,
        selectedCoordinate: $coordinate,
        radius: $radius
    )
}
