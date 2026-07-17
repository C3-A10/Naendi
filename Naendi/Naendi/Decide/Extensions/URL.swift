//
//  URL.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 17/07/26.
//

import SwiftUI

// MARK: - Extension agar URL bisa digunakan pada .fullScreenCover(item:)
extension URL: @retroactive Identifiable {
    public var id: String { self.absoluteString }
}
