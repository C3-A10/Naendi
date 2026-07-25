//
//  FullImageDetailView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import SwiftUI

struct FullImageDetailView: View {
    let imageUrls: [String]
    let startIndex: Int
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int
    
    init(imageUrls: [String], startIndex: Int) {
        self.imageUrls = imageUrls
        self.startIndex = startIndex
        self._selectedIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.black
                .ignoresSafeArea()
            VStack {
                header
                TabView(selection: $selectedIndex) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, urlString in
                        ZoomableImageItem(urlString: urlString)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
    }
    
    private var header: some View {
        ZStack {
            Text("\(selectedIndex + 1) / \(imageUrls.count)")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                
            HStack {
                Spacer() // Mendorong konten ke kanan
                
                CircleIconButton(
                    systemName: "xmark",
                    accessibilityLabel: "Close full image",
                    backgroundColor: Color(.darkGray)
                ) {
                    dismiss()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}

#Preview {
    FullImageDetailView(
        imageUrls: [
            "https://images.unsplash.com/photo-1554118811-1e0d58224f24?q=80&w=800&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1559925393-8be0ec4767c8?q=80&w=800&auto=format&fit=crop"
        ],
        startIndex: 0
    )
}
