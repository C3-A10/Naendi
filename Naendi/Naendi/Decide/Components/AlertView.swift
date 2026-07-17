//
//  ReportAlert.swift
//  Naendi
//
//  Created by Bryan Samuel on 17/07/26.
//

import SwiftUI

struct AlertView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {

            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(message)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: action) {
                Text(buttonTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color.white.opacity(0.12))
                    )
            }
            .buttonStyle(.plain)

        }
        .padding(20)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color(red: 18/255, green: 18/255, blue: 20/255))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }
}

#Preview{
    AlertView(title: "Make sure you're at the location and that GPS is enabled.", message: "Report can only be submitted on-site to keep information accurate.", buttonTitle: "I Understand", action: {})
}
