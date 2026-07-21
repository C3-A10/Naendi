//
//  PlaceCardExpandInformationView.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 15/07/26.
//

import SwiftUI

struct PlaceCardExpandInfoView: View {
    let place: Place
    let isChooseThisLocationBtnVisible: Bool
    @Binding var isExpanded: Bool
    @Binding var selectedPlace: Place?
    
    private var reviewItems: [(title: String, text: String, isPositive: Bool)] {
        var items: [(String, String, Bool)] = []
        items.append(("What People Love", place.reviewPositif, true))
        items.append(("Things to Consider", place.reviewNegatif, false))
        return items
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Header nama - rating - jml rating - pil2 - tombol close
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    
                    // Nama tempat
                    Text(place.nama)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    // Rating - jml rating - range harga
                    HStack(spacing: 6) {
                        
                        // icon bintang
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                        
                        // rating
                        Text("\(place.rating, specifier: "%.1f")")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("•").foregroundColor(.secondary)
                        
                        // jml review
                        Text("(\(place.jumlahReview))").font(.system(size: 13)).foregroundColor(.secondary)
                        Text("•").foregroundColor(.secondary)
                        
                        // range harga
                        Text(place.rangeHarga).font(.system(size: 13, weight: .regular)).foregroundColor(.secondary).lineLimit(1)
                    }
                    
                    // Badges Type - Vibe - Halal
                    HStack(spacing: 6) {
                        TagView(text: place.typeTempat, backgroundColor: Color.orange.opacity(0.15), textColor: Color(red: 0.90, green: 0.45, blue: 0.10))
                        
                        TagView(text: place.vibe, backgroundColor: Color.blue.opacity(0.15), textColor: Color(red: 0.10, green: 0.45, blue: 0.90))
                        
                        if place.isHalalConfirmed {
                            TagView(text: "Halal", backgroundColor: Color.green.opacity(0.15), textColor: Color(red: 0.15, green: 0.65, blue: 0.30))
                        } else if place.halal.lowercased() == "non-halal" {
                            TagView(text: "Non-Halal", backgroundColor: Color(red: 0.98, green: 0.85, blue: 0.85),
                                    textColor: Color(red: 0.75, green: 0.22, blue: 0.22))
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(4)
            }
            .padding(.horizontal, 12)
            .onTapGesture {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    isExpanded = false
                }
            }
            .padding(.bottom, 8)
            
            Divider()
                .padding(.vertical, 2)
            
            DetailRowView(title: "Location", value: place.alamat)
                .padding(.horizontal, 12)
            
            Divider()
                .padding(.vertical, 2)
            
            DetailRowView(title: "Operational Hours", value: "\(place.jamHariIniFormatted) WIB")
                .padding(.horizontal, 12)
            
            Divider()
                .padding(.vertical, 2)
            
            VStack (alignment: .leading, spacing: 2) {
                Text("AI Reviews Summary")
                    .font(.system(size: 14, weight: .bold))
                    .lineLimit(2)
                
                if !reviewItems.isEmpty {
                    ForEach(0..<reviewItems.count, id: \.self) { index in
                        let item = reviewItems[index]
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(item.isPositive ? .green : .red)
                            
                            Text(item.text)
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .padding(.horizontal, 12)
            
            if isChooseThisLocationBtnVisible {
                Divider()
                    .padding(.vertical, 2)
                CustomActionButton(text: "Choose this location", backgroundColor: Color("color_green"), textColor: .black) {
                    selectedPlace = place
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
    }
}

#Preview {
    PlaceCardExpandInfoView(
        place: Place.dummyData[0],
        isChooseThisLocationBtnVisible: true,
        isExpanded: .constant(false),
        selectedPlace: .constant(nil)
    )
}
