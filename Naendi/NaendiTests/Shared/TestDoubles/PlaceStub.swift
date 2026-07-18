//
//  PlaceStub.swift
//  NaendiTests
//
//  Test factory for building the app's Place model with sensible defaults,
//  so tests only spell out the fields they care about.
//

@testable import Naendi

extension Place {
    static func stub(
        id: String = "stub-id",
        nama: String = "Test Place",
        alamat: String = "",
        latitude: Double = 0,
        longitude: Double = 0,
        rangeHarga: String = "",
        jamBuka: String = "",
        typeTempat: String = "",
        rating: Double = 0,
        jumlahReview: Int = 0,
        vibe: String = "",
        halal: String = "",
        halalEvidence: String = "",
        reviewPositif: String = "",
        reviewNegatif: String = "",
        imgUrl: String? = nil,
        reportCount: Int = 0
    ) -> Place {
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
            imgUrl: imgUrl,
            reportCount: reportCount
        )
    }
}
