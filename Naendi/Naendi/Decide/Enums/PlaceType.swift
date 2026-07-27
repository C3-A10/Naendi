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
            return String(localized: "Includes all place types.")
        case .restaurant:
            return String(localized: "Places for dining, family meals, and gatherings.")
        case .cafe:
            return String(localized: "Places for coffee, light meals, and a relaxed atmosphere.")
        case .warkop:
            return String(localized: "Local coffee stalls with drinks and simple meals.")
        case .pkl:
            return String(localized: "Street food vendors serving local dishes, quick meals, and affordable eats.")
        case .drinks:
            return String(localized: "Places focused on beverages and specialty drinks.")
        case .bakery:
            return String(localized: "Places serving bread, pastries, cakes, and freshly baked goods.")
            
        }
    }
}
