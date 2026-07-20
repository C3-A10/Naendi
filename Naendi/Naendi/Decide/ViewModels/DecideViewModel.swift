//
//  DecideViewModel.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import Foundation
import Observation
import CoreLocation

@Observable
class DecideViewModel: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private let mapKitService = MapKitService()

    var places: [Place] = []
    var landingPagePlaces: [Place] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedPlaces: [Place] = []
    var isCompareLimitReached: Bool { selectedPlaces.count >= 2 }
    
    var userLocation: CLLocation?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // fungsi untuk mengecek apakah suatu tempat sedang terpilih
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
    
    /// Loads places from the backend (CloudKit-seeded, locally cached) and keeps
    /// the top `limit` ranked by review count, descending. Preference filtering
    /// is intentionally not applied yet.
    func loadTopPlaces(from provider: PlaceProviding, limit: Int = 10) async {
        isLoading = true
        errorMessage = nil
        do {
            let all = try await provider.places()
            places = Array(
                all.sorted { $0.jumlahReview > $1.jumlahReview }.prefix(limit)
            )
        } catch {
            errorMessage = error.localizedDescription
            places = []
        }
        isLoading = false
    }

    // function ini diganti kalau udh ada data asli dari swiftdata/cloudkit
    func loadDummyData() {
        self.isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run {
                //self.places = Place.dummyData
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
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // minta izin lokasi ke user
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 10.0 // panggil fungsi hanya jika user berjalan/berpindah sejauh 10 meter
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    // fungsi untuk routing di apple map
    func openRoute(to place: Place) {
        mapKitService.openAppleMapsRoute(to: place)
    }
    
    // fungsi untuk hitung jarak di cardview
    func calculateDistance(to place: Place) -> String {
        guard let userLocation = userLocation else {
            return "-" // tampilkan tanda strip jika GPS user belum didapat/tdk diizinkan
        }
        
        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        
        // menghitung jarak dalam satuan meter
        let distanceInMeters = userLocation.distance(from: placeLocation)
        
        // format tampilan teks (jika < 1 km tampilkan "500 m", jika lebih tampilkan "1.2 km")
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            let distanceInKm = distanceInMeters / 1000
            return String(format: "%.1f km", distanceInKm)
        }
    }
}
