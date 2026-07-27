//
//  ZoomableImageItem.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 25/07/26.
//

import SwiftUI

struct ZoomableImageItem: View {
    let urlString: String

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        if let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / lastScale
                                    lastScale = value
                                    scale = min(max(scale * delta, 1.0), 4.0) // Batasi zoom
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
                    NoInternetPlaceholder(isTransparent: true)

                case .empty:
                    ProgressView()
                        .tint(.white)

                @unknown default:
                    EmptyView()
                }
            }
        } else {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                Text("Invalid image URL")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
        }
    }
}
