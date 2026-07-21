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
    var persistenceErrorMessage: String?
    var reportErrorMessage: String?
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

        guard let origin else {
            places = []
            isLoading = false
            errorMessage = "Location is unavailable. Search for a location or allow location access to apply the selected radius."
            phase = .results
            return
        }

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
        phase = .results
    }

    func applyPreferences(
        _ criteria: PreferenceCriteria,
        store: PreferenceStoring,
        provider: PlaceProviding
    ) async {
        do {
            try store.saveCriteria(criteria)
            persistenceErrorMessage = nil
        } catch {
            persistenceErrorMessage = "Your preferences were applied for this session but could not be saved."
        }
        await loadRecommendations(from: provider, criteria: criteria)
    }

    func restoreCriteria(from store: PreferenceStoring) {
        guard let stored = try? store.loadCriteria() else { return }
        criteria = stored
    }

    // fungsi untuk routing di apple map
    func openRoute(to place: Place) {
        mapKitService.openAppleMapsRoute(to: place)
    }

    /// Reports a place, bumping its `jumlah_report` count in CloudKit. Callers are
    /// expected to have already confirmed proximity via `isWithinReportRadius(of:)`.
    /// A failure surfaces via `reportErrorMessage`; it never throws to the view.
    func reportPlace(
        _ place: Place,
        using repository: CloudKitPlaceRepository = CloudKitPlaceRepository()
    ) async {
        do {
            _ = try await repository.incrementReportCount(placeID: place.id)
            reportErrorMessage = nil
        } catch {
            reportErrorMessage = "Couldn't submit your report. Please try again."
        }
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

    // fungsi untuk hitung jarak dari tempat user saat ini
    func calculateDistanceFromMe(to place: Place) -> String {
        guard let userLocation else {
            return "-" // tampilkan tanda strip jika GPS user belum didapat/tdk diizinkan
        }

        let distanceInMeters = userLocation.distance(from: place.coordinate.clLocation)

        // format tampilan teks (jika < 1 km tampilkan "500 m", jika lebih tampilkan "1.2 km")
        if distanceInMeters < 1000 {
            return String(format: "%.0f m", distanceInMeters)
        } else {
            let distanceInKm = distanceInMeters / 1000
            return String(format: "%.1f km", distanceInKm)
        }
    }

    /// Returns true when GPS is available and the user is within 250 m of the place.
    func isWithinReportRadius(of place: Place) -> Bool {
        guard let userLocation else { return false }
        return userLocation.distance(from: place.coordinate.clLocation) <= 250
    }
}
