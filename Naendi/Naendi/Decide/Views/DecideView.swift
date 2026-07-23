//
//  DecideView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 16/07/26.
//

import SwiftUI
import SwiftData

struct DecideView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DecideViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .loading:
                    loadingIndicator()

                case .landing:
                    if viewModel.isLoading && viewModel.landingPagePlaces.isEmpty {
                        loadingIndicator("Loading places…")
                    } else if let errorMessage = viewModel.errorMessage {
                        landingErrorState(message: errorMessage)
                    } else if viewModel.landingPagePlaces.isEmpty {
                        landingEmptyState
                    } else {
                        LandingView(viewModel: viewModel)
                    }

                case .results:
                    ResultView(viewModel: viewModel)
                } 
            }
            .background {
                GreenBlurBackground()
            }
            .task {
                viewModel.startLocationUpdates()
                // Landing is a one-time onboarding teaser: once the user has ever
                // saved preferences, go straight to results on every launch.
                let hasPreferences = viewModel.restoreCriteria(
                    from: SwiftDataPreferenceStore(context: modelContext)
                )
                if hasPreferences {
                    await viewModel.loadRecommendations(
                        from: placeProvider,
                        criteria: viewModel.criteria
                    )
                } else {
                    await viewModel.loadLandingPlaces(from: placeProvider)
                }
            }
            .onChange(of: viewModel.origin) { oldValue, newValue in
                guard oldValue == nil, newValue != nil else { return }
                Task {
                    if viewModel.phase == .landing {
                        await viewModel.loadLandingPlaces(from: placeProvider)
                    } else if viewModel.awaitingOrigin {
                        await viewModel.loadRecommendations(
                            from: placeProvider,
                            criteria: viewModel.criteria
                        )
                    }
                }
            }
        }
    }

    private func loadingIndicator(_ title: String = "Finding recommendations…") -> some View {
        ProgressView(title)
            .controlSize(.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func landingErrorState(message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Places", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again", systemImage: "arrow.clockwise") {
                Task {
                    await viewModel.loadLandingPlaces(from: placeProvider)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var landingEmptyState: some View {
        ContentUnavailableView {
            Label("No Places Available", systemImage: "mappin.slash")
        } description: {
            Text("We couldn't find any places to show right now.")
        } actions: {
            Button("Reload", systemImage: "arrow.clockwise") {
                Task {
                    await viewModel.loadLandingPlaces(from: placeProvider)
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var placeProvider: PlaceProviding {
        PlaceProvider(
            repository: CloudKitPlaceRepository(),
            store: SwiftDataPlaceStore(context: modelContext)
        )
    }
}

#Preview {
    DecideView()
}
