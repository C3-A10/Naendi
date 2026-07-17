//
//  Place.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Foundation

enum HalalStatus: String {
    case halal
    case nonHalal
    case unknown
}

struct Place: Equatable {
    let name: String
    let halalStatus: HalalStatus
    let address: String?
    let halalEvidence: String?
    let images: String?
    let openingHours: String?
    let reviewCount: Int?
    let latitude: Double?
    let longitude: Double?
    let menuLink: String?
    let placeID: String?
    let priceRange: String?
    let rating: Double?
    let negativeReview: String?
    let positiveReview: String?
    let thumbnail: String?
    let placeType: String?
    let vibe: String?

    init(
        name: String,
        halalStatus: HalalStatus,
        address: String? = nil,
        halalEvidence: String? = nil,
        images: String? = nil,
        openingHours: String? = nil,
        reviewCount: Int? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        menuLink: String? = nil,
        placeID: String? = nil,
        priceRange: String? = nil,
        rating: Double? = nil,
        negativeReview: String? = nil,
        positiveReview: String? = nil,
        thumbnail: String? = nil,
        placeType: String? = nil,
        vibe: String? = nil
    ) {
        self.name = name
        self.halalStatus = halalStatus
        self.address = address
        self.halalEvidence = halalEvidence
        self.images = images
        self.openingHours = openingHours
        self.reviewCount = reviewCount
        self.latitude = latitude
        self.longitude = longitude
        self.menuLink = menuLink
        self.placeID = placeID
        self.priceRange = priceRange
        self.rating = rating
        self.negativeReview = negativeReview
        self.positiveReview = positiveReview
        self.thumbnail = thumbnail
        self.placeType = placeType
        self.vibe = vibe
    }
}
