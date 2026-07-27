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
                map
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                searchField
                    .padding(20)

                mapControls
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
                searchState: $searchState,
                radius: radius,
                submittedSearchQuery: submittedSearchQuery
            )
        }
        .alert(searchState.alertTitle, isPresented: isShowingSearchAlert) {
            Button("OK", role: .cancel) {
                searchState = .idle
            }
        } message: {
            Text(searchState.alertMessage)
        }
    }

    private var map: some View {
        LocationMapView(
            cameraPosition: $cameraPosition,
            selectedLocationName: $selectedLocationName,
            selectedCoordinate: $selectedCoordinate,
            searchState: $searchState,
            radius: radius,
            submittedSearchQuery: submittedSearchQuery
        )
    }

    private var searchField: some View {
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
        .onSubmit {
            suggestionProvider.clear()
            search(for: query)
        }
        .onChange(of: query) { _, newValue in
            suggestionProvider.update(query: newValue)
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

    private var mapControls: some View {
        VStack(spacing: 12) {
            RecenterButton(cameraPosition: $cameraPosition)

            CircleIconButton(
                systemName: "arrow.up.left.and.arrow.down.right",
                accessibilityLabel: "Expand map",
                backgroundColor: Color(.systemBackground),
                size: 48
            ) { isMapExpanded = true }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }

    private var radiusControl: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Custom local radius (km)")
                .font(.body)

            RadiusSlider(value: $radius, range: 0.25...10, step: 0.25)
        }
    }

    private func search(for text: String) {
        let trimmedQuery = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        submittedSearchQuery = ""
        Task { @MainActor in
            submittedSearchQuery = trimmedQuery
        }
    }

    private func confirmLocation() {
        if let camera = cameraPosition.camera {
            selectedCoordinate = camera.centerCoordinate
        } else if let region = cameraPosition.region {
            selectedCoordinate = region.center
        }
        dismiss()
    }

    private var isShowingSearchAlert: Binding<Bool> {
        Binding(
            get: { searchState.isAlerting },
            set: { isPresented in
                if !isPresented {
                    searchState = .idle
                }
            }
        )
    }
}

#Preview {
    @Previewable @State var locationName = "Search Location"
    @Previewable @State var coordinate = MKCoordinateRegion.surabaya.center
    @Previewable @State var radius = 1.0

    SelectLocationView(
        selectedLocationName: $locationName,
        selectedCoordinate: $coordinate,
        radius: $radius
    )
}
