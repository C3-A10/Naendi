//
//  LandingView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 16/07/26.
//

import SwiftUI

struct LandingView: View {
    @State var viewModel: DecideViewModel
    @State private var isComparing: Bool = false
    @State private var selectedImageURL: URL? = nil
    @State private var selectedPlace: Place? = nil

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.landingPagePlaces) { place in
                            PlaceCardView(
                                place: place,
                                mode: .landing,
                                viewModel: viewModel,
                                isComparing: $isComparing,
                                selectedImageURL: $selectedImageURL,
                                selectedPlace: $selectedPlace
                            )
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .padding(.bottom, viewModel.isCompareLimitReached ? 80 : 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.clearSelectedPlaces()
            isComparing = false
        }
        .navigationDestination(item: $selectedImageURL) { url in
            FullImageDetailView(url: url)
        }
        .fullScreenCover(item: $selectedPlace) { place in
            NavigationStack {
                DetailPlaceView(place: place)
            }
        }
    }
}

#Preview {
    LandingView(viewModel: DecideViewModel())
}
