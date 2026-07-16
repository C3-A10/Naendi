//
//  Detail.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI
import MapKit

struct DetailPlaceView: View {
    let place: Place
    
    @State private var viewModel = DecideViewModel()
    @State private var isComparing: Bool = false
    @State private var selectedImageURL: URL? = nil
    
    var body: some View {
        VStack {
            // Card
            PlaceResultCardView(
                place: place,
                viewModel: viewModel,
                isComparing: $isComparing,
                selectedImageURL: $selectedImageURL
            )
            
            // Button
            CustomActionButton(
                text: "Go to Destination",
                backgroundColor: Color(red: 207/255, green: 245/255, blue: 64/255),
                textColor: .black,
                action: {
                    print("Location Selected!")
                }
            )
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    DetailPlaceView(place: Place.dummyData[1])
}
