//
//  ResultView.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import SwiftUI

struct ResultView: View {
    @State private var viewModel = DecideViewModel()
    @State private var isComparing: Bool = false
    @State private var selectedImageURL: URL? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Custom Header (Pengganti Native Navigation Bar)
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
                            // SAAT MODE COMPARE: Hanya ada tombol Cancel
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
                            // SAAT NORMAL: Tombol Compare dan Tombol Edit
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
                                // Aksi edit atau profil
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
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)
                
                // MARK: - Konten Utama
                ZStack {
                    if viewModel.isLoading {
                        ProgressView("Memuat rekomendasi...")
                            .scaleEffect(1.1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.places.isEmpty {
                        // Tampilan saat hasil kosong
                        VStack(spacing: 16) {
                            Text("No results found")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Edit Your Preference First To get results")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 20) {
                                ForEach(viewModel.places) { place in
                                    PlaceResultCardView(
                                        place: place,
                                        cardHeight: 240,
                                        viewModel: viewModel,
                                        isComparing: $isComparing,
                                        selectedImageURL: $selectedImageURL
                                    )
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.bottom, viewModel.isCompareLimitReached ? 80 : 16)
                        }
                    }
                }
            }
            // Sembunyikan navigation bar bawaan secara penuh
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                viewModel.loadDummyData()
                viewModel.clearSelectedPlaces()
                isComparing = false
            }
            // MARK: - Tombol Melayang "Compare" (Muncul saat pas 2 kartu dipilih)
            .overlay(alignment: .bottom) {
                if isComparing && viewModel.isCompareLimitReached {
                    NavigationLink(destination: CompareView(placeA:viewModel.selectedPlaces[0], placeB: viewModel.selectedPlaces[1] ).navigationTitle("Compare")
                        .navigationBarTitleDisplayMode(.inline)) {
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
                    // FullImageDetailView(url: url)
            }
        }
    }
}

#Preview {
    ResultView()
}
