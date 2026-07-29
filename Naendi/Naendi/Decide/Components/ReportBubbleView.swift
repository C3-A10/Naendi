//
//  ReportBubbleView.swift
//  Naendi
//
//  Created by Bryan Samuel on 21/07/26.
//

import SwiftUI
import UIKit
import Combine

/// A badge showing the report count with a bubble icon.
/// Used on place cards to indicate how many reports a location has received.
struct ReportBubbleView: View {
    let reportCount: Int
    @State private var isShowingPopover = false

    var body: some View {
        Button {
            if UIAccessibility.isVoiceOverRunning {
                isShowingPopover = false
                UIAccessibility.post(notification: .announcement, argument: reportDescription)
            } else {
                isShowingPopover.toggle()
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "exclamationmark.bubble.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                Text("\(reportCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .foregroundColor(.black)
                    .frame(minWidth: 20, minHeight: 20)
                    .padding(.horizontal, reportCount > 9 ? 3 : 0)
                    .background(Color("color_green"))
                    .clipShape(Capsule())
            }
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Reports")
        .accessibilityValue("\(reportCount)")
        .accessibilityHint(Text(reportDescription))
        .popover(isPresented: $isShowingPopover, arrowEdge: .top) {
            Text(reportDescription)
                .font(.footnote)
                .padding()
                .presentationCompactAdaptation(.popover)
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIAccessibility.voiceOverStatusDidChangeNotification
            )
        ) { _ in
            if UIAccessibility.isVoiceOverRunning {
                isShowingPopover = false
            }
        }
    }

    private var reportDescription: String {
        String(
            format: String(
                localized: "There are %lld number of reports made about this place being inaccurate."
            ),
            locale: .current,
            Int64(reportCount)
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ReportBubbleView(reportCount: 5)
    }
}
