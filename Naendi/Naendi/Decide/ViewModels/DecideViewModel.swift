//
//  DecideViewModel.swift
//  Naendi
//
//  Created by Bryan Samuel on 14/07/26.
//

import Foundation
import Observation
import CoreLocation
import CloudKit

/// Why a place earns a spot on the landing showcase, so its card can label itself.
enum LandingTag: Equatable {
    case nearby
    case top(type: String)
}

@MainActor
@Observable
class DecideViewModel {

    private let mapKitService = MapKitService()
    private let locationProvider: LocationProviding
    private let recommender: PlaceRecommender
    private let networkMonitor = NetworkMonitor()

    /// The filtered, sorted results shown on the results screen.
    var places: [Place] = []
    /// The showcase carousel on the landing page: nearby picks, then top
    /// restaurants, then top cafes.
    var landingPagePlaces: [Place] = []
    /// Which group each landing card belongs to, keyed by place id, so a card
    /// can render the matching "Nearby" / "Top …" pill.
    private var landingTags: [String: LandingTag] = [:]
    var isLoading: Bool = false
    var errorMessage: String?
    var persistenceErrorMessage: String?
    var reportMessage: String?
    /// Live report counts per place id, sourced from the `Report` records rather
    /// than the stale `jumlah_report` field on `Place`.
    var reportCounts: [String: Int] = [:]
    var selectedPlaces: [Place] = []
    var isCompareLimitReached: Bool { selectedPlaces.count >= 2 }

    var phase: DecidePhase = .landing
    var criteria: PreferenceCriteria = .default
    
    var isNetworkConnected: Bool { networkMonitor.isConnected }

    private(set) var awaitingOrigin = false

    private var shuffleSeed = UInt64.random(in: .min ... .max)

    init(
        locationProvider: LocationProviding = CoreLocationProvider(),
        recommender: PlaceRecommender = PlaceRecommender()
    ) {
        self.locationProvider = locationProvider
        self.recommender = recommender
    }

    var userLocation: CLLocation? { locationProvider.currentLocation }

    var origin: Coordinate? {
        criteria.coordinate ?? locationProvider.currentLocation.map { Coordinate($0.coordinate) }
    }

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

    func landingTag(for place: Place) -> LandingTag? { landingTags[place.id] }

    func loadLandingPlaces(from provider: PlaceProviding, perGroup: Int = 1) async {
        isLoading = true
        errorMessage = nil
        do {
            let all = try await provider.places { [weak self] fresh in
                self?.applyLanding(fresh, perGroup: perGroup)
            }
            applyLanding(all, perGroup: perGroup)
        } catch {
            errorMessage = error.localizedDescription
            landingPagePlaces = []
            landingTags = [:]
        }
        await loadReportCounts()
        isLoading = false
    }

    private func applyLanding(_ all: [Place], perGroup: Int) {
        let byDistance: [Place]
        if let origin {
            let from = origin.clLocation
            byDistance = all.sorted {
                from.distance(from: $0.coordinate.clLocation)
                    < from.distance(from: $1.coordinate.clLocation)
            }
        } else {
            byDistance = []
        }

        func topReviewed(ofType type: String) -> [Place] {
            all.filter { $0.typeTempat == type }
                .sorted { $0.jumlahReview > $1.jumlahReview }
        }

        var tags: [String: LandingTag] = [:]
        var ordered: [Place] = []
        func add(_ group: [Place], _ tag: LandingTag) {
            var taken = 0
            for place in group where tags[place.id] == nil {
                tags[place.id] = tag
                ordered.append(place)
                taken += 1
                if taken == perGroup { break }
            }
        }

        add(byDistance, .nearby)
        add(topReviewed(ofType: "Restaurant"), .top(type: "Restaurant"))
        add(topReviewed(ofType: "Cafe"), .top(type: "Cafe"))

        landingPagePlaces = ordered
        landingTags = tags
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
            awaitingOrigin = true
            errorMessage = String(
                localized: "Location is unavailable. Search for a location or allow location access to apply the selected radius."
            )
            phase = .results
            return
        }
        awaitingOrigin = false

        do {
            let seed = shuffleSeed
            let all = try await provider.places { [weak self] fresh in
                guard let self else { return }
                self.places = self.recommender.recommend(
                    fresh,
                    criteria: criteria,
                    origin: origin,
                    now: now,
                    seed: seed
                )
            }
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

        await loadReportCounts()
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
            persistenceErrorMessage = String(
                localized: "Your preferences were applied for this session but could not be saved."
            )
        }
        await loadRecommendations(from: provider, criteria: criteria)
    }

    @discardableResult
    func restoreCriteria(from store: PreferenceStoring) -> Bool {
        do {
            if let stored = try store.loadCriteria() {
                criteria = stored
                persistenceErrorMessage = nil
                return true
            }
            persistenceErrorMessage = nil
            return false
        } catch {
            persistenceErrorMessage = String(
                localized: "Your saved preferences could not be restored. Default preferences will be used."
            )
            return false
        }
    }

    // fungsi untuk routing di apple map
    func openRoute(to place: Place) {
        mapKitService.openAppleMapsRoute(to: place)
    }

    // fungsi untuk menambah report count di cloudkit
    func reportPlace(
        _ place: Place,
        using repository: CloudKitPlaceRepository = CloudKitPlaceRepository()
    ) async -> Bool {
        do {
            let isNew = try await repository.report(placeID: place.id)
            reportMessage = isNew
                ? "Your report has been submitted successfully. Thanks for your help!"
                : "Looks lik you've already submitted a report for this place."
            if isNew {
                reportCounts[place.id, default: place.reportCount] += 1
            }
            return isNew
        } catch let error as CKError where error.code == .notAuthenticated {
            reportMessage = "Log-in to iCloud to submit a report. Please try again when you're back online."
        } catch {
            reportMessage = "Failed to send report, please try again"
        }
        return false
    }

    // ambil reportcount terbaru 
    func reportCount(for place: Place) -> Int {
        reportCounts[place.id] ?? place.reportCount
    }

    // fungsi untuk load ulang reportcounts di cloudkit
    func loadReportCounts(using repository: CloudKitPlaceRepository = CloudKitPlaceRepository()) async {
        if let counts = try? await repository.reportCounts() {
            reportCounts = counts
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

    // Returns true when GPS is available and the user is within 250 m of the place.
    func isWithinReportRadius(of place: Place) -> Bool {
        guard let userLocation else { return false }
        return userLocation.distance(from: place.coordinate.clLocation) <= 250
    }
}
