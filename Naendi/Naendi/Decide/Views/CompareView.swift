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
    
    @State private var selectedPlace: Place?
    @State private var isNavigatingToDetail = false
    
    private var detailDestination: some View {
        Group {
            if let selectedPlace {
                DetailPlaceView(place: selectedPlace)
            } else {
                EmptyView()
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Compare Table
                CompareTable(placeA: placeA, placeB: placeB, selectedPlace: $selectedPlace)
                
                // Button
                CustomActionButton(
                    text: "Choose this location",
                    backgroundColor: selectedPlace == nil ? Color.gray.opacity(0.2) : .white,
                    textColor: selectedPlace == nil ? .gray : .black,
                    isDisabled: selectedPlace == nil,
                    action: {
                        guard selectedPlace != nil else { return }
                        isNavigatingToDetail = true
                    }
                )
                .padding(.top, 16)
                .padding(.bottom, 12)
                .padding(.horizontal, 24)
                
                Spacer(minLength: 0)
            }
            
            NavigationLink(destination: detailDestination, isActive: $isNavigatingToDetail) {
                EmptyView()
            }
            .hidden()
        }
        .navigationTitle(selectedPlace?.nama ?? "Compare")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CompareView(placeA: Place.dummyData[1], placeB: Place.dummyData[2])
}
