//
//  FullImageDetailView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI

struct FullImageDetailView: View {
    let url: URL
    
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
                    
                case .failure(_):
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("Gagal memuat gambar")
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
        // Konfigurasi Navigation Bar agar menyatu dengan tema gelap
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar) // Memastikan tombol "Back" berwarna putih/terang
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar) // Navbar diwarnai hitam senada
    }
}

#Preview {
    NavigationStack {
        FullImageDetailView(url: URL(string: "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=800&auto=format&fit=crop")!)
    }
}
