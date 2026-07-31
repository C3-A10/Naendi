//
//  PriceRange.swift
//  Naendi
//
//  Parses the free-form `range_harga` strings from the dataset into a numeric
//  range so budget preferences can be matched against them.
//

import Foundation

struct PriceRange: Equatable {
    let lowerBound: Double?
    let upperBound: Double?

    init(lowerBound: Double?, upperBound: Double?) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    init?(parsing raw: String) {
        let text = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !text.isEmpty else { return nil }

        let isOpenEndedAbove = text.contains("+") || text.contains("di atas")
        let isOpenEndedBelow = text.contains("di bawah")

        let scale: Double
        if text.contains("jt") || text.contains("juta") {
            scale = 1_000_000
        } else if text.contains("rb") || text.contains("ribu") {
            scale = 1_000
        } else {
            scale = 1
        }

        var stripped = text
        for noise in ["di bawah", "di atas", "ribu", "juta", "rp", "rb", "jt", "+"] {
            stripped = stripped.replacingOccurrences(of: noise, with: " ")
        }

        let numbers = stripped
            .components(separatedBy: CharacterSet(charactersIn: "\u{2013}-"))
            .compactMap { Self.number(from: $0, scale: scale) }

        switch numbers.count {
        case 0:
            return nil
        case 1 where isOpenEndedAbove:
            self.init(lowerBound: numbers[0], upperBound: nil)
        case 1 where isOpenEndedBelow:
            self.init(lowerBound: nil, upperBound: numbers[0])
        case 1:
            self.init(lowerBound: numbers[0], upperBound: numbers[0])
        default:
            self.init(
                lowerBound: Swift.min(numbers[0], numbers[1]),
                upperBound: Swift.max(numbers[0], numbers[1])
            )
        }
    }

    private static func number(from token: String, scale: Double) -> Double? {
        let trimmed = token.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        let isDecimalFraction: Bool
        if scale > 1, let dot = trimmed.lastIndex(of: ".") {
            let fraction = trimmed[trimmed.index(after: dot)...]
            isDecimalFraction = (1...2).contains(fraction.count)
                && fraction.allSatisfy(\.isNumber)
        } else {
            isDecimalFraction = false
        }

        let normalized = isDecimalFraction
            ? trimmed
            : trimmed.replacingOccurrences(of: ".", with: "")

        guard let value = Double(normalized) else { return nil }
        return value * scale
    }


    func fits(within budget: PriceRange) -> Bool {
        let ourLow = lowerBound ?? -.greatestFiniteMagnitude
        let ourHigh = upperBound ?? .greatestFiniteMagnitude
        let budgetLow = budget.lowerBound ?? -.greatestFiniteMagnitude
        let budgetHigh = budget.upperBound ?? .greatestFiniteMagnitude
        return ourLow >= budgetLow && ourHigh <= budgetHigh
    }
}

extension Place {
    /// `nil` when the place has no usable price information.
    var priceRange: PriceRange? { PriceRange(parsing: rangeHarga) }

    /// A spoken alternative to abbreviated visual prices such as
    /// `Rp 25–50 rb`, which VoiceOver otherwise reads symbol by symbol.
    var accessibilityPriceRangeDescription: String {
        guard let priceRange else { return rangeHarga }

        switch (priceRange.lowerBound, priceRange.upperBound) {
        case let (lower?, upper?) where lower == upper:
            return String(
                format: String(localized: "%@ rupiah"),
                Self.spokenCurrencyAmount(lower)
            )
        case let (lower?, upper?):
            return String(
                format: String(localized: "Price range from %@ to %@ rupiah"),
                Self.spokenCurrencyAmount(lower),
                Self.spokenCurrencyAmount(upper)
            )
        case let (nil, upper?):
            return String(
                format: String(localized: "Below %@ rupiah"),
                Self.spokenCurrencyAmount(upper)
            )
        case let (lower?, nil):
            return String(
                format: String(localized: "Above %@ rupiah"),
                Self.spokenCurrencyAmount(lower)
            )
        case (nil, nil):
            return rangeHarga
        }
    }

    private static func spokenCurrencyAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = .current
        return formatter.string(from: NSNumber(value: value)) ?? String(Int(value))
    }
}
