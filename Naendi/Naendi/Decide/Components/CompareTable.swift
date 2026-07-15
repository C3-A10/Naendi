//
//  CompareTable.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import SwiftUI

struct CompareTable: View {
    var body: some View {
        
    }
}


// MARK: - Component Card
struct CompareCard: View {
    let item: Place
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Bagian Atas
            ZStack(alignment: .topTrailing) {

                if let imgUrlString = item.imgUrl, !imgUrlString.isEmpty, let url = URL(string: imgUrlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 180)
                                .clipped()
                                .cornerRadius(24)
                        case .failure, .empty:
                            placeholderView
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    placeholderView
                }
                
                // Grup Badge
                HStack(spacing: -8) {
                    Text("\(item.reportCount)")                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(Color(red: 0.61, green: 0.80, blue: 0.22))
                        .clipShape(Circle())
                        .zIndex(1)
                    
                    // Badge Putih Tanda Seru
                    Image(systemName: "exclamationmark.bubble.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.white)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .padding([.top, .trailing], 12)
            }
            
            // Bagian Bawah
            VStack(alignment: .leading, spacing: 12) {
                // Judul Tempat / Cafe
                Text(item.nama)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Rating & Tags Row
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(red: 0.95, green: 0.76, blue: 0.29))
                            .font(.system(size: 18))
                        
                        Text(String(format: "%.1f", item.rating))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    // Tag 1: Vibe / Tipe Tempat
                    Text(item.vibe)
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.82, green: 0.94, blue: 0.89))
                        .foregroundColor(Color(red: 0.22, green: 0.55, blue: 0.42))
                        .cornerRadius(12)
                    
                    // Tag 2: Halal (Jika "yes")
                    if item.halal.lowercased() == "yes" {
                        Text("Halal")
                            .font(.system(size: 11, weight: .bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.98, green: 0.84, blue: 0.53))
                            .foregroundColor(Color(red: 0.72, green: 0.44, blue: 0.16))
                            .cornerRadius(12)
                    }
                }
                
                // Info Jarak Kustom / Placeholder teks area
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(item.typeTempat)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black.opacity(0.7))
                    Text("Terhitung dari lokasi Anda saat ini")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .cornerRadius(32)
    }
    
    // View Placeholder saat gambar loading/gagal
    private var placeholderView: some View {
        Color.gray.opacity(0.3)
            .frame(height: 180)
            .cornerRadius(24)
            .overlay(
                ProgressView()
            )
    }
}



// MARK: - PREVIEW
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            CompareCard(item: Place(
                id: "ChIJZWbUpcD71y0RasSgwAJ7TUw_2",
                nama: "Holden Martabak & Terang Bulan",
                alamat: "Jl. Kalidami VII No.2, RT.003/RW.10, Mojo, Kec. Gubeng, Surabaya, Jawa Timur 60285, Indonesia",
                latitude: -7.2760381,
                longitude: 112.7583921,
                rangeHarga: "Di bawah Rp 25 rb",
                jamBuka: #"{"Senin": ["15.00–23.00"], "Selasa": ["15.00–23.00"], "Rabu": ["15.00–23.00"], "Kamis": ["15.00–23.00"], "Jumat": ["15.00–23.00"], "Sabtu": ["15.00–23.00"], "Minggu": ["15.00–23.00"]}"#,
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
            ))
        }
    }
}
