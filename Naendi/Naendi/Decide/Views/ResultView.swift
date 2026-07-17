//
//  ResultView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 16/07/26.
//

import SwiftUI

struct ResultView: View {
    
    @State var viewModel: DecideViewModel
    @State private var isComparing: Bool = false
    @State private var selectedImageURL: URL? = nil
    @State private var isNavigatingToCompare: Bool = false
    @State private var selectedPlace: Place? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isComparing ? "Compare" : "Results")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    if isComparing {
                        Text("Select any 2 places to compare")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if isComparing {
                        Button {
                            withAnimation(.spring()) {
                                isComparing = false
                                viewModel.clearSelectedPlaces()
                            }
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(height: 36)
                                .padding(.horizontal, 16)
                                .background(Color(white: 0.15))
                                .clipShape(Capsule())
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                    } else {
                        Button {
                            withAnimation(.spring()) {
                                isComparing = true
                            }
                        } label: {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(white: 0.15))
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        Button {
                            // Aksi edit atau filter
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(white: 0.15))
                                .clipShape(Circle())
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 16)
            
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.places) { place in
                            PlaceCardView(
                                place: place,
                                mode: .result,
                                viewModel: viewModel,
                                isComparing: $isComparing,
                                selectedImageURL: $selectedImageURL,
                                selectedPlace: $selectedPlace 
                            )
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .padding(.bottom, viewModel.isCompareLimitReached ? 80 : 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.clearSelectedPlaces()
            isComparing = false
        }
        .overlay(alignment: .bottom) {
            if isComparing && viewModel.isCompareLimitReached {
                Button {
                    isNavigatingToCompare = true
                } label: {
                    HStack(spacing: 8) {
                        Text("Compare (\(viewModel.selectedPlaces.count) places)")
                            .font(.system(size: 16, weight: .bold))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color("color_green"))
                    .clipShape(Capsule())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationDestination(item: $selectedImageURL) { url in
            FullImageDetailView(url: url)
        }
        .navigationDestination(item: $selectedPlace) { place in
            DetailPlaceView(place: place)
        }
        .navigationDestination(isPresented: $isNavigatingToCompare) {
            if viewModel.selectedPlaces.count >= 2 {
                CompareView(placeA: viewModel.selectedPlaces[0], placeB: viewModel.selectedPlaces[1])
                    .navigationTitle("Compare")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ResultView(
        viewModel: DecideViewModel()
    )
}
