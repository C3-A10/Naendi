//
//  PlaceEntity.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

import SwiftData

@Model
final class PlaceEntity {
    var name: String
    var halalStatusRaw: String
    var address: String?
    var halalEvidence: String?
    var images: String?
    var openingHours: String?
    var reviewCount: Int?
    var latitude: Double?
    var longitude: Double?
    var menuLink: String?
    var placeID: String?
    var priceRange: String?
    var rating: Double?
    var negativeReview: String?
    var positiveReview: String?
    var thumbnail: String?
    var placeType: String?
    var vibe: String?

    init(
        name: String,
        halalStatusRaw: String,
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
        self.halalStatusRaw = halalStatusRaw
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

extension PlaceEntity {
    func toPlace() -> Place {
        Place(
            name: name,
            halalStatus: HalalStatus(rawValue: halalStatusRaw) ?? .unknown,
            address: address,
            halalEvidence: halalEvidence,
            images: images,
            openingHours: openingHours,
            reviewCount: reviewCount,
            latitude: latitude,
            longitude: longitude,
            menuLink: menuLink,
            placeID: placeID,
            priceRange: priceRange,
            rating: rating,
            negativeReview: negativeReview,
            positiveReview: positiveReview,
            thumbnail: thumbnail,
            placeType: placeType,
            vibe: vibe
        )
    }

    convenience init(from place: Place) {
        self.init(
            name: place.name,
            halalStatusRaw: place.halalStatus.rawValue,
            address: place.address,
            halalEvidence: place.halalEvidence,
            images: place.images,
            openingHours: place.openingHours,
            reviewCount: place.reviewCount,
            latitude: place.latitude,
            longitude: place.longitude,
            menuLink: place.menuLink,
            placeID: place.placeID,
            priceRange: place.priceRange,
            rating: place.rating,
            negativeReview: place.negativeReview,
            positiveReview: place.positiveReview,
            thumbnail: place.thumbnail,
            placeType: place.placeType,
            vibe: place.vibe
        )
    }
}
