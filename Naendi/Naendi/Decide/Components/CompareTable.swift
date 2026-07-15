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
        HStack(alignment: .top, spacing: 12) {
            CompareCard(item: placeA)
            CompareCard(item: placeB)
        }
        .padding(.horizontal, 16) // Padding luar kanan-kiri layar utama
    }
}

// MARK: - Component Card
struct CompareCard: View {
    let item: Place
    
    var body: some View {
        // PENTING: Struktur diubah agar satu kontainer utama mengontrol segalanya
        VStack(alignment: .leading, spacing: 0) {
            
            // 1. Bagian Atas: Gambar & Badge Kontainer
            ZStack(alignment: .topTrailing) {
                if let imgUrlString = item.imgUrl, !imgUrlString.isEmpty, let url = URL(string: imgUrlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 130) // Tinggi gambar seragam
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
                
                // Grup Badge (Green Count + White Bubble)
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
                        .foregroundColor(Color.white)
                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                }
                .padding([.top, .trailing], 10)
            }
            
            // 2. Bagian Bawah: Seluruh Informasi Detail Teks dimasukkan ke dalam satu blok padding
            VStack(alignment: .leading, spacing: 10) {
                
                // Judul Tempat / Cafe (Aman di dalam padding kontainer)
                Text(item.nama)
                    .font(.system(size: 20, weight: .bold)) // Ukuran proporsional untuk 2 kolom
                    .foregroundColor(.black)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .frame(height: 48, alignment: .topLeading) // Mengunci tinggi agar card kiri & kanan selalu sejajar presisi
                
                // Ratings & Tags Row
                HStack(spacing: 6) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color(red: 0.95, green: 0.76, blue: 0.29))
                            .font(.system(size: 15))
                        
                        Text(String(format: "%.1f", item.rating))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    // Tag Vibe
                    Text(item.vibe)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.82, green: 0.94, blue: 0.89))
                        .foregroundColor(Color(red: 0.22, green: 0.55, blue: 0.42))
                        .cornerRadius(8)
                    
                    // Tag Halal
                    if item.halal.lowercased() == "yes" {
                        Text("Halal")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.98, green: 0.84, blue: 0.53))
                            .foregroundColor(Color(red: 0.72, green: 0.44, blue: 0.16))
                            .cornerRadius(8)
                    }
                }
                
                // Info Jarak Kustom
                VStack(alignment: .leading, spacing: 2) {
                    Text("0,9 KM dari lokasi Anda saat ini")
                    Text("0,1 KM dari GWalk")
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                
                Divider()
                    .padding(.vertical, 2)
                
                // Baris Informasi Detail Tambahan
                DetailRowView(title: "Address", value: item.alamat)
                DetailRowView(title: "Price Range", value: item.rangeHarga)
                DetailRowView(title: "Operating Hour", value: item.jamBuka)
            }
            .padding(.all, 14) // Menggeser seluruh elemen teks ke tengah secara merata dan aman
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Membagi 50/50 ruang layar secara adil
        .background(Color(red: 0.95, green: 0.95, blue: 0.95)) // Background untuk SATU KESATUAN Kartu
        .cornerRadius(24) // Efek melengkung rapi membungkus gambar dan teks sekaligus
    }
    
    // View Placeholder saat gambar loading/gagal (Tinggi disamakan 130 agar tidak jumping)
    private var placeholderView: some View {
        Color.gray.opacity(0.3)
            .frame(height: 130)
            .overlay(ProgressView())
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
    
    
    
    // MARK: - PREVIEW
    #Preview {
        CompareTable(placeA: Place(
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
        ), placeB: Place(
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
        ))
        
    }
