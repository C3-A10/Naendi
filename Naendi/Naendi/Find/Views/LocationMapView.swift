import MapKit
import SwiftUI

struct LocationMapView: View {
    @Binding var cameraPosition: MapCameraPosition
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var radius: Double
    @Binding var submittedSearchQuery: String
    @Binding var showsUserLocation: Bool

    var interactionModes: MapInteractionModes = .all

    var body: some View {
        ZStack {
            Map(
                position: $cameraPosition,
                interactionModes: interactionModes
            ) {
                MapCircle(center: selectedCoordinate, radius: radius * 1_000)
                    .foregroundStyle(.blue.opacity(0.2))
                    .stroke(.blue, lineWidth: 3)

                if showsUserLocation {
                    UserAnnotation()
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                selectedCoordinate = context.camera.centerCoordinate
            }
            .task(id: submittedSearchQuery) {
                await searchSubmittedLocationIfNeeded()
            }
            .animation(.smooth(duration: 0.2), value: radius)
            .animation(.smooth(duration: 0.2), value: selectedCoordinate.latitude)
            .animation(.smooth(duration: 0.2), value: selectedCoordinate.longitude)

            centerPin
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private var centerPin: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.system(size: 38, weight: .bold))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, Color.red)
            .shadow(color: .black.opacity(0.22), radius: 4, y: 2)
            .offset(y: -19)
    }

    @MainActor
    private func searchSubmittedLocationIfNeeded() async {
        let query = submittedSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]

        do {
            let response = try await MKLocalSearch(request: request).start()

            guard let mapItem = response.mapItems.first else {
                return
            }

            let coordinate = mapItem.location.coordinate
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
            )

            selectedCoordinate = coordinate

            withAnimation(.smooth(duration: 0.45)) {
                cameraPosition = .region(region)
            }
        } catch {
            return
        }
    }
}

#Preview {
    @Previewable @State var cameraPosition: MapCameraPosition = .automatic
    @Previewable @State var selectedCoordinate = CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787)
    @Previewable @State var radius = 1.0
    @Previewable @State var submittedSearchQuery = ""
    @Previewable @State var showsUserLocation = true

    LocationMapView(
        cameraPosition: $cameraPosition,
        selectedCoordinate: $selectedCoordinate,
        radius: $radius,
        submittedSearchQuery: $submittedSearchQuery,
        showsUserLocation: $showsUserLocation
    )
}
