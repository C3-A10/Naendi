//
//  DistanceCheckmarkView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI

struct DistanceCheckmarkView: View {
    let isComparing: Bool
    let isSelected: Bool
    let isCheckDisabled: Bool
    let place: Place
    let viewModel: DecideViewModel
    let distancePillColor: Color
    let isTagVisible: Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            // 1. Badge Jarak
            Text(viewModel.calculateDistance(to: place))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(distancePillColor)
                .clipShape(Capsule())
            
            if isTagVisible {
                let isNearby = Bool.random() // Peluang 50:50 antara Nearby atau Top
                if isNearby {
                    PlaceTagPillView(title: "Nearby", style: .pinLight)
                    
                } else {
                    let randomTopStyle: PlaceTagStyle = Bool.random() ? .topDark : .topLight
                    PlaceTagPillView(title: "Top \(place.typeTempat)", style: randomTopStyle)
                }
            }
          
            Spacer()
            
            // 2. Checkbox
            if isComparing {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.toggleSelection(for: place)
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(isSelected ? Color("color_green") : (isCheckDisabled ? Color.black.opacity(0.2) : Color.black.opacity(0.5)))
                            .frame(width: 32, height: 32)
                            .overlay(Circle().stroke(isCheckDisabled ? Color.white.opacity(0.3) : Color.white, lineWidth: 2))
                        
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(isCheckDisabled)
            } else {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.toggleSelection(for: place)
                    }
                } label: {
                    Image(systemName: "exclamationmark.bubble")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(16)
    }
}

enum DistanceTagType {
    case top
    case nearby
}

#Preview {
    DistanceCheckmarkView(isComparing: false, isSelected: false, isCheckDisabled: false, place: Place.dummyData[0], viewModel: DecideViewModel(), distancePillColor: .green, isTagVisible: true)
}
