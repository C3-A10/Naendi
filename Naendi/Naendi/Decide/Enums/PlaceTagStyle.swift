//
//  PlaceTagStyle.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 21/07/26.
//

import SwiftUI

enum PlaceTagStyle {
    case topDark   // Star putih -> BG Hijau Tua
    case topLight  // Star fill -> BG Hijau Terang
    case pinLight  // Pin -> BG Hijau Terang
    
    // Warna Background
    var backgroundColor: Color {
        switch self {
        case .topDark:
            return Color.colorGreenDark
        case .topLight, .pinLight:
            return Color(red: 0.88, green: 0.95, blue: 0.85)
        }
    }
    
    // Warna Teks & Ikon
    var contentColor: Color {
        switch self {
        case .topDark:
            return .white
        case .topLight, .pinLight:
            return Color.black
        }
    }
    
    // Nama Custom Asset
    var iconName: String {
        switch self {
        case .topDark:
            return "icon_star"
        case .topLight:
            return "icon_star_fill"
        case .pinLight:
            return "icon_pin"
        }
    }
}
