//
//  PlaceRepository.swift
//  Naendi
//
//  Created by Mohammad Rizaldy Ramadhan on 16/07/26.
//

import Foundation

protocol PlaceRepository {
    func getAllPlaces() async throws -> [Place]
}
