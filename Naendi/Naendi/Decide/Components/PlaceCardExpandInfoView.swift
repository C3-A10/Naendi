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
        items.append((String(localized: "What People Love"), place.reviewPositif, true))
        items.append((String(localized: "Things to Consider"), place.reviewNegatif, false))
        return items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Header nama - rating - jml rating - pil2 - tombol close
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {

                    // Nama tempat
                    Text(place.nama)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    // Rating - jml rating - range harga
                    HStack(spacing: 6) {

                        // icon bintang
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.body)
                            .accessibilityHidden(true)

                        // rating
                        Text("\(place.rating, specifier: "%.1f")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .accessibilityLabel("Rating \(place.accessibilityRatingDescription)")

                        Text("•").foregroundColor(.secondary).font(.caption)

                        // jml review
                        Text("(\(place.jumlahReview))").font(.caption).foregroundColor(.secondary)
                        Text("•").foregroundColor(.secondary).font(.caption)

                        // range harga
                        Text(place.rangeHarga).font(.caption).foregroundColor(.secondary).lineLimit(1)
                    }

                    // Badges Type - Vibe - Halal
                    HStack(spacing: 6) {
                        TagView(text: place.typeTempat, backgroundColor: Color.orange.opacity(0.15), textColor: Color(red: 0.90, green: 0.45, blue: 0.10))

                        TagView(text: place.vibe, backgroundColor: Color.blue.opacity(0.15), textColor: Color(red: 0.10, green: 0.45, blue: 0.90))

                        switch place.halal.lowercased() {
                            case "halal":
                                TagView(text: "Halal", backgroundColor: Color.green.opacity(0.15), textColor: Color(red: 0.15, green: 0.65, blue: 0.30))
                            case "non-halal":
                                TagView(text: "Nonhalal", backgroundColor: Color(red: 0.98, green: 0.85, blue: 0.85),
                                        textColor: Color(red: 0.75, green: 0.22, blue: 0.22))
                            default:
                                EmptyView()
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.title3).fontWeight(.bold)
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
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .lineLimit(2)

                if !reviewItems.isEmpty {
                    ForEach(0..<reviewItems.count, id: \.self) { index in
                        let item = reviewItems[index]
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(item.isPositive ? .green : .red)

                            Text(item.text)
                                .font(.caption)
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
