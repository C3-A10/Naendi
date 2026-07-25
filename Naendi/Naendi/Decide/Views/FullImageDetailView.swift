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
        ZStack {
            Color.black
                .ignoresSafeArea()
            TabView(selection: $selectedIndex) {
                ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, urlString in
                    ZoomableImageItem(urlString: urlString)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(selectedIndex + 1) / \(imageUrls.count)")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Ikon close di kanan karena bentuknya Modal (sheet/fullScreenCover)
            ToolbarItem(placement: .topBarTrailing) {
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        
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
