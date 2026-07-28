//
//  DetailRow.swift
//  Naendi
//
//  Created by Bryan Samuel on 24/07/26.
//
import SwiftUI
// MARK: - Sub Component Detail Row
struct DetailRowView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(LocalizedStringKey(title))
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(value)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 6)
    }
}
