import MapKit
import SwiftUI

enum LocationSearchState: Equatable {
    case idle
    case searching
    case success
    case emptyResult
    case failure(String)
}

struct LocationMapView: View {
    @Binding var cameraPosition: MapCameraPosition
    @Binding var selectedLocationName: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var radius: Double
    @Binding var submittedSearchQuery: String
    @Binding var showsUserLocation: Bool
    @Binding var searchState: LocationSearchState

    @State private var reverseGeocodingTask: Task<Void, Never>?

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
            .onMapCameraChange(frequency: .continuous) { context in
                selectedCoordinate = context.camera.centerCoordinate
                if cameraPosition.positionedByUser {
                    selectedLocationName = "Pinned Location"
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                guard cameraPosition.positionedByUser else { return }

                reverseGeocodingTask?.cancel()
                let coordinate = context.camera.centerCoordinate
                reverseGeocodingTask = Task {
                    await updateSelectedLocationName(for: coordinate)
                }
            }
            .task(id: submittedSearchQuery) {
                await searchSubmittedLocationIfNeeded()
            }
            .onDisappear {
                reverseGeocodingTask?.cancel()
            }
            .animation(.smooth(duration: 0.2), value: radius)
            .accessibilityHidden(true)

            centerPin
                .allowsHitTesting(false)
        }
    }

    private var centerPin: some View {
        Image(systemName: "mappin.circle.fill")
            .font(.system(size: 38, weight: .bold))
            .symbolRenderingMode(.palette)
            .foregroundStyle(.white, Color.red)
            .shadow(color: .black.opacity(0.22), radius: 4, y: 2)
            .offset(y: -19)
            .accessibilityElement()
            .accessibilityLabel("Selected location")
            .accessibilityValue(selectedLocationName)
            .accessibilityHint("Use the search field to adjust the location.")
    }

    @MainActor
    private func searchSubmittedLocationIfNeeded() async {
        let query = submittedSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            searchState = .idle
            return
        }

        searchState = .searching

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .pointOfInterest]

        do {
            let response = try await MKLocalSearch(request: request).start()

            guard let mapItem = response.mapItems.first else {
                searchState = .emptyResult
                return
            }

            let coordinate = mapItem.location.coordinate
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
            )

            selectedLocationName = mapItem.name ?? query
            selectedCoordinate = coordinate

            withAnimation(.smooth(duration: 0.45)) {
                cameraPosition = .region(region)
            }
            searchState = .success
        } catch is CancellationError {
            return
        } catch {
            searchState = .failure(error.localizedDescription)
        }
    }

    @MainActor
    private func updateSelectedLocationName(for coordinate: CLLocationCoordinate2D) async {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        guard let request = MKReverseGeocodingRequest(location: location) else {
            selectedLocationName = "Pinned Location"
            return
        }

        do {
            let mapItems = try await request.mapItems
            try Task.checkCancellation()

            guard let mapItem = mapItems.first else {
                selectedLocationName = "Pinned Location"
                return
            }

            selectedLocationName = mapItem.name
                ?? mapItem.address?.shortAddress
                ?? mapItem.address?.fullAddress
                ?? "Pinned Location"
        } catch is CancellationError {
            return
        } catch {
            selectedLocationName = "Pinned Location"
        }
    }
}

#Preview {
    @Previewable @State var cameraPosition: MapCameraPosition = .automatic
    @Previewable @State var selectedLocationName = "Search Location"
    @Previewable @State var selectedCoordinate = CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787)
    @Previewable @State var radius = 1.0
    @Previewable @State var submittedSearchQuery = ""
    @Previewable @State var showsUserLocation = true
    @Previewable @State var searchState = LocationSearchState.idle

    LocationMapView(
        cameraPosition: $cameraPosition,
        selectedLocationName: $selectedLocationName,
        selectedCoordinate: $selectedCoordinate,
        radius: $radius,
        submittedSearchQuery: $submittedSearchQuery,
        showsUserLocation: $showsUserLocation,
        searchState: $searchState
    )
}
