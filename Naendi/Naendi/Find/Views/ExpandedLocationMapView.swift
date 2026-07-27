import MapKit
import SwiftUI

struct ExpandedLocationMapView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var cameraPosition: MapCameraPosition
    @Binding var selectedLocationName: String
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var searchState: LocationSearchState

    var radius: Double
    var submittedSearchQuery: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LocationMapView(
                cameraPosition: $cameraPosition,
                selectedLocationName: $selectedLocationName,
                selectedCoordinate: $selectedCoordinate,
                searchState: $searchState,
                radius: radius,
                submittedSearchQuery: submittedSearchQuery
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
