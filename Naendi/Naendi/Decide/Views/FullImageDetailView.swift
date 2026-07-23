//
//  FullImageDetailView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI

struct FullImageDetailView: View {
    let url: URL
    
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Latar belakang hitam penuh mengabaikan Safe Area
            Color.black
                .ignoresSafeArea()
            
            // Render Gambar
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        // Fitur Pinch-to-Zoom menggunakan MagnificationGesture
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1.0), 4.0) // Batasi zoom minimal 1x, maksimal 4x
                                }
                                .onEnded { _ in
                                    lastScale = 1.0
                                    if scale < 1.0 {
                                        withAnimation(.spring()) {
                                            scale = 1.0
                                        }
                                    }
                                }
                        )
                        // Double tap untuk reset zoom
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1.0 {
                                    scale = 1.0
                                } else {
                                    scale = 2.0
                                }
                            }
                        }
                        .accessibilityLabel("Place photo")
                        .accessibilityValue("Zoom \(Int(scale * 100)) percent")
                        .accessibilityHint("Swipe up or down to zoom.")
                        .accessibilityAdjustableAction { direction in
                            switch direction {
                            case .increment:
                                scale = min(scale + 0.5, 4.0)
                            case .decrement:
                                scale = max(scale - 0.5, 1.0)
                            @unknown default:
                                break
                            }
                        }
                    
                case .failure(_):
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .accessibilityHidden(true)
                        Text("Failed to load image")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                case .empty:
                    ProgressView()
                        .tint(.white)
                        
                @unknown default:
                    EmptyView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.white) // Pastikan dikunci warna putih
                }
                .frame(minWidth: 44, minHeight: 44)
                .accessibilityLabel("Back")
                .accessibilityInputLabels(["Back"])
            }
        }
    }
}

#Preview {
    NavigationStack {
        FullImageDetailView(url: URL(string: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=800&auto=format&fit=crop")!)
    }
}
