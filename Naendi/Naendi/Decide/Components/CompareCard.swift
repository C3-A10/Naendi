//
//  ComponentCard.swift
//  Naendi
//
//  Created by Bryan Samuel on 16/07/26.
//
import SwiftUI

// MARK: - Compare Card
struct CompareCard: View {
    let item: Place
    let isSelected: Bool
    let onTap: () -> Void
    let viewModel: DecideViewModel
    
    
    var body: some View {
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
                        
                    } else {
                        placeholderView
                    }
                    
                    HStack(spacing: -6) {
                        Text("\(item.reportCount)")
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
                    .padding(.top, 10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(item.nama)
                        .font(.system(size: 16, weight: .bold))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 10)
                    
                    BrickLayout(spacing: 6) {
                        
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .foregroundColor(Color(red: 0.95, green: 0.76, blue: 0.29))
                                .font(.system(size: 13))
                            
                            Text(String(format: "%.1f", item.rating))
                                .font(.system(size: 12, weight: .semibold))
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
                            Text("\(viewModel.calculateDistance(to: item)) dari lokasi Anda saat ini.")
                    }
                    .font(.system(size: 12))
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
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
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
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
        
        private var placeholderView: some View {
            Color.gray.opacity(0.3)
                .frame(height: 130)
                .overlay(ProgressView())
        }

// MARK: - Sub Component Detail Row
struct DetailRowView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
            
            Text(value)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
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
