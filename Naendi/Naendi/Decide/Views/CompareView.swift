//
//  CompareView.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//
import SwiftUI

struct CompareView: View {
    @Environment(\.dismiss) var dismiss
    
    let placeA: Place
    let placeB: Place
    
    var body: some View {
        
        VStack(spacing: 0) {
            // TOP NAVIGATION BAR ---
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                Text("Compare")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Color.clear
                    .frame(width: 40, height: 40)
            }
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.horizontal, 24)
            
            // Compare Table
            CompareTable(placeA: placeA, placeB: placeB)
            
            // Button
            CustomActionButton(
                text: "Choose this location",
                backgroundColor: .white,
                textColor: .black,
                action: {
                    print("Location Selected!")
                }
            )
            .padding(.top, 16)
            .padding(.bottom, 12)
            .padding(.horizontal, 24)
        }
        Spacer()
    }
}

#Preview {
    CompareView(placeA: Place(
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
        reportCount: 12))
}

