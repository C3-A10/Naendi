//
//  DecideView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 16/07/26.
//

import SwiftUI

struct DecideView: View {
    
    @State private var viewModel = DecideViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Memuat rekomendasi...")
                        .scaleEffect(1.1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.places.isEmpty {
                    LandingView()
                } else {
                    ResultView(viewModel: viewModel)
                }
            }
            .onAppear {
                viewModel.loadDummyData()
            }
        }
    }
}

#Preview {
    DecideView()
}
