//
//  PlaceStore.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 17/07/26.
//

protocol PlaceStore {
    func loadPlaces() throws -> [Place]
    func save(_ places: [Place]) throws
    var hasSeededData: Bool { get }
    func markSeeded() throws
}
