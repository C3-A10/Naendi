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

                PreferenceSearchField(query: $query, placeholder: "Search location")
                    .onSubmit(submitSearch)
                    .padding(20)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        CircleIconButton(
                            systemName: "arrow.up.left.and.arrow.down.right",
                            accessibilityLabel: "Expand map",
                            size: 48
                        ) { isMapExpanded = true }
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
        .background(Color(uiColor: .systemBackground))
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
            CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Back") {
                dismiss()
            }

            Spacer()

            Text("Select your Location")
                .font(.headline)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            CircleIconButton(systemName: "checkmark", accessibilityLabel: "Confirm location") {
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
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        submittedSearchQuery = ""
        Task { @MainActor in
            submittedSearchQuery = trimmedQuery
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
            "Location Not Found"
        case .failure:
            "Unable to Search"
        case .idle, .searching, .success:
            ""
        }
    }

    private var searchAlertMessage: String {
        switch searchState {
        case .emptyResult:
            "Try a different city, place, or address."
        case .failure(let message):
            message
        case .idle, .searching, .success:
            ""
        }
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
                size: 48
            ) { dismiss() }
            .padding(.top, 12)
            .padding(.trailing, 20)
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
