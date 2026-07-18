//
//  UserPreference.swift
//  Naendi
//
//  Created by Satriya Handha Wibowo on 14/07/26.
//

import Foundation
import SwiftData

@Model
final class UserPreference {
    var radius: Double
    var budgetCategory: String
    var minBudget: Double
    var maxBudget: Double
    var type: String
    var vibe: String
    var startTime: Date
    var endTime: Date
    var isHalalOnly: Bool
    var outputResult: Int
    var sortBy: String
    
    // --- Penyimpanan Array Place (Caching CloudKit Data) ---
    // Kita simpan sebagai Data agar tidak mengganggu relasi SwiftData
    private var savedPlacesData: Data?
    
    init(radius: Double = 1.0,
         budgetCategory: String = "$$",
         minBudget: Double = 10000,
         maxBudget: Double = 25000,
         type: String = "Cafe",
         vibe: String = "Lively",
         startTime: Date = Date(),
         endTime: Date = Date(),
         isHalalOnly: Bool = false,
         outputResult: Int = 5,
         sortBy: String = "Surprise Me") {
        
        self.radius = radius
        self.budgetCategory = budgetCategory
        self.minBudget = minBudget
        self.maxBudget = maxBudget
        self.type = type
        self.vibe = vibe
        self.startTime = startTime
        self.endTime = endTime
        self.isHalalOnly = isHalalOnly
        self.outputResult = outputResult
        self.sortBy = sortBy
    }
    
    // Helper property untuk mengakses array Place dengan mudah
    var savedPlaces: [Place] {
        get {
            guard let data = savedPlacesData else { return [] }
            return []
        }
        set {
            savedPlacesData = Data()
        }
    }
}
