import MapKit
import SwiftUI

/// "Take the map to me". Shared by the inline and expanded map so the location
/// permission check only exists once.
struct RecenterButton: View {
    @Binding var cameraPosition: MapCameraPosition

    @State private var permission = LocationPermission()
    @State private var isShowingLocationDeniedAlert = false

    var body: some View {
        CircleIconButton(
            systemName: "location.fill",
            accessibilityLabel: "Go to current location",
            backgroundColor: Color(.systemBackground),
            size: 48
        ) {
            guard permission.requestIfNeeded() else {
                isShowingLocationDeniedAlert = true
                return
            }

            withAnimation(.smooth(duration: 0.45)) {
                cameraPosition = .userLocation(fallback: .automatic)
            }
        }
        .locationDeniedAlert(isPresented: $isShowingLocationDeniedAlert)
    }
}
