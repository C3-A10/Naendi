//
//  ActionButton.swift
//  Naendi
//
//  Created by Bryan Samuel on 15/07/26.
//

import SwiftUI

struct CustomActionButton: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        text: String,
        backgroundColor: Color,
        textColor: Color,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundColor)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}
