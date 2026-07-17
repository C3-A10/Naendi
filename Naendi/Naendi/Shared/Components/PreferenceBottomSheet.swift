import SwiftUI

struct PreferenceBottomSheet: View {
    @Binding var query: String
    @Binding var radius: Double

    let onSubmitSearch: () -> Void

    @State private var selectedBudgetOption: BudgetOption = .any
    @State private var minimumBudget = ""
    @State private var maximumBudget = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                locationControls
                radiusControl
                preferenceRows
            }
            .padding(.horizontal, 32)
            .padding(.top, 18)
            .padding(.bottom, 44)
        }
        .scrollIndicators(.hidden)
        .background(Color(uiColor: .systemBackground))
    }

    private var locationControls: some View {
        VStack(spacing: 0) {
            PreferenceSearchField(
                query: $query,
                placeholder: "Search"
            )
            .onSubmit(onSubmitSearch)
            .padding(.horizontal, 6)
            .padding(.top, 8)
            .padding(.bottom, 14)

            Label {
                Text("Your location")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "location.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color("color_green"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .frame(height: 48)

            Divider()
                .overlay(Color.primary.opacity(0.16))

            Text("Choose on map")
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 48)
                .frame(height: 48)
        }
    }

    private var radiusControl: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Custom local radius (km)")
                .font(.system(size: 16))
                .foregroundStyle(.primary)

            RadiusSlider(value: $radius, range: 0.5...10, step: 0.5)
        }
        .padding(.horizontal, 10)
    }

    private var preferenceRows: some View {
        VStack(spacing: 20) {
            BudgetRow(selection: $selectedBudgetOption)

            if selectedBudgetOption == .custom {
                CustomBudgetRow(
                    minimumBudget: $minimumBudget,
                    maximumBudget: $maximumBudget
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            PreferenceOptionRow(title: "Type", value: "Cafe")
            PreferenceOptionRow(title: "Vibe", value: "Lively")
            PreferenceOptionRow(title: "Preferred Time", value: "08:00  –  10:00")
            PreferenceOptionRow(title: "Halal", value: "Yes")
            PreferenceOptionRow(title: "Output Result", value: "5")
            PreferenceOptionRow(title: "Sort By", value: "Surprise Me")
        }
        .animation(.snappy(duration: 0.24), value: selectedBudgetOption)
    }
}

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
            PreferenceOptionRowContent(
                title: "Budget",
                value: selection.title,
                showsDisclosure: true
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Budget")
        .accessibilityValue(selection.title)
    }
}

struct PreferenceOptionRow: View {
    let title: String
    let value: String

    var body: some View {
        PreferenceOptionRowContent(
            title: title,
            value: value,
            showsDisclosure: true
        )
    }
}

private struct PreferenceOptionRowContent: View {
    let title: String
    let value: String
    let showsDisclosure: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 18))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 12)

            valueView

            if showsDisclosure {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.55))
            }
        }
        .padding(.horizontal, 28)
        .frame(height: 60)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
    }

    @ViewBuilder
    private var valueView: some View {
        if title == "Preferred Time" {
            HStack(spacing: 8) {
                Text("08:00")
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(Color(uiColor: .systemBackground).opacity(0.9))
                    .clipShape(Capsule())
                Text("-")
                Text("10:00")
                    .padding(.horizontal, 10)
                    .frame(height: 32)
                    .background(Color(uiColor: .systemBackground).opacity(0.9))
                    .clipShape(Capsule())
            }
            .font(.system(size: 18))
            .foregroundStyle(.secondary)
        } else {
            Text(value)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

private struct RadiusSlider: View {
    @Binding var value: Double

    let range: ClosedRange<Double>
    let step: Double

    private var progress: CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    var body: some View {
        GeometryReader { proxy in
            let trackWidth = proxy.size.width
            let knobSize: CGFloat = 24
            let knobX = max(0, min(trackWidth - knobSize, progress * (trackWidth - knobSize)))
            let labelX = max(18, min(trackWidth - 18, knobX + knobSize / 2))

            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(height: 5)
                    .offset(y: 8)

                Capsule()
                    .fill(Color("color_green"))
                    .frame(width: knobX + knobSize / 2, height: 5)
                    .offset(y: 8)

                Circle()
                    .fill(Color("color_green"))
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: knobX)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                updateValue(with: gesture.location.x, width: trackWidth, knobSize: knobSize)
                            }
                    )

                Text("0,5")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .offset(x: 0, y: 28)

                Text(value.formatted(.number.precision(.fractionLength(value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 1))))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36)
                    .offset(x: labelX - 18, y: 28)

                Text("10")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 22, alignment: .trailing)
                    .offset(x: trackWidth - 22, y: 28)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(with: gesture.location.x, width: trackWidth, knobSize: knobSize)
                    }
            )
        }
        .frame(height: 48)
    }

    private func updateValue(with xPosition: CGFloat, width: CGFloat, knobSize: CGFloat) {
        let usableWidth = max(width - knobSize, 1)
        let rawProgress = min(max((xPosition - knobSize / 2) / usableWidth, 0), 1)
        let rawValue = range.lowerBound + Double(rawProgress) * (range.upperBound - range.lowerBound)
        let steppedValue = (rawValue / step).rounded() * step
        value = min(max(steppedValue, range.lowerBound), range.upperBound)
    }
}

#Preview {
    @Previewable @State var query = ""
    @Previewable @State var radius = 1.0

    PreferenceBottomSheet(
        query: $query,
        radius: $radius,
        onSubmitSearch: { }
    )
}
