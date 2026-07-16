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
    
    @Binding var selectedPlace: Place?
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            CompareCard(
                item: placeA,
                isSelected: selectedPlace?.id == placeA.id
            ) {
                selectedPlace = placeA
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CompareCard(
                item: placeB,
                isSelected: selectedPlace?.id == placeB.id
            ) {
                selectedPlace = placeB
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .fixedSize(horizontal: false, vertical: true)
    }
}



// MARK: - PREVIEW
#Preview {
    CompareTable(placeA: Place.dummyData[1], placeB: Place.dummyData[2],selectedPlace: .constant(nil))

}
