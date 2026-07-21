//
//  ReportBubbleView.swift
//  Naendi
//
//  Created by Bryan Samuel on 21/07/26.
//

import SwiftUI

/// A badge showing the report count with a bubble icon.
/// Used on place cards to indicate how many reports a location has received.
struct ReportBubbleView: View {
    let reportCount: Int

    var body: some View {
        HStack(spacing: -6) {
            Text("\(reportCount)")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 16, height: 16)
                .background(Color(red: 0.61, green: 0.80, blue: 0.22))
                .clipShape(Circle())
                .zIndex(1)

            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 20))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ReportBubbleView(reportCount: 5)
    }
}
