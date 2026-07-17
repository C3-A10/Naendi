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

    var body: some View {
        VStack {
            Spacer()
            // Card
            PlaceResultCardView(
                place: place,
                isDetail: true,
                viewModel: viewModel,
                isComparing: $isComparing,
                selectedImageURL: $selectedImageURL
            )
            .frame(maxWidth: .infinity)

            // Button
            CustomActionButton(
                text: "Go to Destination",
                backgroundColor: Color(red: 207/255, green: 245/255, blue: 64/255),
                textColor: .black,
                action: {
                    print("Location Selected!")
                }
            )
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            Spacer()
        }
        .frame(alignment: .center)
        .navigationTitle(place.nama)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                }
            }
        }
    }
}

#Preview {
    DetailPlaceView(place: Place.dummyData[1])
}
