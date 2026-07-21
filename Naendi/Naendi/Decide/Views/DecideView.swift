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
                viewModel.restoreCriteria(from: SwiftDataPreferenceStore(context: modelContext))
                await viewModel.loadLandingPlaces(from: placeProvider)
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
