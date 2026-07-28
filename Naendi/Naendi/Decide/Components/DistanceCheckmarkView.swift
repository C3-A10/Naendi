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
    let isReported: Bool
    let onReport: () -> Void
    @State private var isShowingDistancePopover = false

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            // 1. Badge Jarak
            Text(viewModel.calculateDistance(to: place))
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(distancePillColor)
                .clipShape(Capsule())
                .accessibilityLabel("Distance")
                .accessibilityValue(viewModel.calculateDistance(to: place))
                .onTapGesture {
                    isShowingDistancePopover.toggle()
                }
                .popover(isPresented: $isShowingDistancePopover, arrowEdge: .top) {
                    Text("You are \(viewModel.calculateDistance(to: place)) away from \(viewModel.criteria.locationName ?? "your location")")
                        .font(.footnote)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            
            if isTagVisible, let tag = viewModel.landingTag(for: place) {
                switch tag {
                case .nearby:
                    PlaceTagPillView(title: "Nearby", style: .pinLight)
                case .top(let type):
                    // Deterministic style so the pill doesn't flicker on redraw.
                    PlaceTagPillView(
                        title: "Top \(type)",
                        style: place.jumlahReview.isMultiple(of: 2) ? .topDark : .topLight
                    )
                }
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
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Circle())
                .accessibilityRespondsToUserInteraction(true)
                .accessibilitySortPriority(3)
                .accessibilityLabel(Text("Select \(place.nama) for comparison"))
                .accessibilityValue(
                    Text(
                        isSelected
                            ? String(localized: "Selected")
                            : String(localized: "Not selected")
                    )
                )
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            } else if isDetail {
                Button {
                    onReport()
                } label: {
                    Image(systemName: isReported ? "exclamationmark.bubble.fill" : "exclamationmark.bubble")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(isReported ? Color("color_green") : .white)
                        .frame(width: 32, height: 32)
                        .padding(6)
                }
                .buttonStyle(.plain)
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel(isReported ? "Place reported" : "Report \(place.nama)")
                .accessibilityHint(isReported ? "" : "Reports inaccurate information about this place.")
                .shadow(
                        color: !isReported ? .black.opacity(0.15) : .clear,
                        radius: !isReported ? 4 : 0,
                        x: 0,
                        y: 2
                    )
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
    VStack(spacing: 20) {
        DistanceCheckmarkView(
            isComparing: false,
            isSelected: false,
            isCheckDisabled: false,
            place: Place.dummyData[0],
            viewModel: DecideViewModel(),
            distancePillColor: .green,
            isTagVisible: true,
            isDetail: false,
            isReported: false,
            onReport: {}
        )
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        
        DistanceCheckmarkView(
            isComparing: true,
            isSelected: true,
            isCheckDisabled: false,
            place: Place.dummyData[0],
            viewModel: DecideViewModel(),
            distancePillColor: .green,
            isTagVisible: true,
            isDetail: false,
            isReported: false,
            onReport: {}
        )
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)

        DistanceCheckmarkView(
            isComparing: false,
            isSelected: false,
            isCheckDisabled: false,
            place: Place.dummyData[0],
            viewModel: DecideViewModel(),
            distancePillColor: .green,
            isTagVisible: true,
            isDetail: true,
            isReported: true,
            onReport: {}
        )
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    .padding()
}
