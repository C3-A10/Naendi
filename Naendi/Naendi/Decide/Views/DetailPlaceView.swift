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
        // GPS / out-of-radius alert overlay
        .overlay {
            if showGPSAlert {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    AlertView(
                        title: "Make sure you're at the location and that GPS is enabled.",
                        message: "Report can only be submitted on-site to keep information accurate.",
                        buttonTitle: "I Understand",
                        action: {
                            showGPSAlert = false
                        }
                    )
                    .padding(.horizontal, 24)
                }
            }
        }
        // Confirmation alert when user IS within radius
        .alert("Report this place?", isPresented: $showReportConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Report", role: .destructive) {
                // TODO: implement the report action
            }
        } message: {
            Text("Are you sure you want to report \(place.nama)? This helps keep location information accurate.")
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
