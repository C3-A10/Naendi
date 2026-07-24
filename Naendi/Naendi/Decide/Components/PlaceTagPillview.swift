//
//  PlaceTagPillview.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 21/07/26.
//

import SwiftUI

struct PlaceTagPillView: View {
    let title: String
    var style: PlaceTagStyle
    
    var body: some View {
        HStack(spacing: 4) {

            Image(style.iconName)
                .resizable()
                .frame(width: style == .pinLight ? 9 : 15, height: 15)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(style.contentColor)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(style.backgroundColor)
        .clipShape(Capsule())
    }
}

#Preview {
    PlaceTagPillView(title: "Nearby", style: .pinLight)
}
