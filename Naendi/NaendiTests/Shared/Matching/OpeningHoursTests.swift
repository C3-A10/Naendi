//
//  OpeningHoursTests.swift
//  NaendiTests
//
//  Weekday numbers follow Calendar.component(.weekday): 1 = Minggu (Sunday),
//  2 = Senin, and so on.
//

import Testing
@testable import Naendi

struct OpeningHoursTests {

    private static let senin = 2
    private static let selasa = 3

    private func hours(_ json: String) -> OpeningHours? {
        OpeningHours(json: json)
    }

    @Test("a place open 24 hours is open during any window")
    func openTwentyFourHours() {
        let subject = hours(#"{"Senin": ["Buka 24 jam"]}"#)
        let window = MinuteInterval(startHour: 3, endHour: 5)
        #expect(subject?.isOpen(during: window, onWeekday: Self.senin) == true)
    }

    @Test("an explicitly closed day fails rather than reading as unknown")
    func tutupIsAContradiction() {
        let subject = hours(#"{"Senin": ["Tutup"]}"#)
        let window = MinuteInterval(startHour: 11, endHour: 13)
        #expect(subject?.isOpen(during: window, onWeekday: Self.senin) == false)
    }

    @Test("a day absent from the schedule is unknown and passes to the caller")
    func missingDayIsUnknown() {
        let subject = hours(#"{"Senin": ["10.00–22.00"]}"#)
        let window = MinuteInterval(startHour: 11, endHour: 13)
        #expect(subject?.isOpen(during: window, onWeekday: Self.selasa) == nil)
    }

    @Test("the whole window must fall inside opening hours")
    func requiresWholeWindow() {
        let subject = hours(#"{"Senin": ["10.00–20.00"]}"#)
        // Ends after closing time.
        #expect(subject?.isOpen(during: MinuteInterval(startHour: 19, endHour: 21), onWeekday: Self.senin) == false)
        // Starts before opening time.
        #expect(subject?.isOpen(during: MinuteInterval(startHour: 9, endHour: 11), onWeekday: Self.senin) == false)
        // Fully inside.
        #expect(subject?.isOpen(during: MinuteInterval(startHour: 11, endHour: 13), onWeekday: Self.senin) == true)
    }

    @Test("a window exactly matching the opening hours counts as open")
    func exactBoundaryIsInclusive() {
        let subject = hours(#"{"Senin": ["10.00–22.00"]}"#)
        let window = MinuteInterval(startHour: 10, endHour: 22)
        #expect(subject?.isOpen(during: window, onWeekday: Self.senin) == true)
    }

    @Test("split hours are merged when the halves touch")
    func mergesTouchingSlots() {
        let subject = hours(#"{"Senin": ["08.00–12.00", "12.00–20.00"]}"#)
        // Spans the seam between the two slots.
        let window = MinuteInterval(startHour: 11, endHour: 13)
        #expect(subject?.isOpen(during: window, onWeekday: Self.senin) == true)
    }

    @Test("a genuine break between split hours is respected")
    func doesNotBridgeARealGap() {
        let subject = hours(#"{"Senin": ["08.00–12.00", "17.00–22.00"]}"#)
        #expect(subject?.isOpen(during: MinuteInterval(startHour: 13, endHour: 15), onWeekday: Self.senin) == false)
        #expect(subject?.isOpen(during: MinuteInterval(startHour: 18, endHour: 20), onWeekday: Self.senin) == true)
    }

    @Test("hours running past midnight extend beyond 1440")
    func handlesMidnightCrossing() {
        let subject = hours(#"{"Senin": ["18.00–02.00"]}"#)
        #expect(subject?.isOpen(during: MinuteInterval(startHour: 19, endHour: 23), onWeekday: Self.senin) == true)
        // 01:00 the following morning is 25:00 in this representation.
        #expect(subject?.isOpen(during: MinuteInterval(start: 24 * 60, end: 25 * 60), onWeekday: Self.senin) == true)
    }

    @Test("minutes are parsed, not just whole hours")
    func parsesMinutes() {
        let subject = hours(#"{"Senin": ["06.30–21.30"]}"#)
        #expect(subject?.isOpen(during: MinuteInterval(start: 6 * 60 + 30, end: 21 * 60 + 30), onWeekday: Self.senin) == true)
        #expect(subject?.isOpen(during: MinuteInterval(start: 6 * 60, end: 21 * 60), onWeekday: Self.senin) == false)
    }

    @Test("malformed JSON yields nil")
    func malformedJSONIsNil() {
        #expect(hours("") == nil)
        #expect(hours("not json") == nil)
    }

    @Test("an out-of-range weekday is unknown rather than a crash")
    func weekdayOutOfRange() {
        let subject = hours(#"{"Senin": ["10.00–22.00"]}"#)
        let window = MinuteInterval(startHour: 11, endHour: 13)
        #expect(subject?.isOpen(during: window, onWeekday: 0) == nil)
        #expect(subject?.isOpen(during: window, onWeekday: 8) == nil)
    }

    @Test("Place exposes its parsed schedule")
    func placeAccessor() {
        #expect(Place.stub(jamBuka: #"{"Senin": ["10.00–22.00"]}"#).openingHours != nil)
        #expect(Place.stub(jamBuka: "").openingHours == nil)
    }
}
