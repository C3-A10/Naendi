//
//  FakePlaceStore.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//
import Foundation

@testable import Naendi

final class FakePlaceStore: PlaceStore {
    var storedPlaces: [Place] = []
    var hasSeededData: Bool = false

    private(set) var savedPlaces: [Place]? = nil

    func loadPlaces() throws -> [Place] { storedPlaces }

    func save(_ places: [Place]) throws {
        savedPlaces = places
        for place in places {
            if let index = storedPlaces.firstIndex(where: { $0.id == place.id }) {
                storedPlaces[index] = place
            } else {
                storedPlaces.append(place)
            }
        }
    }

    func markSeeded() throws {
        hasSeededData = true
    }
}
