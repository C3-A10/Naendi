//
//  ComponentCard.swift
//  Naendi
//
//  Created by Bryan Samuel on 16/07/26.
//
import SwiftUI

// MARK: - Compare Card
struct CompareCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let item: Place
    let isSelected: Bool
    let onTap: () -> Void
    let viewModel: DecideViewModel
    
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: Image & Badge
                ZStack(alignment: .topTrailing) {
                    
                    if let imgUrlString = item.imgUrl,
                       !imgUrlString.isEmpty,
                       let url = URL(string: imgUrlString) {
                        
                        AsyncImage(url: url) { phase in
                            switch phase {
                                
                            case .success(let image):
                                GeometryReader { geo in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .clipped()
                                }
                                .frame(height: 130)
                                
                            case .failure, .empty:
                                placeholderView
                                
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .accessibilityHidden(true)
                        
                    } else {
                        placeholderView
                    }
                    
                    ReportBubbleView(reportCount: viewModel.reportCount(for: item))
                        .padding(.top, 10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(item.nama)
                        .font(.headline)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 10)
                        .foregroundColor(.primary)
                    
                    BrickLayout(spacing: 6) {
                        
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 0.95, green: 0.76, blue: 0.29))
                                .font(.caption)
                            
                            Text(String(format: "%.1f", item.rating))
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.gray)
                        }
                        
                        TagView(
                            text: item.vibe,
                            backgroundColor: Color(red: 0.82, green: 0.94, blue: 0.89),
                            textColor: Color(red: 0.22, green: 0.55, blue: 0.42)
                        )
                        
                        if item.halal.lowercased() == "halal" {
                            TagView(
                                text: "Halal",
                                backgroundColor: Color(red: 0.98, green: 0.84, blue: 0.53),
                                textColor: Color(red: 0.72, green: 0.44, blue: 0.16)
                            )
                        } else if item.halal.lowercased() == "non-halal"{
                            TagView(
                                text: "Non-Halal",
                                backgroundColor: Color(red: 0.98, green: 0.85, blue: 0.85),
                                textColor: Color(red: 0.75, green: 0.22, blue: 0.22)
                            )
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        if let locationName = viewModel.criteria.locationName,
                           viewModel.criteria.coordinate != nil {
                            Text("\(viewModel.calculateDistance(to: item)) dari \(locationName),")
                        };
                            Text("\(viewModel.calculateDistanceFromMe(to: item)) dari lokasi Anda saat ini.")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    DetailRowView(title: "Address", value: item.alamat)
                    DetailRowView(title: "Price Range", value: item.rangeHarga)
                    DetailRowView(title: "Operating Hour", value: item.jamHariIniFormatted)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected ? Color(red: 207/255, green: 245/255, blue: 64/255) : .clear,
                        lineWidth: 4
                    )
                    .shadow(
                        color: isSelected ? Color(red: 207/255, green: 245/255, blue: 64/255).opacity(0.9) : .clear,
                        radius: 10
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.nama)
        .accessibilityValue(compareAccessibilityValue)
        .accessibilityHint("Selects this place for comparison.")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var compareAccessibilityValue: String {
        let status = isSelected ? String(localized: "Selected") : String(localized: "Not selected")
        return String(localized: "\(status), rating \(item.rating, specifier: "%.1f"), \(item.accessibilityPriceRangeDescription), \(item.alamat)")
    }
        
    private var placeholderView: some View {
        Color.gray.opacity(0.3)
            .frame(height: 130)
            .overlay(ProgressView())
            .accessibilityHidden(true)
    }
}

// MARK: - Sub Component Detail Row
struct DetailRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(LocalizedStringKey(title))
                .font(.subheadline.bold())
                .foregroundColor(.primary)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .padding(.bottom, 6)
    }
}

#Preview("Selected") {
    CompareCard(
        item: Place.dummyData[1],
        isSelected: true,
        onTap: {},
        viewModel: DecideViewModel()
    )
}

#Preview("Not Selected") {
    CompareCard(
        item: Place.dummyData[1],
        isSelected: false,
        onTap: {},
        viewModel: DecideViewModel()
    )
}
