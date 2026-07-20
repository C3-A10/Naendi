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
                if viewModel.isLoading {
                    ProgressView("Memuat rekomendasi...")
                        .scaleEffect(1.1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.places.isEmpty {
                    LandingView(viewModel: viewModel)
                        
                } else {
                    ResultView(viewModel: viewModel)
                }
                
            }
            .background {
                GreenBlurBackground()
            }
            .task {
                let provider = PlaceProvider(
                    repository: CloudKitPlaceRepository(),
                    store: SwiftDataPlaceStore(context: modelContext)
                )
                await viewModel.loadTopPlaces(from: provider)
            }
            .onAppear {
                if (viewModel.places.isEmpty) {
                    viewModel.loadLandingPageData()
                }
            }
        }
    }
}

#Preview {
    DecideView()
}
