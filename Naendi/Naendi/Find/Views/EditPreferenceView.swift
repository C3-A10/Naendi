import MapKit
import SwiftUI

struct EditPreferenceView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var submittedSearchQuery = ""
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787),
            span: MKCoordinateSpan(latitudeDelta: 0.026, longitudeDelta: 0.026)
        )
    )
    @State private var selectedCoordinate = CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787)
    @State private var showsUserLocation = true
    @State private var radius = 1.0
    @State private var isPreferenceSheetPresented = true
    @State private var selectedDetent = PresentationDetent.medium

    private let collapsedDetent = PresentationDetent.fraction(0.25)
    private let expandedDetent = PresentationDetent.fraction(0.92)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                navigationHeader
                mapLayer
            }
            .background(Color(uiColor: .systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isPreferenceSheetPresented) {
                PreferenceBottomSheet(
                    query: $query,
                    radius: $radius,
                    onSubmitSearch: submitSearch
                )
                .presentationDetents(
                    [collapsedDetent, .medium, expandedDetent],
                    selection: $selectedDetent
                )
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(34)
                .presentationBackground(Color(uiColor: .systemBackground))
                .presentationBackgroundInteraction(.enabled(upThrough: collapsedDetent))
                .presentationContentInteraction(.scrolls)
                .interactiveDismissDisabled()
            }
            .onChange(of: isPreferenceSheetPresented) { _, isPresented in
                if !isPresented {
                    isPreferenceSheetPresented = true
                }
            }
        }
    }

    private var mapLayer: some View {
        LocationMapView(
            cameraPosition: $cameraPosition,
            selectedCoordinate: $selectedCoordinate,
            radius: $radius,
            submittedSearchQuery: $submittedSearchQuery,
            showsUserLocation: $showsUserLocation
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var navigationHeader: some View {
        HStack(spacing: 12) {
            CircleIconButton(
                systemName: "chevron.left",
                accessibilityLabel: "Back",
                size: 44
            ) { dismiss() }

            Spacer(minLength: 0)

            Text("Edit Preference")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .layoutPriority(1)

            Spacer(minLength: 0)

            CircleIconButton(
                systemName: "checkmark",
                accessibilityLabel: "Save",
                foregroundColor: .black,
                backgroundColor: Color("color_green"),
                size: 44
            ) { }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 22)
        .background(Color(uiColor: .systemBackground))
    }

    private func submitSearch() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedQuery.isEmpty else {
            return
        }

        submittedSearchQuery = ""

        Task { @MainActor in
            submittedSearchQuery = trimmedQuery
        }
    }
}

#Preview {
    EditPreferenceView()
}
