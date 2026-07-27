import Testing
@testable import Naendi

@Suite("Budget preference")
struct EditPreferenceViewModelTests {
    @Test("The default selection is Any Budget")
    func defaultBudgetSelection() {
        let viewModel = EditPreferenceViewModel()

        #expect(viewModel.selectedBudgetOption == .any)
    }

    @Test("Custom can be selected")
    func selectingCustomBudget() {
        let viewModel = EditPreferenceViewModel()

        viewModel.selectedBudgetOption = .custom

        #expect(viewModel.selectedBudgetOption == .custom)
    }

    @Test("The custom row is visible only for Custom", arguments: BudgetOption.allCases)
    func customRowVisibility(option: BudgetOption) {
        let viewModel = EditPreferenceViewModel(selectedBudgetOption: option)

        #expect(viewModel.isCustomBudgetRowVisible == (option == .custom))
    }

    @Test(
        "Valid custom budget ranges are accepted",
        arguments: [
            ("0", "0"),
            ("10000", "25000"),
            ("10.000", "25.000")
        ]
    )
    func validCustomBudget(minimum: String, maximum: String) {
        let viewModel = EditPreferenceViewModel(
            selectedBudgetOption: .custom,
            minimumBudget: minimum,
            maximumBudget: maximum
        )

        #expect(viewModel.isBudgetValid)
    }

    @Test(
        "Incomplete or nonnumeric custom budgets are invalid",
        arguments: [
            ("", "25000"),
            ("10000", ""),
            ("ten", "25000"),
            ("10000", "many")
        ]
    )
    func invalidCustomBudget(minimum: String, maximum: String) {
        let viewModel = EditPreferenceViewModel(
            selectedBudgetOption: .custom,
            minimumBudget: minimum,
            maximumBudget: maximum
        )

        #expect(!viewModel.isBudgetValid)
    }

    @Test("Minimum budget cannot exceed maximum budget")
    func minimumCannotExceedMaximum() {
        let viewModel = EditPreferenceViewModel(
            selectedBudgetOption: .custom,
            minimumBudget: "50.000",
            maximumBudget: "25.000"
        )

        #expect(!viewModel.isBudgetValid)
        #expect(
            viewModel.budgetValidationMessage
                == String(localized: "Minimum budget must not exceed maximum budget.")
        )
    }

    @Test("Equal minimum and maximum budgets are valid")
    func equalMinimumAndMaximumAreValid() {
        let viewModel = EditPreferenceViewModel(
            selectedBudgetOption: .custom,
            minimumBudget: "25.000",
            maximumBudget: "25.000"
        )

        #expect(viewModel.isBudgetValid)
        #expect(viewModel.budgetValidationMessage == nil)
    }

    @Test(
        "Negative custom budget values are invalid",
        arguments: [
            ("-1", "25000"),
            ("10000", "-1"),
            ("-10000", "-1")
        ]
    )
    func negativeValuesAreInvalid(minimum: String, maximum: String) {
        let viewModel = EditPreferenceViewModel(
            selectedBudgetOption: .custom,
            minimumBudget: minimum,
            maximumBudget: maximum
        )

        #expect(!viewModel.isBudgetValid)
    }

    @Test("Preset budgets do not require custom values", arguments: BudgetOption.allCases.filter { $0 != .custom })
    func presetBudgetsDoNotRequireCustomValues(option: BudgetOption) {
        let viewModel = EditPreferenceViewModel(selectedBudgetOption: option)

        #expect(viewModel.isBudgetValid)
    }

    @Test("Leaving Custom hides its row and preserves entered values")
    func switchingAwayFromCustomPreservesValues() {
        let viewModel = EditPreferenceViewModel(
            selectedBudgetOption: .custom,
            minimumBudget: "10.000",
            maximumBudget: "25.000"
        )

        viewModel.selectedBudgetOption = .tenToFifty

        #expect(!viewModel.isCustomBudgetRowVisible)
        #expect(viewModel.minimumBudget == "10.000")
        #expect(viewModel.maximumBudget == "25.000")
    }
}
