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
    let isChooseThisLocationBtnVisible: Bool
    @State private var isExpanded: Bool = false
    @State var viewModel: DecideViewModel
    
    @Binding var isComparing: Bool
    @Binding var selectedImageURL: URL?
    @Binding var selectedPlace: Place?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if isExpanded {
                    PlaceCardExpandView(place: place, isChooseThisLocationBtnVisible: isChooseThisLocationBtnVisible, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel, selectedImageURL: $selectedImageURL, selectedPlace: $selectedPlace)
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
                mode: .result, isChooseThisLocationBtnVisible: true,
                viewModel: DecideViewModel(), isComparing: .constant(true),
                selectedImageURL: .constant(nil), selectedPlace: .constant(Place.dummyData[0])
            )
            .padding(.vertical)
        }
    }
}
