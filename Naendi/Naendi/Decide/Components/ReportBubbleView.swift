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
    @State private var isShowingPopover = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "exclamationmark.bubble.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)

            Text("\(reportCount)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .frame(width: 16, height: 16)
                .background(Color("color_green"))
                .clipShape(Circle())
                .offset(x: 6, y: -4)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reports")
        .accessibilityValue("\(reportCount)")
        .onTapGesture {
            isShowingPopover.toggle()
        }
        .popover(isPresented: $isShowingPopover, arrowEdge: .top) {
            Text("There are \(reportCount) number of reports made about this place being inaccurate.")
                .font(.footnote)
                .padding()
                .presentationCompactAdaptation(.popover)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ReportBubbleView(reportCount: 5)
    }
}
