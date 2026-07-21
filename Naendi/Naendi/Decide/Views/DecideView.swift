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
                    loadingIndicator

                case .landing:
                    if viewModel.isLoading && viewModel.landingPagePlaces.isEmpty {
                        loadingIndicator
                    } else {
                        LandingView(viewModel: viewModel)
                    }

                case .results:
                    ResultView(viewModel: viewModel)
                }
            }
            .task {
                viewModel.startLocationUpdates()
                viewModel.restoreCriteria(from: SwiftDataPreferenceStore(context: modelContext))
                await viewModel.loadLandingPlaces(from: placeProvider)
            }
        }
    }

    private var loadingIndicator: some View {
        ProgressView("Memuat rekomendasi...")
            .scaleEffect(1.1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
