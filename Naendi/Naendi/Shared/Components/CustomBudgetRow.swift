import SwiftUI

struct CustomBudgetRow: View {
    @Binding var minimumBudget: String
    @Binding var maximumBudget: String

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case minimum
        case maximum
    }

    var body: some View {
        HStack(spacing: 6) {
            Text("Custom Budget")
                .font(.system(size: 18))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .layoutPriority(1)

            Spacer(minLength: 8)

            budgetField(
                placeholder: "Min",
                text: $minimumBudget,
                field: .minimum
            )

            Text("–")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)

            budgetField(
                placeholder: "Max",
                text: $maximumBudget,
                field: .maximum
            )
        }
        .padding(.horizontal, 18)
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
    }

    private func budgetField(
        placeholder: String,
        text: Binding<String>,
        field: Field
    ) -> some View {
        TextField(placeholder, text: formattedText(text))
            .font(.system(size: 18))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focusedField, equals: field)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 6)
            .frame(width: 56, height: 32)
            .background(Color(uiColor: .systemBackground).opacity(0.9))
            .clipShape(Capsule())
            .contentShape(Capsule())
            .accessibilityLabel(placeholder)
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
