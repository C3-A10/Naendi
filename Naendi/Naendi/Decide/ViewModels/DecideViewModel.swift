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
class DecideViewModel {

    private let mapKitService = MapKitService()
    private let locationProvider: LocationProviding
    private let recommender: PlaceRecommender

    /// The filtered, sorted results shown on the results screen.
    var places: [Place] = []
    /// The showcase carousel on the landing page, ranked by review count.
    var landingPagePlaces: [Place] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var selectedPlaces: [Place] = []
    var isCompareLimitReached: Bool { selectedPlaces.count >= 2 }

    var phase: DecidePhase = .landing
    var criteria: PreferenceCriteria = .default

    /// Fixed until preferences are re-applied, so "Surprise Me" doesn't reshuffle
    /// as the user scrolls or expands a card.
    private var shuffleSeed = UInt64.random(in: .min ... .max)

    init(
        locationProvider: LocationProviding = CoreLocationProvider(),
        recommender: PlaceRecommender = PlaceRecommender()
    ) {
        self.locationProvider = locationProvider
        self.recommender = recommender
    }

    var userLocation: CLLocation? { locationProvider.currentLocation }

    /// Where distances and the radius filter are measured from: the location the
    /// user searched for, falling back to the device's own position.
    var origin: Coordinate? {
        criteria.coordinate ?? locationProvider.currentLocation.map { Coordinate($0.coordinate) }
    }

    /// Triggers the location permission prompt, so call it from a view's `.task`
    /// rather than at construction time.
    func startLocationUpdates() {
        locationProvider.start()
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

    /// Fills the landing page showcase with the most-reviewed places. This is a
    /// teaser, not a search — preferences deliberately don't apply.
    func loadLandingPlaces(from provider: PlaceProviding, limit: Int = 10) async {
        isLoading = true
        errorMessage = nil
        do {
            let all = try await provider.places()
            landingPagePlaces = Array(
                all.sorted { $0.jumlahReview > $1.jumlahReview }.prefix(limit)
            )
        } catch {
            errorMessage = error.localizedDescription
            landingPagePlaces = []
        }
        isLoading = false
    }

    /// Applies the user's preferences and moves to the results screen.
    func loadRecommendations(
        from provider: PlaceProviding,
        criteria: PreferenceCriteria,
        now: Date = .now
    ) async {
        self.criteria = criteria
        shuffleSeed = UInt64.random(in: .min ... .max)

        phase = .loading
        isLoading = true
        errorMessage = nil

        do {
            let all = try await provider.places()
            places = recommender.recommend(
                all,
                criteria: criteria,
                origin: origin,
                now: now,
                seed: shuffleSeed
            )
        } catch {
            errorMessage = error.localizedDescription
            places = []
        }

        isLoading = false
        // Unconditional: matching nothing is a valid outcome that belongs on the
        // results screen, not a reason to fall back to the landing page.
        phase = .results
    }

    /// Persists the user's edited preferences and immediately searches with them.
    /// A failed write is not fatal — the search still runs, the choice just
    /// won't survive a relaunch.
    func applyPreferences(
        _ criteria: PreferenceCriteria,
        store: PreferenceStoring,
        provider: PlaceProviding
    ) async {
        try? store.saveCriteria(criteria)
        await loadRecommendations(from: provider, criteria: criteria)
    }

    /// Restores previously saved preferences, if any, without running a search.
    func restoreCriteria(from store: PreferenceStoring) {
        guard let stored = try? store.loadCriteria() else { return }
        criteria = stored
    }

    // fungsi untuk routing di apple map
    func openRoute(to place: Place) {
        mapKitService.openAppleMapsRoute(to: place)
    }

    // fungsi untuk hitung jarak di cardview
    func calculateDistance(to place: Place) -> String {
        guard let origin else {
            return "-" // tampilkan tanda strip jika GPS user belum didapat/tdk diizinkan
        }

        // menghitung jarak dalam satuan meter, diukur dari titik yang sama
        // dengan filter radius supaya tidak kontradiktif
        let distanceInMeters = origin.clLocation.distance(from: place.coordinate.clLocation)

        // format tampilan teks (jika < 1 km tampilkan "500 m", jika lebih tampilkan "1.2 km")
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            let distanceInKm = distanceInMeters / 1000
            return String(format: "%.1f km", distanceInKm)
        }
    }
}
