import Foundation

enum BudgetOption: String, CaseIterable, Identifiable, Hashable {
    case any
    case tenToFifty = "10_50"
    case fiftyToOneHundred = "50_100"
    case oneHundredToTwoFifty = "100_250"
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .any:
            String(localized: "Any Budget")
        case .tenToFifty:
            "Rp. 10rb – Rp. 50rb"
        case .fiftyToOneHundred:
            "Rp. 50rb – Rp. 100rb"
        case .oneHundredToTwoFifty:
            "Rp. 100rb – Rp. 250rb"
        case .custom:
            String(localized: "Custom")
        }
    }

    var accessibilityDescription: String {
        switch self {
        case .any:
            String(localized: "Any budget")
        case .tenToFifty:
            String(localized: "10 thousand to 50 thousand rupiah")
        case .fiftyToOneHundred:
            String(localized: "50 thousand to 100 thousand rupiah")
        case .oneHundredToTwoFifty:
            String(localized: "100 thousand to 250 thousand rupiah")
        case .custom:
            String(localized: "Custom")
        }
    }

    var range: PriceRange? {
        switch self {
        case .any, .custom:
            nil
        case .tenToFifty:
            PriceRange(lowerBound: 10_000, upperBound: 50_000)
        case .fiftyToOneHundred:
            PriceRange(lowerBound: 50_000, upperBound: 100_000)
        case .oneHundredToTwoFifty:
            PriceRange(lowerBound: 100_000, upperBound: 250_000)
        }
    }
}
