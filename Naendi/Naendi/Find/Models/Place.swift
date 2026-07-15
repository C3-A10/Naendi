//
//  Place.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import Foundation
import SwiftData


struct Place: Identifiable, Codable, Hashable {
    let id: String
    let nama: String
    let alamat: String
    let latitude: Double
    let longitude: Double
    let rangeHarga: String?
    let jamBuka: String?
    let typeTempat: String
    let rating: Double
    let jumlahReview: Int
    let vibe: String?
    let halal: String?
    let halalEvidence: String?
    let reviewPositif: String?
    let reviewNegatif: String?
    
    // tambahan
    let imgUrl: String?
    let reportCount: Int?
    
    // Mapping dari snake_case (CSV) ke camelCase (Swift)
    enum CodingKeys: String, CodingKey {
        case id = "place_id"
        case nama
        case alamat
        case latitude
        case longitude
        case rangeHarga = "range_harga"
        case jamBuka = "jam_buka"
        case typeTempat = "type_tempat"
        case rating
        case jumlahReview = "jumlah_review"
        case vibe
        case halal
        case halalEvidence = "halal_evidence"
        case reviewPositif = "review_positif"
        case reviewNegatif = "review_negatif"
        case imgUrl
        case reportCount
        
    }
}

// MARK: - Helper / Extension
extension Place {
    /// Computed property untuk memparsing string JSON di dalam kolom `jam_buka`
    /// Menghasilkan dictionary dengan format: ["Senin": ["07.00–22.00"], "Selasa": [...]]
    var jamBukaDictionary: [String: [String]]? {
        guard let jamBukaString = jamBuka,
              let data = jamBukaString.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode([String: [String]].self, from: data)
    }
    
    /// Mengecek apakah tempat ini terkonfirmasi halal
    var isHalalConfirmed: Bool {
        return halal?.lowercased() == "yes" || halal?.lowercased() == "halal"
    }
    
    var statusJamBukaFormatted: String {
        guard let jamBukaDict = jamBukaDictionary else { return "Jam Buka Tidak Tersedia" }
        
        // Mengambil hari ini dalam bahasa Indonesia
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "id_ID")
        dateFormatter.dateFormat = "EEEE"
        let hariIni = dateFormatter.string(from: Date())
        
        if let jadwalHariIni = jamBukaDict[hariIni]?.first {
            if jadwalHariIni.lowercased().contains("24 jam") {
                return "Buka 24 jam"
            }
            // Mengambil jam tutup dari format "07.00–22.00"
            let komponen = jadwalHariIni.components(separatedBy: "–")
            if let jamTutup = komponen.last, !jamTutup.isEmpty {
                return "Buka sampai jam \(jamTutup)"
            }
        }
        return "Buka hari ini"
    }
    
    static let dummyData: [Place] = [
        // 1. Mie Mapan
        Place(
            id: "ChIJl_j1m6v71y0RzcEBmBCj8tg",
            nama: "Mie Mapan - Barata Jaya",
            alamat: "Jl. Barata Jaya XIX No.51, Baratajaya, Kec. Gubeng, Surabaya, Jawa Timur 60284, Indonesia",
            latitude: -7.302051,
            longitude: 112.7594761,
            rangeHarga: "Rp 25–50 rb",
            jamBuka: #"{"Senin": ["07.00–22.00"], "Selasa": ["07.00–22.00"], "Rabu": ["07.00–22.00"], "Kamis": ["07.00–22.00"], "Jumat": ["07.00–22.00"], "Sabtu": ["07.00–22.00"], "Minggu": ["07.00–22.00"]}"#,
            typeTempat: "Restaurant",
            rating: 4.5,
            jumlahReview: 3935,
            vibe: "Balanced",
            halal: "yes",
            halalEvidence: "Sertifikat Halal MUI",
            reviewPositif: "Mie Mapan ini emang jadi legend di Surabaya, rasanya konsisten enak dari dulu sampai sekarang. Pelayanan di sini juga jempolan, cepet, ramah, dan tempatnya bersih.",
            reviewNegatif: "Beberapa pengunjung merasa AC di sini kurang dingin, bikin gerah pas cuaca Surabaya lagi panas.",
            imgUrl: "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?q=80&w=800&auto=format&fit=crop",
            reportCount: 0
        ),
        
        // 2. Volcano Terang Bulan
        Place(
            id: "ChIJZWbUpcD71y0RasSgwAJ7TUw_1",
            nama: "Volcano Terang Bulan Dan Martabak",
            alamat: "Jl. Jaksa Agung Suprapto No.31, Ketabang, Kec. Genteng, Surabaya, Jawa Timur 60272, Indonesia",
            latitude: -7.2576642,
            longitude: 112.7463023,
            rangeHarga: "Rp 50–75 rb",
            jamBuka: #"{"Senin": ["16.00–22.00"], "Selasa": ["16.00–22.00"], "Rabu": ["16.00–22.00"], "Kamis": ["16.00–22.00"], "Jumat": ["16.00–22.00"], "Sabtu": ["16.00–22.00"], "Minggu": ["16.00–22.00"]}"#,
            typeTempat: "Restaurant",
            rating: 4.4,
            jumlahReview: 20,
            vibe: "Lively",
            halal: "unknown",
            halalEvidence: nil,
            reviewPositif: "Porsi martabak dan terang bulannya tuh super big banget, bikin nagih deh pokoknya. Topingnya melimpah, jadi worth it lah.",
            reviewNegatif: "Agak pricey sih buat sebagian orang, tapi ada juga yang bilang porsinya gede jadi lumayan.",
            imgUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=800&auto=format&fit=crop",
            reportCount: 0
        ),
        
        // 3. Holden Martabak
        Place(
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
            reportCount: 0
        ),
        
        // 4. Soto Ayam Ambengan
        Place(
            id: "ChIJZWbUpcD71y0RasSgwAJ7TUw_3",
            nama: "Soto Ayam Ambengan Pak Sadi",
            alamat: "Jl. Ambengan No.3A, Ketabang, Kec. Genteng, Surabaya, Jawa Timur 60272, Indonesia",
            latitude: -7.254123,
            longitude: 112.748912,
            rangeHarga: "Rp 25–50 rb",
            jamBuka: #"{"Senin": ["06.30–21.30"], "Selasa": ["06.30–21.30"], "Rabu": ["06.30–21.30"], "Kamis": ["06.30–21.30"], "Jumat": ["06.30–21.30"], "Sabtu": ["06.30–21.30"], "Minggu": ["06.30–21.30"]}"#,
            typeTempat: "Restaurant",
            rating: 4.6,
            jumlahReview: 5120,
            vibe: "Traditional",
            halal: "yes",
            halalEvidence: "Sertifikat Halal MUI",
            reviewPositif: "Kuah sotonya sangat gurih dan kental, apalagi ditambah bubuk koya khasnya yang bikin rasa makin mantap. Daging ayamnya melimpah.",
            reviewNegatif: "Kalau jam makan siang sangat ramai sampai susah cari meja kosong.",
            imgUrl: "https://images.unsplash.com/photo-1572656631137-7935297eff55?q=80&w=800&auto=format&fit=crop",
            reportCount: 0
        )
    ]

}

