import SwiftUI

struct BudgetOption: Identifiable, Hashable {
    let id: String
    let title: String

    static let any = BudgetOption(id: "any", title: "Any Budget")
    static let tenToFifty = BudgetOption(id: "10_50", title: "Rp. 10rb – Rp. 50rb")
    static let fiftyToOneHundred = BudgetOption(id: "50_100", title: "Rp. 50rb – Rp. 100rb")
    static let oneHundredToTwoFifty = BudgetOption(id: "100_250", title: "Rp. 100rb – Rp. 250rb")
    static let custom = BudgetOption(id: "custom", title: "Custom")

    static let allCases: [BudgetOption] = [
        .any,
        .tenToFifty,
        .fiftyToOneHundred,
        .oneHundredToTwoFifty,
        .custom
    ]
}

struct BudgetRow: View {
    @Binding var selection: BudgetOption

    var body: some View {
        Menu {
            ForEach(BudgetOption.allCases) { option in
                Button {
                    selection = option
                } label: {
                    Label(
                        option.title,
                        systemImage: selection == option ? "checkmark" : ""
                    )
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
