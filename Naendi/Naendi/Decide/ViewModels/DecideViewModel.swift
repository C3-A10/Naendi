//
//  DecideViewModel.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import Foundation
import Observation

@Observable
class DecideViewModel {
    var places: [Place] = []
    var landingPagePlaces: [Place] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    // 1. Array untuk menampung maksimal 2 objek Place yang dipilih
    var selectedPlaces: [Place] = []
    
    // Helper untuk mengecek apakah kuota compare sudah penuh (2 tempat)
    var isCompareLimitReached: Bool {
        selectedPlaces.count >= 2
    }
    
    // Helper untuk mengecek apakah suatu tempat sedang terpilih
    func isSelected(_ place: Place) -> Bool {
        selectedPlaces.contains { $0.id == place.id }
    }
    
    // Fungsi untuk menambah/menghapus tempat dari daftar perbandingan
    func toggleSelection(for place: Place) {
        if let index = selectedPlaces.firstIndex(where: { $0.id == place.id }) {
            // Jika sudah ada, hapus dari list
            selectedPlaces.remove(at: index)
        } else if !isCompareLimitReached {
            // Jika belum ada dan kuota masih tersedia, masukkan ke list
            selectedPlaces.append(place)
        }
    }
    
    // Kosongkan daftar saat keluar dari mode compare
    func clearSelectedPlaces() {
        selectedPlaces.removeAll()
    }
    
    // function ini diganti kalau udh ada data asli dari swiftdata/cloudkit
    func loadDummyData() {
        self.isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run {
                self.places = Place.dummyData
                self.isLoading = false
            }
        }
    }
    
    func loadLandingPageData() {
        self.isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run {
                self.landingPagePlaces = Place.dummyData
                self.isLoading = false
            }
        }
    }
}
