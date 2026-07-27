//
//  PlaceType.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 26/07/26.
//

import Foundation

enum PlaceType: String, CaseIterable {
    case any = "Any"
    case restaurant = "Restaurant"
    case cafe = "Cafe"
    case warkop = "Warkop"
    case pkl = "PKL"
    case drinks = "Drinks"
    case bakery = "Bakery"

    var description: String {
        switch self {
        case .any:
            return String(localized: "Any type of place.")
        case .restaurant:
            return String(localized: "Full service dining with a complete menu.")
        case .cafe:
            return String(localized: "Relaxed setting for coffee and light meals.")
        case .warkop:
            return String(localized: "Traditional coffee stall with a casual vibe.")
        case .pkl:
            return String(localized: "Street food vendors with local delicacies.")
        case .drinks:
            return String(localized: "Places primarily serving beverages.")
        case .bakery:
            return String(localized: "Shops selling fresh breads and pastries.")
        }
    }
}
