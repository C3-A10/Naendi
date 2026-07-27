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
    
    @State private var isShowingPopover = false
    
    // Mengecek apakah text adalah PlaceType atau VibeType, lalu mengambil deskripsinya
    private var matchedDescription: String? {
        if let place = PlaceType.allCases.first(where: { $0.rawValue.caseInsensitiveCompare(text) == .orderedSame }) {
            return place.description
        }
        
        if let vibe = VibeType.allCases.first(where: { $0.rawValue.caseInsensitiveCompare(text) == .orderedSame }) {
            return vibe.description
        }
        
        if let halal = HalalType.allCases.first(where: { $0.rawValue.caseInsensitiveCompare(text) == .orderedSame }) {
            return halal.description
        }
        
        return nil
    }
    
    var body: some View {
        Text(LocalizedStringKey(text))
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(8)
            .onTapGesture {
                if matchedDescription != nil {
                    isShowingPopover.toggle()
                }
            }
            .popover(isPresented: $isShowingPopover, arrowEdge: .top) {
                if let description = matchedDescription {
                    VStack(alignment: .leading, spacing: 6) {
                        // Judul Tag
                        Text(LocalizedStringKey(text))
                            .font(.subheadline)
                            .bold()
                        
                        // Deskripsi dari Enum
                        Text(LocalizedStringKey(description))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .presentationCompactAdaptation(.popover)
                }
            }
    }
}

#Preview{
    TagView(text: "Hello", backgroundColor: Color.red, textColor: Color.green)
}
