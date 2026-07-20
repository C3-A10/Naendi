//
//  PriceRange.swift
//  Naendi
//
//  Parses the free-form `range_harga` strings from the dataset into a numeric
//  range so budget preferences can be matched against them.
//

import Foundation

/// A price band in rupiah. An open end means "unbounded in that direction",
/// which is how `"Rp 250.000+"` is represented.
struct PriceRange: Equatable {
    let lowerBound: Double?
    let upperBound: Double?

    init(lowerBound: Double?, upperBound: Double?) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }

    /// Returns `nil` when the string is empty or carries no parseable number.
    /// Roughly 21% of the dataset has an empty `range_harga`, and callers treat
    /// that as "price unknown" rather than as a non-match.
    init?(parsing raw: String) {
        let text = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !text.isEmpty else { return nil }

        let isOpenEndedAbove = text.contains("+") || text.contains("di atas")
        let isOpenEndedBelow = text.contains("di bawah")

        // A "rb"/"jt" suffix scales every number in the string, so
        // "Rp 25–50 rb" is 25_000...50_000 rather than 25...50_000.
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

        // The dataset uses an en-dash (U+2013); accept a plain hyphen too.
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

        // A dot is a thousands separator ("250.000") unless a scale suffix is
        // present and it reads as a decimal fraction ("1.5 jt").
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

    /// Two bands match when they share any common price, not when one contains
    /// the other — a place priced "Rp 25–50 rb" satisfies a 10k–50k budget.
    func overlaps(_ other: PriceRange) -> Bool {
        let ourLow = lowerBound ?? -.greatestFiniteMagnitude
        let ourHigh = upperBound ?? .greatestFiniteMagnitude
        let theirLow = other.lowerBound ?? -.greatestFiniteMagnitude
        let theirHigh = other.upperBound ?? .greatestFiniteMagnitude
        return ourLow <= theirHigh && ourHigh >= theirLow
    }
}

extension Place {
    /// `nil` when the place has no usable price information.
    var priceRange: PriceRange? { PriceRange(parsing: rangeHarga) }
}
