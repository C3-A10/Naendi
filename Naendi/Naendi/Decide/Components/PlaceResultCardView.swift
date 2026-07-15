//
//  PlaceCardView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI

struct PlaceResultCardView: View {
    let place: Place
    @State private var isExpanded: Bool = false
    @Binding var isComparing: Bool
    var viewModel: DecideViewModel
    @State private var isNavigating: Bool = false
    
    var body: some View {
        ZStack {
            NavigationLink(destination: DetailPlaceView(place: place), isActive: $isNavigating) {
                EmptyView()
            }
            .hidden()
            
            // Bungkus dalam satu container yang menangkap tap
            VStack(spacing: 0) {
                if isExpanded {
                    PlaceCardExpandView(place: place, isExpanded: $isExpanded, isComparing: $isComparing, viewModel: viewModel)
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
                isComparing: .constant(true),
                viewModel: DecideViewModel()
            )
            .padding(.vertical)
        }
    }
}
