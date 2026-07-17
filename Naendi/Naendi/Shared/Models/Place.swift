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

struct Place {
    let name: String
    let halalStatus: HalalStatus
}
