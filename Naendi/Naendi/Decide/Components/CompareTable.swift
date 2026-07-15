//
//  CompareTable.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import SwiftUI

// MARK: - Compare Table
struct CompareTable: View {
    let placeA: Place
    let placeB: Place
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            CompareCard(item: placeA)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CompareCard(item: placeB)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.horizontal, 16)
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Component Card
struct CompareCard: View {
    let item: Place
    
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
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 130)
                                .clipped()
                            
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
                    .padding(.trailing, 4)
                    
                    TagView(
                        text: item.vibe,
                        backgroundColor: Color(red: 0.82, green: 0.94, blue: 0.89),
                        textColor: Color(red: 0.22, green: 0.55, blue: 0.42)
                    )
                    
                    if item.halal.lowercased() == "yes" {
                        TagView(
                            text: "Halal",
                            backgroundColor: Color(red: 0.98, green: 0.84, blue: 0.53),
                            textColor: Color(red: 0.72, green: 0.44, blue: 0.16)
                        )
                    } else {
                        TagView(
                            text: "Non-Halal",
                            backgroundColor: Color(red: 0.98, green: 0.85, blue: 0.85),
                            textColor: Color(red: 0.75, green: 0.22, blue: 0.22)
                        )
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("0,9 KM dari lokasi Anda saat ini")
                    Text("0,1 KM dari GWalk")
                }
                .font(.system(size: 12))
                .foregroundColor(.gray)
                
                Divider()
                    .padding(.vertical, 4)
                
                DetailRowView(title: "Address", value: item.alamat)
                DetailRowView(title: "Price Range", value: item.rangeHarga)
                DetailRowView(title: "Operating Hour", value: item.jamBuka)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 16)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private var placeholderView: some View {
        Color.gray.opacity(0.3)
            .frame(height: 130)
            .overlay(ProgressView())
    }
    
    // MARK: - Sub Component Tags
    struct TagView: View {
        let text: String
        let backgroundColor: Color
        let textColor: Color
        
        var body: some View {
            Text(text)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(8)
        }
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
}

// MARK: - PREVIEW
#Preview {
    CompareTable(
        placeA: Place(
            id: "ChIJZWbUpcD71y0RasSgwAJ7TUw_2",
            nama: "Holden Martabak & Terang Bulan",
            alamat: "Jl. Kalidami VII No.2, RT.003/RW.10, Mojo, Kec. Gubeng, Surabaya, Jawa Timur 60285, Indonesia",
            latitude: -7.2760381,
            longitude: 112.7583921,
            rangeHarga: "Di bawah Rp 25 rb",
            jamBuka: "12.00-23.00",
            typeTempat: "Street Food",
            rating: 4.2,
            jumlahReview: 115,
            vibe: "Casual",
            halal: "yes",
            halalEvidence: "No Pork No Lard",
            reviewPositif: "Harga sangat terjangkau untuk mahasiswa, rasanya pas tidak terlalu manis dan adonannya lembut.",
            reviewNegatif: "Antrean lumayan panjang kalau malam minggu dan tempat parkirnya agak sempit untuk mobil.",
            imgUrl: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=800&auto=format&fit=crop",
            reportCount: 12
        ),
        placeB: Place(
            id: "ChIJZWbUpcD71y0RasSgwAJ7TUw_2",
            nama: "Kopi Joyo",
            alamat: "Jl. Kalidami VII No.2, RT.003/RW.10, Mojo, Kec. Gubeng, Surabaya, Jawa Timur 60285, Indonesia",
            latitude: -7.2760381,
            longitude: 112.7583921,
            rangeHarga: "Di bawah Rp 25 rb",
            jamBuka: "12.00-23.00",
            typeTempat: "Street Food",
            rating: 4.2,
            jumlahReview: 115,
            vibe: "Casual",
            halal: "no",
            halalEvidence: "No Pork No Lard",
            reviewPositif: "Harga sangat terjangkau untuk mahasiswa, rasanya pas tidak terlalu manis dan adonannya lembut.",
            reviewNegatif: "Antrean lumayan panjang kalau malam minggu dan tempat parkirnya agak sempit untuk mobil.",
            imgUrl: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=800&auto=format&fit=crop",
            reportCount: 12
        )
    )
}
