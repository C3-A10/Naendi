import SwiftUI

/// Raw values double as the persisted identifier in `UserPreference`, so they
/// must stay stable across releases.
enum BudgetOption: String, CaseIterable, Identifiable, Hashable {
    case any
    case tenToFifty = "10_50"
    case fiftyToOneHundred = "50_100"
    case oneHundredToTwoFifty = "100_250"
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .any: "Any Budget"
        case .tenToFifty: "Rp. 10rb – Rp. 50rb"
        case .fiftyToOneHundred: "Rp. 50rb – Rp. 100rb"
        case .oneHundredToTwoFifty: "Rp. 100rb – Rp. 250rb"
        case .custom: "Custom"
        }
    }

    /// `nil` where the option carries no fixed band: `.any` matches everything
    /// and `.custom` takes its bounds from the user's own min/max.
    var range: PriceRange? {
        switch self {
        case .any, .custom: nil
        case .tenToFifty: PriceRange(lowerBound: 10_000, upperBound: 50_000)
        case .fiftyToOneHundred: PriceRange(lowerBound: 50_000, upperBound: 100_000)
        case .oneHundredToTwoFifty: PriceRange(lowerBound: 100_000, upperBound: 250_000)
        }
    }
}

struct BudgetRow: View {
    @Binding var selection: BudgetOption

    var body: some View {
        Menu {
            ForEach(BudgetOption.allCases) { option in
                Button {
                    selection = option
                } label: {
                    if selection == option {
                        Label(option.title, systemImage: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        } label: {
            PreferenceOptionRow(
                title: "Budget",
                value: selection.title
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Budget")
        .accessibilityValue(selection.title)
    }
}

#Preview {
    @Previewable @State var selection: BudgetOption = .any

    BudgetRow(selection: $selection)
        .padding(.horizontal, 32)
}
