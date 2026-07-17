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

    init(name: String, halalStatusRaw: String) {
        self.name = name
        self.halalStatusRaw = halalStatusRaw
    }
}

extension PlaceEntity {
    func toPlace() -> Place {
        Place(
            name: name,
            halalStatus: HalalStatus(rawValue: halalStatusRaw) ?? .unknown
        )
    }

    convenience init(from place: Place) {
        self.init(
            name: place.name,
            halalStatusRaw: place.halalStatus.rawValue
        )
    }
}
