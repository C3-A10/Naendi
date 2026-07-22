//
//  TagView.swift
//  Naendi
//
//  Created by Bryan Samuel on 16/07/26.
//
import SwiftUI

// MARK: - Sub Component Tags
struct TagView: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        Text(LocalizedStringKey(text))
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(8)
    }
}

#Preview{
    TagView(text: "Hello", backgroundColor: Color.red, textColor: Color.green)
}
