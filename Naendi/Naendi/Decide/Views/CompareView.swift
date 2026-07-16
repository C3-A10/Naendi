//
//  CompareView.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//
import SwiftUI

struct CompareView: View {
    @Environment(\.dismiss) var dismiss
    
    let placeA: Place
    let placeB: Place
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            // Compare Table
            CompareTable(placeA: placeA, placeB: placeB)
            
            // Button
            CustomActionButton(
                text: "Choose this location",
                backgroundColor: .white,
                textColor: .black,
                action: {
                    print("Location Selected!")
                }
            )
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 24)
        }
        Spacer()
    }
}

#Preview {

    CompareView(places: Place.dummyData)
}
