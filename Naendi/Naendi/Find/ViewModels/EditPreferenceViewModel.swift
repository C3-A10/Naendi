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
//        false
        selectedBudgetOption == .custom
    }

    var isBudgetValid: Bool {
        guard selectedBudgetOption == .custom else {
            return true
        }

        guard let minimum = Self.budgetValue(from: minimumBudget),
              let maximum = Self.budgetValue(from: maximumBudget) else {
            return false
        }

        return minimum >= 0 && maximum >= 0 && minimum <= maximum
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
