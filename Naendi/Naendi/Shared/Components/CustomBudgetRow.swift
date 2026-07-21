import SwiftUI

struct CustomBudgetRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var minimumBudget: String
    @Binding var maximumBudget: String

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case minimum
        case maximum
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 10) {
                    title
                    budgetFields
                }
            } else {
                HStack(spacing: 8) {
                    title
                    Spacer(minLength: 8)
                    budgetFields
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .frame(minHeight: 60)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
        .accessibilityElement(children: .contain)
    }

    private var title: some View {
        Text("Custom Budget")
            .font(.body)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
            .layoutPriority(1)
            .accessibilityHidden(true)
    }

    private var budgetFields: some View {
        HStack(spacing: 8) {
            budgetField(
                placeholder: "Min",
                accessibilityLabel: "Minimum budget",
                text: $minimumBudget,
                field: .minimum
            )

            Text("–")
                .font(.body)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            budgetField(
                placeholder: "Max",
                accessibilityLabel: "Maximum budget",
                text: $maximumBudget,
                field: .maximum
            )
        }
    }

    private func budgetField(
        placeholder: String,
        accessibilityLabel: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        TextField(placeholder, text: formattedText(text))
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focusedField, equals: field)
            .padding(.horizontal, 6)
            .frame(minWidth: 72, minHeight: 44)
            .background(Color(uiColor: .systemBackground).opacity(0.9))
            .clipShape(Capsule())
            .contentShape(Capsule())
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityAmount(from: text.wrappedValue))
    }

    private func accessibilityAmount(from text: String) -> String {
        let digits = text.filter(\.isNumber)
        guard let amount = Int(digits), !digits.isEmpty else {
            return "Not entered"
        }

        return "\(Self.spellOutFormatter.string(from: NSNumber(value: amount)) ?? String(amount)) rupiah"
    }

    private func formattedText(_ text: Binding<String>) -> Binding<String> {
        Binding(
            get: { text.wrappedValue },
            set: { newValue in
                text.wrappedValue = Self.formattedDigits(from: newValue)
            }
        )
    }

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static let spellOutFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = Locale(identifier: "en")
        return formatter
    }()

    private static func formattedDigits(from value: String) -> String {
        let digits = value.filter(\.isNumber)

        guard let number = Int(digits), !digits.isEmpty else {
            return ""
        }

        return formatter.string(from: NSNumber(value: number)) ?? digits
    }
}

#Preview {
    @Previewable @State var minimumBudget = "10.000"
    @Previewable @State var maximumBudget = "25.000"

    CustomBudgetRow(
        minimumBudget: $minimumBudget,
        maximumBudget: $maximumBudget
    )
    .padding(.horizontal, 32)
    .padding(.vertical, 24)
    .background(Color(uiColor: .systemBackground))
}
