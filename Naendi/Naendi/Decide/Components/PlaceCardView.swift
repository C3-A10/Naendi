//
//  PlaceCardView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 13/07/26.
//

//
//  PlaceCardView.swift
//

import SwiftUI

struct PlaceCardView: View {
    let place: Place
    let mode: PlaceCardMode
    @State private var isExpanded: Bool = false
    @State var viewModel: DecideViewModel
    
    @Binding var isComparing: Bool
    @Binding var selectedImageURL: URL?
    @Binding var selectedPlace: Place?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isExpanded {
                    PlaceCardExpandView(place: place, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel, selectedImageURL: $selectedImageURL)
                } else {
                    PlaceCardNormalView(place: place, mode: mode, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isComparing {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.toggleSelection(for: place)
                    }
                } else {
                    selectedPlace = place
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6)
            .ignoresSafeArea()
        
        ScrollView {
            PlaceCardView(
                place: Place.dummyData[0],
                mode: .result,
                viewModel: DecideViewModel(), isComparing: .constant(true),
                selectedImageURL: .constant(nil), selectedPlace: .constant(Place.dummyData[0])
            )
            .padding(.vertical)
        }
    }
}
