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
    let viewModel: DecideViewModel
    
    @State private var selectedPlace: Place?
    @State private var isShowingDetail = false
    
    init(placeA: Place, placeB: Place, viewModel: DecideViewModel) {
        self.placeA = placeA
        self.placeB = placeB
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header Bar
                ZStack {
                    Text("Compare")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 48)

                    HStack {
                        Spacer()

                        CircleIconButton(
                            systemName: "xmark",
                            accessibilityLabel: "Close",
                            backgroundColor: Color(.systemBackground)
                        ) {
                            withAnimation(.spring()) {
                                dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .frame(maxWidth: .infinity)
                // Compare Table
                CompareTable(
                    placeA: placeA,
                    placeB: placeB,
                    viewModel: viewModel,
                    selectedPlace: $selectedPlace
                )
                
                // Button
                CustomActionButton(
                    text: "Choose this location",
                    backgroundColor: selectedPlace == nil ? Color.gray.opacity(0.2) : .white,
                    textColor: selectedPlace == nil ? .gray : .black,
                    isDisabled: selectedPlace == nil,
                    action: {
                        guard selectedPlace != nil else { return }
                        isShowingDetail = true
                    }
                )
                .padding(.top, 16)
                .padding(.bottom, 12)
                .padding(.horizontal, 24)
                
                Spacer(minLength: 0)
            }
            
            .fullScreenCover(isPresented: $isShowingDetail, onDismiss: {
                dismiss()
            }) {
                if let selectedPlace {
                    NavigationStack {
                        DetailPlaceView(place: selectedPlace)
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .background {
            GreenBlurBackground()
        }
        
    }
}

#Preview {
    CompareView(placeA: Place.dummyData[1], placeB: Place.dummyData[2], viewModel: DecideViewModel())
}
