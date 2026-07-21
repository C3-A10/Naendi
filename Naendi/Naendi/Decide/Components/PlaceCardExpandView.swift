//
//  PlaceCardExpandView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 13/07/26.
//

import SwiftUI
import Combine

struct PlaceCardExpandView: View {
    
    let place: Place
    let isChooseThisLocationBtnVisible: Bool
    @Binding var isExpanded: Bool
    @Binding var isComparing: Bool
    @State var viewModel: DecideViewModel
    @Binding var selectedImageURL: URL?
    @Binding var selectedPlace: Place?
    
    // Helper status
    private var isSelected: Bool { viewModel.isSelected(place) }
    private var isCheckDisabled: Bool { viewModel.isCompareLimitReached && !isSelected }
        
    // Di PlaceCardExpandView.swift
    var body: some View {
        VStack { // 1. Kunci jarak atas-bawah di sini (bukan 0)
            
            PlaceCardExpandPhotoView(
                isComparing: isComparing,
                isSelected: isSelected,
                isCheckDisabled: isCheckDisabled,
                place: place,
                viewModel: viewModel,
                selectedImageURL: $selectedImageURL
            )
            
            PlaceCardExpandInfoView(
                place: place, isChooseThisLocationBtnVisible: isChooseThisLocationBtnVisible,
                isExpanded: $isExpanded, selectedPlace: $selectedPlace
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        .transition(.identity)
    }
}

#Preview {
    ZStack {
        Color(UIColor.systemGray6)
            .ignoresSafeArea()
        
        ScrollView {
            PlaceCardExpandView(
                place: Place.dummyData[0], isChooseThisLocationBtnVisible: false,
                isExpanded: .constant(false),
                isComparing: .constant(true),
                viewModel: DecideViewModel(),
                selectedImageURL: .constant(URL(string: Place.dummyData[0].imgUrl ?? "")),
                selectedPlace: .constant(nil),
            )
            .padding(.horizontal)
            .padding(.vertical)
        }
    }
}
