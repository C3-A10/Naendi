//
//  PlaceMatcherTests.swift
//  NaendiTests
//
//  Dates are pinned to a UTC calendar so weekday-sensitive assertions do not
//  depend on the machine's timezone.
//

import Testing
import Foundation
@testable import Naendi

struct PlaceMatcherTests {

    private static let utcCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    /// 2026-07-20 is a Monday (Senin).
    private static let monday: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 7
        components.day = 20
        components.hour = 12
        return utcCalendar.date(from: components)!
    }()

    private let matcher = PlaceMatcher(calendar: PlaceMatcherTests.utcCalendar)

    private func matches(
        _ place: Place,
        _ criteria: PreferenceCriteria,
        origin: Coordinate? = nil
    ) -> Bool {
        matcher.matches(place, criteria: criteria, origin: origin, now: Self.monday)
    }

    // MARK: - Type and vibe

    @Test("a nil type means Any and matches everything")
    func nilTypeMatchesAnything() {
        #expect(matches(.stub(typeTempat: "Restaurant"), PreferenceCriteria(type: nil)))
        #expect(matches(.stub(typeTempat: "PKL"), PreferenceCriteria(type: nil)))
    }

    @Test("a set type excludes other types")
    func typeIsExclusive() {
        #expect(matches(.stub(typeTempat: "Cafe"), PreferenceCriteria(type: "Cafe")))
        #expect(matches(.stub(typeTempat: "Restaurant"), PreferenceCriteria(type: "Cafe")) == false)
    }

    @Test("type comparison ignores case")
    func typeIsCaseInsensitive() {
        #expect(matches(.stub(typeTempat: "cafe"), PreferenceCriteria(type: "Cafe")))
    }

    @Test("a nil vibe means Any, a set vibe is exclusive")
    func vibeBehaviour() {
        #expect(matches(.stub(vibe: "Calm"), PreferenceCriteria(vibe: nil)))
        #expect(matches(.stub(vibe: "Calm"), PreferenceCriteria(vibe: "Calm")))
        #expect(matches(.stub(vibe: "Lively"), PreferenceCriteria(vibe: "Calm")) == false)
    }

    // MARK: - Halal

    @Test("Any halal preference accepts every status", arguments: ["halal", "non-halal", "unknown"])
    func anyHalalAcceptsEverything(status: String) {
        #expect(matches(.stub(halal: status), PreferenceCriteria(halal: .any)))
    }

    @Test("Halal accepts verified and unverified places but rejects non-halal")
    func halalAcceptsUnknown() {
        let criteria = PreferenceCriteria(halal: .halal)
        #expect(matches(.stub(halal: "halal"), criteria))
        #expect(matches(.stub(halal: "unknown"), criteria))
        #expect(matches(.stub(halal: "non-halal"), criteria) == false)
    }

    @Test("Non-halal accepts only places known to be non-halal")
    func nonHalalIsExclusive() {
        let criteria = PreferenceCriteria(halal: .nonHalal)
        #expect(matches(.stub(halal: "non-halal"), criteria))
        #expect(matches(.stub(halal: "unknown"), criteria) == false)
        #expect(matches(.stub(halal: "halal"), criteria) == false)
    }

    // MARK: - Radius

    @Test("radius is skipped when there is no origin to measure from")
    func noOriginSkipsRadius() {
        let faraway = Place.stub(latitude: 50, longitude: 50)
        #expect(matches(faraway, PreferenceCriteria(radiusKm: 1), origin: nil))
    }

    @Test("the radius bound is inclusive")
    func radiusIsInclusive() {
        let here = Place.stub(latitude: 0, longitude: 0)
        // Distance is exactly zero, so even a zero radius must accept it.
        #expect(matches(here, PreferenceCriteria(radiusKm: 0), origin: Coordinate(latitude: 0, longitude: 0)))
    }

    @Test("places beyond the radius are excluded")
    func excludesBeyondRadius() {
        // 0.09 degrees of latitude is roughly 10 km.
        let place = Place.stub(latitude: 0.09, longitude: 0)
        let origin = Coordinate(latitude: 0, longitude: 0)
        #expect(matches(place, PreferenceCriteria(radiusKm: 3), origin: origin) == false)
        #expect(matches(place, PreferenceCriteria(radiusKm: 11), origin: origin))
    }

    // MARK: - Budget

    @Test("Any Budget matches regardless of price")
    func anyBudgetMatches() {
        #expect(matches(.stub(rangeHarga: "Rp 250.000+"), PreferenceCriteria(budget: .any)))
    }

    @Test("a place with no price string passes any budget")
    func missingPricePasses() {
        #expect(matches(.stub(rangeHarga: ""), PreferenceCriteria(budget: .tenToFifty)))
    }

    @Test("a price band overlapping the budget matches")
    func overlappingPriceMatches() {
        #expect(matches(.stub(rangeHarga: "Rp 25–50 rb"), PreferenceCriteria(budget: .tenToFifty)))
    }

    @Test("a price band clear of the budget is excluded")
    func disjointPriceExcluded() {
        #expect(matches(.stub(rangeHarga: "Rp 100–250 rb"), PreferenceCriteria(budget: .tenToFifty)) == false)
    }

    @Test("a custom budget uses the user's own bounds")
    func customBudgetUsesOwnBounds() {
        let criteria = PreferenceCriteria(
            budget: .custom,
            customMinBudget: 200_000,
            customMaxBudget: 300_000
        )
        #expect(matches(.stub(rangeHarga: "Rp 250.000+"), criteria))
        #expect(matches(.stub(rangeHarga: "Rp 25–50 rb"), criteria) == false)
    }

    @Test("a custom budget with no bounds set constrains nothing")
    func emptyCustomBudgetMatchesEverything() {
        let criteria = PreferenceCriteria(budget: .custom)
        #expect(matches(.stub(rangeHarga: "Rp 25–50 rb"), criteria))
    }

    // MARK: - Opening hours

    @Test("a place with no schedule passes")
    func missingSchedulePasses() {
        let criteria = PreferenceCriteria(startMinutes: 11 * 60, endMinutes: 13 * 60)
        #expect(matches(.stub(jamBuka: ""), criteria))
    }

    @Test("a place open across the whole window matches")
    func openAcrossWindow() {
        let place = Place.stub(jamBuka: #"{"Senin": ["10.00–22.00"]}"#)
        let criteria = PreferenceCriteria(startMinutes: 11 * 60, endMinutes: 13 * 60)
        #expect(matches(place, criteria))
    }

    @Test("a place closing inside the window is excluded")
    func closesInsideWindow() {
        let place = Place.stub(jamBuka: #"{"Senin": ["10.00–12.00"]}"#)
        let criteria = PreferenceCriteria(startMinutes: 11 * 60, endMinutes: 13 * 60)
        #expect(matches(place, criteria) == false)
    }

    @Test("a place closed today is excluded even though other days are open")
    func closedToday() {
        let place = Place.stub(jamBuka: #"{"Senin": ["Tutup"], "Selasa": ["10.00–22.00"]}"#)
        let criteria = PreferenceCriteria(startMinutes: 11 * 60, endMinutes: 13 * 60)
        #expect(matches(place, criteria) == false)
    }

    @Test("a day missing from the schedule passes rather than failing")
    func unknownDayPasses() {
        let place = Place.stub(jamBuka: #"{"Selasa": ["10.00–22.00"]}"#)
        let criteria = PreferenceCriteria(startMinutes: 11 * 60, endMinutes: 13 * 60)
        #expect(matches(place, criteria))
    }

    // MARK: - Combination

    @Test("every criterion must pass")
    func allCriteriaMustPass() {
        let place = Place.stub(
            latitude: 0,
            longitude: 0,
            rangeHarga: "Rp 25–50 rb",
            jamBuka: #"{"Senin": ["10.00–22.00"]}"#,
            typeTempat: "Cafe",
            vibe: "Calm",
            halal: "halal"
        )
        let origin = Coordinate(latitude: 0, longitude: 0)
        let good = PreferenceCriteria(
            radiusKm: 1,
            budget: .tenToFifty,
            type: "Cafe",
            vibe: "Calm",
            startMinutes: 11 * 60,
            endMinutes: 13 * 60,
            halal: .halal
        )
        #expect(matches(place, good, origin: origin))

        var wrongVibe = good
        wrongVibe.vibe = "Lively"
        #expect(matches(place, wrongVibe, origin: origin) == false)
    }
}
