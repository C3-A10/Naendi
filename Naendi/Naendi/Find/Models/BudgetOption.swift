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
            "Any Budget"
        case .tenToFifty:
            "Rp. 10rb – Rp. 50rb"
        case .fiftyToOneHundred:
            "Rp. 50rb – Rp. 100rb"
        case .oneHundredToTwoFifty:
            "Rp. 100rb – Rp. 250rb"
        case .custom:
            "Custom"
        }
    }
}
