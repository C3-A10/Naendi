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
        ZStack(alignment: .topTrailing) {
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

            Text("\(reportCount)")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 16, height: 16)
                .background(Color("color_green"))
                .clipShape(Circle())
                .offset(x: 6, y: -4)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ReportBubbleView(reportCount: 5)
    }
}
