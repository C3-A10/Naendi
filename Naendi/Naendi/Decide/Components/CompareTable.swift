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


struct CompareCard: View {
    let item: Place
    var body: some View {
        
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
                imgUrl: "https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=800&auto=format&fit=crop"
            ))
        }
    }
}
