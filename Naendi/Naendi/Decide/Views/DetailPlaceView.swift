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

    var body: some View {
        VStack {
            Spacer()
            // Card
            
            PlaceCardView(place: place, mode: .landing, isChooseThisLocationBtnVisible: false, viewModel: viewModel, isComparing: $isComparing, selectedImageURL: $selectedImageURL, selectedPlace: $dummySelectedPlace)
            
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
        .frame(alignment: .center)
        .navigationTitle(place.nama)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 16)
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
    }

}

#Preview {
    DetailPlaceView(place: Place.dummyData[1])
}
