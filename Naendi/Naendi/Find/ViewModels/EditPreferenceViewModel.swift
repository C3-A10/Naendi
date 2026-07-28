import Foundation
import Observation

@Observable
final class EditPreferenceViewModel {
    var selectedBudgetOption: BudgetOption
    var minimumBudget: String
    var maximumBudget: String

    init(
        selectedBudgetOption: BudgetOption = .any,
        minimumBudget: String = "",
        maximumBudget: String = ""
    ) {
        self.selectedBudgetOption = selectedBudgetOption
        self.minimumBudget = minimumBudget
        self.maximumBudget = maximumBudget
    }

    var isCustomBudgetRowVisible: Bool {
        selectedBudgetOption == .custom
    }

    var isBudgetValid: Bool {
        budgetValidationMessage == nil
    }

    var budgetValidationMessage: String? {
        guard selectedBudgetOption == .custom else { return nil }

        guard !minimumBudget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !maximumBudget.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return String(localized: "Enter both minimum and maximum budget.")
        }

        guard let minimum = Self.budgetValue(from: minimumBudget),
              let maximum = Self.budgetValue(from: maximumBudget) else {
            return String(localized: "Enter a valid budget amount.")
        }

        guard minimum >= 0, maximum >= 0 else {
            return String(localized: "Budget cannot be negative.")
        }

        guard minimum <= maximum else {
            return String(localized: "Minimum budget must not exceed maximum budget.")
        }

        return nil
    }

    private static func budgetValue(from text: String) -> Int? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ".", with: "")

        guard !normalized.isEmpty else {
            return nil
        }

        return Int(normalized)
    }
}
