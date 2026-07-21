//
//  PriceRangeTests.swift
//  NaendiTests
//
//  The `allDatasetStrings` list is every distinct non-empty `range_harga`
//  value in app-dataset.csv (37 of them across 6,150 rows), so a parser
//  regression on any real-world format fails here.
//

import Testing
@testable import Naendi

struct PriceRangeTests {

    static let allDatasetStrings = [
        "Rp 100–125 rb", "Rp 100–200 rb", "Rp 100–225 rb", "Rp 100–250 rb",
        "Rp 125–150 rb", "Rp 125–175 rb", "Rp 125–200 rb", "Rp 125–225 rb",
        "Rp 125–250 rb", "Rp 150–175 rb", "Rp 175–200 rb",
        "Rp 1–100.000", "Rp 1–125.000", "Rp 1–150.000",
        "Rp 1–25.000", "Rp 1–50.000", "Rp 1–75.000",
        "Rp 225–250 rb", "Rp 250.000+",
        "Rp 25–100 rb", "Rp 25–125 rb", "Rp 25–150 rb", "Rp 25–175 rb",
        "Rp 25–50 rb", "Rp 25–75 rb",
        "Rp 50–100 rb", "Rp 50–125 rb", "Rp 50–150 rb", "Rp 50–175 rb",
        "Rp 50–200 rb", "Rp 50–75 rb",
        "Rp 75–100 rb", "Rp 75–125 rb", "Rp 75–150 rb", "Rp 75–175 rb",
        "Rp 75–200 rb", "Rp 75–225 rb"
    ]

    @Test("every price string in the dataset parses", arguments: allDatasetStrings)
    func parsesEveryDatasetString(raw: String) {
        let range = PriceRange(parsing: raw)
        #expect(range != nil, "failed to parse \(raw)")

        // Every real value starts at Rp 1 or more; an open upper bound is only
        // legitimate for the "+" form.
        #expect((range?.lowerBound ?? 0) >= 1)
        if !raw.contains("+") {
            #expect(range?.upperBound != nil)
        }
    }

    @Test("a rb suffix scales both operands")
    func rbSuffixScalesBothOperands() {
        #expect(PriceRange(parsing: "Rp 25–50 rb") == PriceRange(lowerBound: 25_000, upperBound: 50_000))
    }

    @Test("dots are thousands separators when no scale suffix is present")
    func dottedThousands() {
        #expect(PriceRange(parsing: "Rp 1–25.000") == PriceRange(lowerBound: 1, upperBound: 25_000))
    }

    @Test("a trailing plus means unbounded above")
    func trailingPlusIsOpenEnded() {
        #expect(PriceRange(parsing: "Rp 250.000+") == PriceRange(lowerBound: 250_000, upperBound: nil))
    }

    @Test("a plain hyphen parses the same as an en-dash")
    func hyphenMatchesEnDash() {
        #expect(PriceRange(parsing: "Rp 25-50 rb") == PriceRange(parsing: "Rp 25–50 rb"))
    }

    @Test("di bawah means unbounded below")
    func diBawahIsOpenEndedBelow() {
        #expect(PriceRange(parsing: "Di bawah Rp 25 rb") == PriceRange(lowerBound: nil, upperBound: 25_000))
    }

    @Test("a decimal fraction survives a juta suffix")
    func decimalFractionWithJutaSuffix() {
        #expect(PriceRange(parsing: "Rp 1.5 jt") == PriceRange(lowerBound: 1_500_000, upperBound: 1_500_000))
    }

    @Test("unparseable input yields nil", arguments: ["", "   ", "Gratis"])
    func unparseableInputIsNil(raw: String) {
        #expect(PriceRange(parsing: raw) == nil)
    }

    @Test("overlapping bands match even when neither contains the other")
    func overlapIsNotContainment() {
        let place = PriceRange(lowerBound: 25_000, upperBound: 50_000)
        let budget = PriceRange(lowerBound: 10_000, upperBound: 30_000)
        #expect(place.overlaps(budget))
        #expect(budget.overlaps(place))
    }

    @Test("disjoint bands do not match")
    func disjointBandsDoNotMatch() {
        let place = PriceRange(lowerBound: 100_000, upperBound: 250_000)
        let budget = PriceRange(lowerBound: 10_000, upperBound: 50_000)
        #expect(place.overlaps(budget) == false)
    }

    @Test("touching at a single boundary counts as overlap")
    func touchingBoundsOverlap() {
        let place = PriceRange(lowerBound: 50_000, upperBound: 75_000)
        let budget = PriceRange(lowerBound: 10_000, upperBound: 50_000)
        #expect(place.overlaps(budget))
    }

    @Test("an open upper bound overlaps any budget above its floor")
    func openEndedOverlap() {
        let place = PriceRange(lowerBound: 250_000, upperBound: nil)
        #expect(place.overlaps(PriceRange(lowerBound: 300_000, upperBound: 400_000)))
        #expect(place.overlaps(PriceRange(lowerBound: 10_000, upperBound: 50_000)) == false)
    }

    @Test("Place exposes its parsed range")
    func placeAccessor() {
        #expect(Place.stub(rangeHarga: "Rp 25–50 rb").priceRange != nil)
        #expect(Place.stub(rangeHarga: "").priceRange == nil)
    }
}
