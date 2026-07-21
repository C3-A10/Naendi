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
    let isDetail: Bool
    let onReport: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            // 1. Badge Jarak
            Text(viewModel.calculateDistance(to: place))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(distancePillColor)
                .clipShape(Capsule())
            
            if isTagVisible {
                TagView(text: "Viral", backgroundColor: .red, textColor: .white)
                
                TagView(text: "Trending", backgroundColor: .yellow, textColor: .black)
                
                TagView(text: "Top rating", backgroundColor: .blue, textColor: .white)
            }
          
            Spacer()
            
            // 2. Checkbox or report bubble
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
            } else if isDetail {
                Button {
                    onReport()
                } label: {
                    Image(systemName: "exclamationmark.bubble")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
            } else {
                ReportBubbleView(reportCount: viewModel.reportCount(for: place))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(16)
    }
}

#Preview {
    
}
