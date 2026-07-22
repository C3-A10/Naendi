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
    @State private var viewModel = DecideViewModel()
    @State private var isComparing: Bool = false
    @State private var selectedImageURL: URL? = nil
    @State private var dummySelectedPlace: Place? = nil

    // Report flow state
    @State private var showGPSAlert: Bool = false
    @State private var showReportConfirm: Bool = false
    @State private var isReported: Bool = false

    var body: some View {
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
                        selectedImageURL: $selectedImageURL,
                        selectedPlace: $dummySelectedPlace
                    )
                    .frame(maxWidth: .infinity)

                    // Button
                    CustomActionButton(
                        text: "Go to Destination",
                        backgroundColor: Color(red: 207/255, green: 245/255, blue: 64/255),
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
        }
        .navigationTitle(place.nama)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                    Text("Compare")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                }
            }
        }
        .background {
            GreenBlurBackground()
        }
        // GPS / out-of-radius alert
        .alert("Pastikan kamu berada di lokasi!", isPresented: $showGPSAlert) {
            Button("Aku mengerti", role: .cancel) { }
        } message: {
            Text("Pelaporan hanya dapat diberikan di lokasi agar menjaga keakuratan informasi.")
        }
        // Confirmation alert when user IS within radius
        .alert("Laporkan Tempat Ini?", isPresented: $showReportConfirm) {
            Button("Batal", role: .cancel) { }
            Button("Laporkan", role: .destructive) {
                Task {
                    let didReport = await viewModel.reportPlace(place)
                    if didReport {
                        isReported = true
                    }
                }
            }
        } message: {
            Text("Apakah anda yakin ingin melaporkan \(place.nama)? Data ini tidak dapat diubah lagi.")
        }
        // Start GPS so isWithinReportRadius has a fix to compare against.
        .task { viewModel.startLocationUpdates() }
        // Report outcome (success / already reported / failure).
        .alert(
            "Laporan",
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

    // MARK: – Report handling

    private func handleReportTapped() {
        if viewModel.isWithinReportRadius(of: place) {
            showReportConfirm = true
        } else {
            showGPSAlert = true
        }
    }

}


#Preview {
    DetailPlaceView(place: Place.dummyData[1])
}
