import SwiftUI

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
        .accessibilityValue(selection.accessibilityDescription)
        .accessibilityHint("Double-tap to choose a budget range.")
        .accessibilityInputLabels(["Budget"])
    }
}

#Preview {
    @Previewable @State var selection: BudgetOption = .any

    BudgetRow(selection: $selection)
        .padding(.horizontal, 32)
}
