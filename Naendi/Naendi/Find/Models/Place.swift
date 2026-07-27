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
    let rangeHarga: String
    let jamBuka: String
    let typeTempat: String
    let rating: Double
    let jumlahReview: Int
    let vibe: String
    let halal: String
    let halalEvidence: String
    let reviewPositif: String
    let reviewNegatif: String
    
    
    // tambahan
    let imgUrls: String?
    let reportCount: Int
    
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
        case imgUrls = "images"
        case reportCount
        
        
    }
}

// MARK: - Helper / Extension
extension Place {
    /// A spoken decimal value for VoiceOver, e.g. 4.7 becomes
    /// "four point seven" in English or "empat koma tujuh" in Indonesian.
    var accessibilityRatingDescription: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = .current
        formatter.maximumFractionDigits = 1

        return formatter.string(from: NSNumber(value: rating))
            ?? rating.formatted(.number.precision(.fractionLength(1)))
    }

    /// Computed property untuk memparsing string JSON di dalam kolom `jam_buka`
    /// Menghasilkan dictionary dengan format: ["Senin": ["07.00–22.00"], "Selasa": [...]]
    var jamBukaDictionary: [String: [String]]? {
            // Langsung konversi ke Data karena jamBuka dijamin ada nilainya
            guard let data = jamBuka.data(using: .utf8) else {
                return nil
            }
            return try? JSONDecoder().decode([String: [String]].self, from: data)
    }
    
    /// Mengecek apakah tempat ini terkonfirmasi halal
    var isHalalConfirmed: Bool {
        return halal.lowercased() == "yes" || halal.lowercased() == "halal"
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
    
    var jamHariIniFormatted: String {
        guard let jamBukaDict = jamBukaDictionary else { return "Jam Buka Tidak Tersedia" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "id_ID")
        dateFormatter.dateFormat = "EEEE"
        let hariIni = dateFormatter.string(from: Date())
        
        guard let jadwalHariIni = jamBukaDict[hariIni]?.first else { return "Tutup hari ini" }
        
        if jadwalHariIni.lowercased().contains("24 jam") {
            return "Buka 24 jam"
        }
        
        // Memproses string "07.00–22.00"
        // Kita split berdasarkan tanda hubung (gunakan karakter yang sesuai dengan data kamu)
        let komponen = jadwalHariIni.components(separatedBy: CharacterSet(charactersIn: "–-"))
        
        if komponen.count == 2 {
            let jamBuka = komponen[0].trimmingCharacters(in: .whitespaces)
            let jamTutup = komponen[1].trimmingCharacters(in: .whitespaces)
            
            // Format output: "hh.mm - hh.mm"
            return "\(jamBuka) - \(jamTutup)"
        }
        
        return jadwalHariIni // fallback jika format tidak sesuai
    }
    
    var parsedImageUrls: [String] {
            guard let jsonString = imgUrls, let data = jsonString.data(using: .utf8) else {
                return []
            }
            
            // Struct internal untuk menangkap key "image" dari JSON
            struct ImagePayload: Decodable {
                let image: String
            }
            
            do {
                let items = try JSONDecoder().decode([ImagePayload].self, from: data)
                return items.map { $0.image }
            } catch {
                print("Gagal memparsing imgUrls untuk ID \(id): \(error)")
                return []
            }
        }
    
    var imgUrl: String? {
        return parsedImageUrls.first
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
            imgUrls: #"[{"title": "Semua", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}, {"title": "Menu", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmxlwzbPD8mt9qF4VjD54NrhAQ3VGDMzqqmqB_iSAjmGeWn6gMCAKHMqDuxSzs5EpZ-aP2aTNYM3ACdFKd2t2Yoev6BoNT_wF5YiOy6ImyMDn3HcK3-jYIuWEe38U-uK2kBkQQG=w224-h298-k-no"}, {"title": "Makanan & minuman", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkvrSNt78A1OtXFBZ20F2Pgz2DcoiOIKKG4l8xKBjLd4m7KXsNCTiqnqHiouPiucqWKUW-3Tj0U9hZEXzL0FALQijIgDukWEWawBSuNrQUAtpKOM9e0FSbECj4PdrbWYLFk5X9_Pb_OIho=w224-h398-k-no"}, {"title": "Nasi goreng", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWngM2ezo7FZh_MZet5nBSujT6W0uGw_r_I3VcyzAv_UuHs1N_XMM-qSxk1Nclz5HFAMyFFVGdD3dYE9oVwmlZlz6TqW8Q37zP2nnyTxRi8Cp7WwBtRmqIkHegLztLrfBlKJBFI=w224-h398-k-no"}, {"title": "Oleh pemilik", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}]"#,
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
            halalEvidence: "No Pork No Lard",
            reviewPositif: "Porsi martabak dan terang bulannya tuh super big banget, bikin nagih deh pokoknya. Topingnya melimpah, jadi worth it lah.",
            reviewNegatif: "Agak pricey sih buat sebagian orang, tapi ada juga yang bilang porsinya gede jadi lumayan.",
            imgUrls: #"[{"title": "Semua", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}, {"title": "Menu", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmxlwzbPD8mt9qF4VjD54NrhAQ3VGDMzqqmqB_iSAjmGeWn6gMCAKHMqDuxSzs5EpZ-aP2aTNYM3ACdFKd2t2Yoev6BoNT_wF5YiOy6ImyMDn3HcK3-jYIuWEe38U-uK2kBkQQG=w224-h298-k-no"}, {"title": "Makanan & minuman", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkvrSNt78A1OtXFBZ20F2Pgz2DcoiOIKKG4l8xKBjLd4m7KXsNCTiqnqHiouPiucqWKUW-3Tj0U9hZEXzL0FALQijIgDukWEWawBSuNrQUAtpKOM9e0FSbECj4PdrbWYLFk5X9_Pb_OIho=w224-h398-k-no"}, {"title": "Nasi goreng", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWngM2ezo7FZh_MZet5nBSujT6W0uGw_r_I3VcyzAv_UuHs1N_XMM-qSxk1Nclz5HFAMyFFVGdD3dYE9oVwmlZlz6TqW8Q37zP2nnyTxRi8Cp7WwBtRmqIkHegLztLrfBlKJBFI=w224-h398-k-no"}, {"title": "Oleh pemilik", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}]"#,
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
            imgUrls: #"[{"title": "Semua", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}, {"title": "Menu", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmxlwzbPD8mt9qF4VjD54NrhAQ3VGDMzqqmqB_iSAjmGeWn6gMCAKHMqDuxSzs5EpZ-aP2aTNYM3ACdFKd2t2Yoev6BoNT_wF5YiOy6ImyMDn3HcK3-jYIuWEe38U-uK2kBkQQG=w224-h298-k-no"}, {"title": "Makanan & minuman", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkvrSNt78A1OtXFBZ20F2Pgz2DcoiOIKKG4l8xKBjLd4m7KXsNCTiqnqHiouPiucqWKUW-3Tj0U9hZEXzL0FALQijIgDukWEWawBSuNrQUAtpKOM9e0FSbECj4PdrbWYLFk5X9_Pb_OIho=w224-h398-k-no"}, {"title": "Nasi goreng", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWngM2ezo7FZh_MZet5nBSujT6W0uGw_r_I3VcyzAv_UuHs1N_XMM-qSxk1Nclz5HFAMyFFVGdD3dYE9oVwmlZlz6TqW8Q37zP2nnyTxRi8Cp7WwBtRmqIkHegLztLrfBlKJBFI=w224-h398-k-no"}, {"title": "Oleh pemilik", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}]"#,
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
            imgUrls: #"[{"title": "Semua", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}, {"title": "Menu", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmxlwzbPD8mt9qF4VjD54NrhAQ3VGDMzqqmqB_iSAjmGeWn6gMCAKHMqDuxSzs5EpZ-aP2aTNYM3ACdFKd2t2Yoev6BoNT_wF5YiOy6ImyMDn3HcK3-jYIuWEe38U-uK2kBkQQG=w224-h298-k-no"}, {"title": "Makanan & minuman", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkvrSNt78A1OtXFBZ20F2Pgz2DcoiOIKKG4l8xKBjLd4m7KXsNCTiqnqHiouPiucqWKUW-3Tj0U9hZEXzL0FALQijIgDukWEWawBSuNrQUAtpKOM9e0FSbECj4PdrbWYLFk5X9_Pb_OIho=w224-h398-k-no"}, {"title": "Nasi goreng", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWngM2ezo7FZh_MZet5nBSujT6W0uGw_r_I3VcyzAv_UuHs1N_XMM-qSxk1Nclz5HFAMyFFVGdD3dYE9oVwmlZlz6TqW8Q37zP2nnyTxRi8Cp7WwBtRmqIkHegLztLrfBlKJBFI=w224-h398-k-no"}, {"title": "Oleh pemilik", "image": "https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnNalJT0yVWoj17g7uVGbXqOwPPMd4Jrp6PhkdZPiNCY_pozkVsCYw_8qkT_U0fuNic9LnqrppvgsH1jeBfOogTMDwKY8cVIWRVsT-WWw3PQcAmH64U5LMWqQ3z7kDD4SE_bGOBww=w224-h298-k-no"}]"#,
            reportCount: 0
        )
    ]

}
