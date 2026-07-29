//
//  Detail.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI

struct DetailPlaceView: View {
    let place: Place

    @Environment(\.dismiss) private var dismiss
    let viewModel: DecideViewModel
    @State private var isComparing: Bool = false
    @State private var selectedImageURL: URL? = nil
    @State private var dummySelectedPlace: Place? = nil

    // Report flow state
    @State private var showGPSAlert: Bool = false
    @State private var showReportConfirm: Bool = false
    @State private var isReported: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            ZStack {
                Text(place.nama)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 48) // Memberi jarak aman agar tidak menabrak tombol xmark & tetap di tengah

                HStack {
                    Spacer()

                    CircleIconButton(
                        systemName: "xmark",
                        accessibilityLabel: "Close",
                        backgroundColor: Color(.systemBackground)
                    ) {
                        withAnimation(.spring()) {
                            dismiss()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .frame(maxWidth: .infinity)

            // Main Content
            GeometryReader { geo in
                ScrollView {
                    VStack {
                        Spacer()

                        // Card
                        PlaceCardView(
                            place: place,
                            mode: .landing,
                            isChooseThisLocationBtnVisible: false,
                            isTagVisible: false,
                            isReportVisible: true,
                            isDetail: true,
                            isReported: isReported,
                            onReport: handleReportTapped,
                            viewModel: viewModel,
                            isComparing: $isComparing,
                            onSelectImageIndex: { index in },
                            selectedPlace: $dummySelectedPlace
                        )
                        .frame(maxWidth: .infinity)

                        // Button
                        CustomActionButton(
                            text: "Go to Destination",
                            backgroundColor: Color("color_green"),
                            textColor: .black,
                            action: {
                                viewModel.openRoute(to: place)
                            }
                        )
                        .padding(.vertical, 20)

                        Spacer()
                    }
                    .frame(minHeight: geo.size.height, alignment: .center)
                    .padding(.horizontal, 16)
                }
                .accessibilityLabel("Close place details")
                .accessibilityInputLabels(["Close", "Close place details"])
            }
        }
        .background {
            GreenBlurBackground()
        }
        // GPS / out-of-radius alert
        .alert("Location Required!", isPresented: $showGPSAlert) {
            Button("I Understand", role: .cancel) { }
        } message: {
            if viewModel.userLocation != nil {
                Text("To report this place, your distance must be under 250m. You are currently \(viewModel.calculateDistanceFromMe(to: place)) away.")
            } else {
                Text("To report this place, your distance must be under 250m. Please enable your Location.")
            }
        }
        // Confirmation alert when user IS within radius
        .alert("Report This Place?", isPresented: $showReportConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Report", role: .destructive) {
                Task {
                    let didReport = await viewModel.reportPlace(place)
                    if didReport {
                        isReported = true
                    }
                }
            }
        } message: {
            Text("Are you sure want to report \(place.nama)? Once submitted, this report can't be changed.")
        }
        // Start GPS so isWithinReportRadius has a fix to compare against, and
        // seed the report icon from CloudKit — this @State resets every time the
        // sheet is presented, so it has to be read back rather than remembered.
        .task {
            viewModel.startLocationUpdates()
            isReported = await viewModel.hasReported(place)
        }
        // Report outcome (success / already reported / failure).
        .alert(
            viewModel.reportMessage?.contains("already submitted") == true
                ? "You've Already Reported"
                : "Report Submitted",
            isPresented: Binding(
                get: { viewModel.reportMessage != nil },
                set: { if !$0 { viewModel.reportMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.reportMessage ?? "")
        }
    }

    // MARK: - Report handling

    private func handleReportTapped() {
        if viewModel.isWithinReportRadius(of: place) {
            showReportConfirm = true
        } else {
            showGPSAlert = true
        }
    }
}

#Preview {
    DetailPlaceView(
        place: Place.dummyData[1],
        viewModel: DecideViewModel()
    )
}
