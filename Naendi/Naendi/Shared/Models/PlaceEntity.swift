//
//  PlaceEntity.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

import SwiftData

@Model
final class PlaceEntity {
    var id: String
    var nama: String
    var alamat: String
    var latitude: Double
    var longitude: Double
    var rangeHarga: String
    var jamBuka: String
    var typeTempat: String
    var rating: Double
    var jumlahReview: Int
    var vibe: String
    var halal: String
    var halalEvidence: String
    var reviewPositif: String
    var reviewNegatif: String
    var imgUrls: String?
    var reportCount: Int

    init(
        id: String,
        nama: String,
        alamat: String,
        latitude: Double,
        longitude: Double,
        rangeHarga: String,
        jamBuka: String,
        typeTempat: String,
        rating: Double,
        jumlahReview: Int,
        vibe: String,
        halal: String,
        halalEvidence: String,
        reviewPositif: String,
        reviewNegatif: String,
        imgUrls: String?,
        reportCount: Int
    ) {
        self.id = id
        self.nama = nama
        self.alamat = alamat
        self.latitude = latitude
        self.longitude = longitude
        self.rangeHarga = rangeHarga
        self.jamBuka = jamBuka
        self.typeTempat = typeTempat
        self.rating = rating
        self.jumlahReview = jumlahReview
        self.vibe = vibe
        self.halal = halal
        self.halalEvidence = halalEvidence
        self.reviewPositif = reviewPositif
        self.reviewNegatif = reviewNegatif
        self.imgUrls = imgUrls
        self.reportCount = reportCount
    }
}

extension PlaceEntity {
    func toPlace() -> Place {
        Place(
            id: id,
            nama: nama,
            alamat: alamat,
            latitude: latitude,
            longitude: longitude,
            rangeHarga: rangeHarga,
            jamBuka: jamBuka,
            typeTempat: typeTempat,
            rating: rating,
            jumlahReview: jumlahReview,
            vibe: vibe,
            halal: halal,
            halalEvidence: halalEvidence,
            reviewPositif: reviewPositif,
            reviewNegatif: reviewNegatif,
            imgUrls: imgUrls,
            reportCount: reportCount
        )
    }

    convenience init(from place: Place) {
        self.init(
            id: place.id,
            nama: place.nama,
            alamat: place.alamat,
            latitude: place.latitude,
            longitude: place.longitude,
            rangeHarga: place.rangeHarga,
            jamBuka: place.jamBuka,
            typeTempat: place.typeTempat,
            rating: place.rating,
            jumlahReview: place.jumlahReview,
            vibe: place.vibe,
            halal: place.halal,
            halalEvidence: place.halalEvidence,
            reviewPositif: place.reviewPositif,
            reviewNegatif: place.reviewNegatif,
            imgUrls: place.imgUrls,
            reportCount: place.reportCount
        )
    }
}
