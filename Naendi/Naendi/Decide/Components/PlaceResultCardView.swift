//
//  PlaceCardView.swift
//  C3Satriya
//
//  Created by Satriya Handha Wibowo on 13/07/26.
//

import SwiftUI

struct PlaceResultCardView: View {
    let place: Place
    @State private var isExpanded: Bool = false
    @State var viewModel: DecideViewModel
    @State private var isNavigating: Bool = false
    @Binding var isComparing: Bool
    @Binding var selectedImageURL: URL?
    
    var body: some View {
        ZStack {
            NavigationLink(destination: DetailPlaceView(place: place), isActive: $isNavigating) {
                EmptyView()
            }
            .hidden()
            
            // Bungkus dalam satu container yang menangkap tap
            VStack(spacing: 0) {
                if isExpanded {
                    PlaceCardExpandView(place: place, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel, selectedImageURL: $selectedImageURL)
                } else {
                    PlaceCardNormalView(place: place, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel)
                }
            }
            .padding(.horizontal)
            .contentShape(Rectangle()) // Penting agar seluruh area bisa diklik
            .onTapGesture {
                if isComparing {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.toggleSelection(for: place)
                    }
                } else {
                    isNavigating = true
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
            PlaceResultCardView(
                place: Place.dummyData[0],
                viewModel: DecideViewModel(), isComparing: .constant(true),
                selectedImageURL: .constant(nil)
            )
            .padding(.vertical)
        }
    }
}
