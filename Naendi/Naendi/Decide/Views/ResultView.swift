//
//  ResultView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo & Bryan Samuel on 16/07/26.
//

import SwiftUI
import SwiftData

struct ResultView: View {
    @Environment(\.modelContext) private var modelContext
    @State var viewModel: DecideViewModel
    @State private var isComparing = false
    @State private var isNavigatingToCompare = false
    @State private var selectedPlace: Place?
    @State private var isShowingEditPreference = false
    @State private var imgStartIndex: Int = 0
    @State private var selectedPlaceForImage: Place?

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isComparing ? "Compare" : "Results")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    if isComparing {
                        Text("Select any 2 places to compare")
                            //.font(.system(size: 14, weight: .medium))
                            .font(.callout.weight(.medium))
                            .foregroundColor(.gray)
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
                                .foregroundColor(.primary)
                                .frame(height: 36)
                                .padding(.horizontal, 16)
                                .background(.background)
                                .clipShape(Capsule())
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                    } else {
                        
                        CircleIconButton(systemName: "arrow.left.arrow.right", accessibilityLabel: "Compare", backgroundColor: Color(.systemBackground)) {
                            withAnimation(.spring()) {
                                isComparing = true
                            }
                        }
                        .transition(.scale.combined(with: .opacity))

                        
                        CircleIconButton(systemName: "pencil", accessibilityLabel: "Preference",                     backgroundColor: Color(.systemBackground)) {
                            withAnimation(.spring()) {
                                isShowingEditPreference = true
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)

            ZStack {
                if viewModel.isLoading && viewModel.places.isEmpty {
                    ProgressView("Memuat rekomendasi...")
                        .scaleEffect(1.1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView {
                        Label("Unable to Load Recommendations", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again", systemImage: "arrow.clockwise") {
                            reloadRecommendations()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.places.isEmpty {
                    ContentUnavailableView {
                        Label("No Results Found", systemImage: "magnifyingglass")
                    } description: {
                        Text("Try adjusting your preferences or increasing the search radius.")
                    } actions: {
                        Button("Edit Preferences", systemImage: "slider.horizontal.3") {
                            isShowingEditPreference = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.places) { place in
                                
                                PlaceCardView(
                                    place: place,
                                    mode: .result,
                                    isChooseThisLocationBtnVisible: true,
                                    isTagVisible: true,
                                    isReportVisible: false,
                                    viewModel: viewModel,
                                    isComparing: $isComparing,
                                    onSelectImageIndex: { index in
                                        imgStartIndex = index
                                        selectedPlaceForImage = place
                                    },
                                    selectedPlace: $selectedPlace
                                )
        
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .padding(.bottom, (isComparing && viewModel.isCompareLimitReached) ? 80 : 16)
                    }
                    .refreshable {
                        await viewModel.loadRecommendations(
                            from: AppServices.placeProvider(context: modelContext),
                            criteria: viewModel.criteria
                        )
                    }
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
                CustomActionButton(text: "Compare (\(viewModel.selectedPlaces.count) places)", backgroundColor: Color("color_green"), textColor: .black) {
                   isNavigatingToCompare = true
                }
                .foregroundColor(.black)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .fullScreenCover(item: $selectedPlaceForImage) { place in
            NavigationStack {
                FullImageDetailView(imageUrls: place.parsedImageUrls, startIndex: imgStartIndex)
                    .id("\(place.id)-\(imgStartIndex)")
            }
        }
        .fullScreenCover(item: $selectedPlace) { place in
            NavigationStack {
                DetailPlaceView(place: place)
            }
        }
        .fullScreenCover(isPresented: $isNavigatingToCompare) {
            if viewModel.selectedPlaces.count >= 2 {
                NavigationStack {
                    CompareView(
                        placeA: viewModel.selectedPlaces[0],
                        placeB: viewModel.selectedPlaces[1],
                        viewModel: viewModel
                    )
                    .navigationTitle("Compare")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingEditPreference) {
            EditPreferenceView(criteria: viewModel.criteria) { criteria in
                Task {
                    await viewModel.applyPreferences(
                        criteria,
                        store: AppServices.preferenceStore(context: modelContext),
                        provider: AppServices.placeProvider(context: modelContext)
                    )
                }
            }
        }
        .alert(
            "Preferences not saved",
            isPresented: Binding(
                get: { viewModel.persistenceErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.persistenceErrorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.persistenceErrorMessage = nil
            }
        } message: {
            Text(viewModel.persistenceErrorMessage ?? "")
        }
    }

    private func reloadRecommendations() {
        Task {
            await viewModel.loadRecommendations(
                from: AppServices.placeProvider(context: modelContext),
                criteria: viewModel.criteria
            )
        }
    }
}

#Preview {
    ResultView(viewModel: DecideViewModel())
}
