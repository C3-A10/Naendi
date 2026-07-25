//
//  NoInternetPlaceholder.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 25/07/26.
//

import SwiftUI

struct NoInternetPlaceholder: View {
    
    var paddingBottom: CGFloat = 0
    var isCaptionHidden: Bool = false
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
            VStack(spacing: 4) {
                
                Image(systemName: "wifi.slash")
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.8))
                
                if !isCaptionHidden {
                    Text("No internet connection")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray.opacity(0.8))
                    
                    Text("Failed to load image")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            .padding(.bottom, paddingBottom)
        }
    }
}

#Preview {
    NoInternetPlaceholder()
}
