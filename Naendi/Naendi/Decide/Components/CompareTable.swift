//
//  CompareTable.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import SwiftUI

// MARK: - Compare Table
struct CompareTable: View {
    let placeA: Place
    let placeB: Place
    let viewModel: DecideViewModel
    
    @Binding var selectedPlace: Place?
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 10) {
                selectionButton(for: placeA)
                CompareCard(
                    item: placeA,
                    isSelected: selectedPlace?.id == placeA.id,
                    onTap: {
                        selectedPlace = placeA
                    },
                    viewModel: viewModel
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 10) {
                selectionButton(for: placeB)
                CompareCard(
                    item: placeB,
                    isSelected: selectedPlace?.id == placeB.id,
                    onTap: {
                        selectedPlace = placeB
                    },
                    viewModel: viewModel
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func selectionButton(for place: Place) -> some View {
        Button(action: {
            if selectedPlace?.id == place.id {
                selectedPlace = nil
            } else {
                selectedPlace = place
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color(red: 0.22, green: 0.55, blue: 0.42), lineWidth: 2)
                    )

                if selectedPlace?.id == place.id {
                    Circle()
                        .fill(Color(red: 207/255, green: 245/255, blue: 64/255))
                        .frame(width: 14, height: 14)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityHidden(true)
    }
}



// MARK: - PREVIEW
#Preview {
    CompareTable(
        placeA: Place.dummyData[1],
        placeB: Place.dummyData[2],
        viewModel: DecideViewModel(),
        selectedPlace: .constant(nil)
    )
}
