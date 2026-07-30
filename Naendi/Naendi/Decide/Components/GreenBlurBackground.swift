//
//  GreenBackground.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 20/07/26.
//

import SwiftUI

struct GreenBlurBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    private var baseColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color("color_green_background"), location: 0.0),              // Atas layar (Status bar)
                .init(color: Color("color_green_background").opacity(0.8), location: 0.25), // Area judul
                .init(color: baseColor, location: 0.55),                                    // Transisi ke warna dasar
                .init(color: baseColor, location: 1.0)                                      // Dasar layar
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    VStack {
        GreenBlurBackground()
    }
    .preferredColorScheme(.dark)
}
