//
//  ContentView.swift
//  Naendi
//
//  Created by Bryan Samuel on 13/07/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = FindViewModel(repository: CloudKitPlaceRepository())
    @State private var status: Status = .idle
    @State private var loadSeconds: Double?

    enum Status: Equatable { case idle, loading, done, failed(String) }

    var body: some View {
        VStack(spacing: 16) {
            switch status {
            case .idle:
                Text("Ready to load").foregroundStyle(.secondary)
            case .loading:
                ProgressView("Loading from CloudKit…")
            case .done:
                Text("✅ Loaded \(viewModel.places.count) places").font(.headline)
                if let loadSeconds {
                    Text(String(format: "in %.2f seconds", loadSeconds))
                        .foregroundStyle(.secondary)
                }
            case .failed(let message):
                Text("❌ Failed").font(.headline)
                Text(message)
                    .font(.caption).foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Load Places") { Task { await runLoad() } }
                .buttonStyle(.borderedProminent)
                .disabled(status == .loading)

            // Eyeball a sample to confirm mapping worked
            if !viewModel.places.isEmpty {
                List(Array(viewModel.places.prefix(30).enumerated()), id: \.offset) { _, place in
                    HStack {
                        Text(place.name)
                    }
                }
            }
        }
        .padding()
    }

    func runLoad() async {
        status = .loading
        loadSeconds = nil
        let start = Date()
        do {
            try await viewModel.load()
            loadSeconds = Date().timeIntervalSince(start)
            status = .done
        } catch {
            status = .failed(error.localizedDescription)
        }
    }
}
