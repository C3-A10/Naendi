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
    @State private var selectedImageURL: URL?
    @State private var isNavigatingToCompare = false
    @State private var selectedPlace: Place?
    @State private var isShowingEditPreference = false

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
                            isShowingEditPreference = true
                        } label: {
                            Image(systemName: "pencil")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color(white: 0.15))
                                .clipShape(Circle())
                                .contentShape(Circle())
                        }
                        .buttonStyle(.plain)
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
                                    isTagVisible: false,
                                    isReportVisible: false,
                                    viewModel: viewModel,
                                    isComparing: $isComparing,
                                    selectedImageURL: $selectedImageURL,
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
        .fullScreenCover(item: $selectedImageURL) { url in
            NavigationStack {
                FullImageDetailView(url: url)
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
