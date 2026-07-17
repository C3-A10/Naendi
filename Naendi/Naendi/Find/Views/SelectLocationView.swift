import MapKit
import SwiftUI

struct SelectLocationView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var radius: Double

    @State private var query = ""
    @State private var submittedSearchQuery = ""
    @State private var cameraPosition: MapCameraPosition
    @State private var showsUserLocation = true
    @State private var isMapExpanded = false

    init(selectedCoordinate: Binding<CLLocationCoordinate2D>, radius: Binding<Double>) {
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
                    selectedCoordinate: $selectedCoordinate,
                    radius: $radius,
                    submittedSearchQuery: $submittedSearchQuery,
                    showsUserLocation: $showsUserLocation
                )
                .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))

                PreferenceSearchField(query: $query, placeholder: "Search")
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
                selectedCoordinate: $selectedCoordinate,
                radius: $radius,
                submittedSearchQuery: $submittedSearchQuery,
                showsUserLocation: $showsUserLocation
            )
        }
    }

    private var header: some View {
        HStack {
            CircleIconButton(systemName: "chevron.left", accessibilityLabel: "Back") {
                dismiss()
            }

            Spacer()

            Text("Select your Location")
                .font(.system(size: 22, weight: .bold))

            Spacer()

            CircleIconButton(systemName: "checkmark", accessibilityLabel: "Confirm location") {
                dismiss()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private var radiusControl: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Custom local radius (km)")
                .font(.system(size: 16))

            RadiusSlider(value: $radius, range: 0.5...10, step: 0.5)
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
}

private struct ExpandedLocationMapView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var cameraPosition: MapCameraPosition
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var radius: Double
    @Binding var submittedSearchQuery: String
    @Binding var showsUserLocation: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LocationMapView(
                cameraPosition: $cameraPosition,
                selectedCoordinate: $selectedCoordinate,
                radius: $radius,
                submittedSearchQuery: $submittedSearchQuery,
                showsUserLocation: $showsUserLocation
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
    @Previewable @State var coordinate = CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787)
    @Previewable @State var radius = 1.0

    SelectLocationView(selectedCoordinate: $coordinate, radius: $radius)
}
