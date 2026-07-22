import MapKit
import SwiftUI

/// Edits a copy of the user's preferences. Everything lives in local state so
/// Back can discard cleanly; only Save hands the result back to the caller,
/// which is what persists it and re-runs the search.
struct EditPreferenceView: View {
    /// Shown in the Type and Vibe menus for "don't filter on this".
    private static let anyOption = "Any"
    private static let locationPlaceholder = String(localized: "Search Location")
    /// Surabaya city centre — the app's whole dataset is here.
    private static let defaultCoordinate = CLLocationCoordinate2D(
        latitude: -7.2575,
        longitude: 112.7521
    )

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let budgetFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private enum PreferredTimeField {
        case start
        case end
    }

    @Environment(\.dismiss) private var dismiss

    private let onSave: (PreferenceCriteria) -> Void

    @State private var isSelectingLocation = false
    @State private var selectedLocationName: String
    @State private var selectedCoordinate: CLLocationCoordinate2D
    @State private var radius: Double
    @State private var budgetViewModel: EditPreferenceViewModel
    @State private var selectedType: String
    @State private var selectedVibe: String
    @State private var selectedHalalOption: HalalPreference
    @State private var isSelectingOutputResult = false
    @State private var outputResult: Int
    @State private var selectedSortOption: SortOption
    @State private var isSelectingPreferredTime = false
    @State private var activePreferredTimeField: PreferredTimeField = .start
    @State private var preferredStartTime: Date
    @State private var preferredEndTime: Date

    init(
        criteria: PreferenceCriteria = .default,
        onSave: @escaping (PreferenceCriteria) -> Void
    ) {
        self.onSave = onSave
        _selectedLocationName = State(initialValue: criteria.locationName ?? Self.locationPlaceholder)
        _selectedCoordinate = State(
            initialValue: criteria.coordinate?.clCoordinate ?? Self.defaultCoordinate
        )
        _radius = State(initialValue: criteria.radiusKm)
        _budgetViewModel = State(
            initialValue: EditPreferenceViewModel(
                selectedBudgetOption: criteria.budget,
                minimumBudget: Self.budgetText(criteria.customMinBudget),
                maximumBudget: Self.budgetText(criteria.customMaxBudget)
            )
        )
        _selectedType = State(initialValue: criteria.type ?? Self.anyOption)
        _selectedVibe = State(initialValue: criteria.vibe ?? Self.anyOption)
        _selectedHalalOption = State(initialValue: criteria.halal)
        _outputResult = State(initialValue: criteria.outputResult)
        _selectedSortOption = State(initialValue: criteria.sortBy)
        _preferredStartTime = State(initialValue: Self.date(fromMinutes: criteria.startMinutes))
        _preferredEndTime = State(initialValue: Self.date(fromMinutes: criteria.endMinutes))
    }

    private let typeOptions = [
        EditPreferenceView.anyOption,
        "Restaurant",
        "Cafe",
        "Warkop",
        "PKL",
        "Drinks",
        "Bakery"
    ]

    private let vibeOptions = [
        EditPreferenceView.anyOption,
        "Calm",
        "Balanced",
        "Lively"
    ]

    var body: some View {
        VStack(spacing: 0) {
            navigationHeader

            ScrollView {
                VStack(spacing: 20) {
                    Button {
                        isSelectingLocation = true
                    } label: {
                        PreferenceOptionRow(
                            title: "Location",
                            value: selectedLocationName,
                            showsDisclosure: false
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Location")
                    .accessibilityValue(selectedLocationName)
                    .accessibilityHint("Double-tap to choose a location and search radius.")

                    BudgetRow(selection: $budgetViewModel.selectedBudgetOption)

                    if budgetViewModel.isCustomBudgetRowVisible {
                        CustomBudgetRow(
                            minimumBudget: $budgetViewModel.minimumBudget,
                            maximumBudget: $budgetViewModel.maximumBudget
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Menu {
                        ForEach(typeOptions, id: \.self) { type in
                            Button {
                                selectedType = type
                            } label: {
                                if selectedType == type {
                                    Label(localizedPreferenceValue(type), systemImage: "checkmark")
                                } else {
                                    Text(localizedPreferenceValue(type))
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(
                            title: "Type",
                            value: localizedPreferenceValue(selectedType)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Type")
                    .accessibilityValue(localizedPreferenceValue(selectedType))
                    .accessibilityHint("Double tap to choose a place type")
                    Menu {
                        ForEach(vibeOptions, id: \.self) { vibe in
                            Button {
                                selectedVibe = vibe
                            } label: {
                                if selectedVibe == vibe {
                                    Label(localizedPreferenceValue(vibe), systemImage: "checkmark")
                                } else {
                                    Text(localizedPreferenceValue(vibe))
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(
                            title: "Vibe",
                            value: localizedPreferenceValue(selectedVibe)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Vibe")
                    .accessibilityValue(localizedPreferenceValue(selectedVibe))
                    .accessibilityHint("Double tap to choose a vibe")
                    Button {
                        isSelectingPreferredTime = true
                    } label: {
                        PreferenceOptionRow(
                            title: "Preferred Time",
                            value: preferredTimeRange
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Preferred Time")
                    .accessibilityValue(preferredTimeRange)
                    .accessibilityHint("Double tap to choose start and end times")
                    Menu {
                        ForEach(HalalPreference.allCases, id: \.self) { option in
                            Button {
                                selectedHalalOption = option
                            } label: {
                                if selectedHalalOption == option {
                                    Label(option.title, systemImage: "checkmark")
                                } else {
                                    Text(option.title)
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(
                            title: "Halal",
                            value: selectedHalalOption.title
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Halal preference")
                    .accessibilityValue(selectedHalalOption.title)
                    .accessibilityHint("Double tap to choose a halal preference")
                    Button {
                        isSelectingOutputResult = true
                    } label: {
                        PreferenceOptionRow(
                            title: "Output Result",
                            value: String(outputResult)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Output Result")
                    .accessibilityValue("\(outputResult) places")
                    .accessibilityHint("Double tap to choose the number of results")
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                selectedSortOption = option
                            } label: {
                                if selectedSortOption == option {
                                    Label(option.title, systemImage: "checkmark")
                                } else {
                                    Text(option.title)
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(
                            title: "Sort By",
                            value: selectedSortOption.title
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Sort By")
                    .accessibilityValue(selectedSortOption.title)
                    .accessibilityHint("Double tap to choose a sorting option")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .animation(.snappy(duration: 0.24), value: budgetViewModel.selectedBudgetOption)
            }
            .scrollIndicators(.hidden)
        }
        .fullScreenCover(isPresented: $isSelectingLocation) {
            SelectLocationView(
                selectedLocationName: $selectedLocationName,
                selectedCoordinate: $selectedCoordinate,
                radius: $radius
            )
        }
        .sheet(isPresented: $isSelectingPreferredTime) {
            preferredTimePicker
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isSelectingOutputResult) {
            outputResultPicker
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .background {
            GreenBlurBackground()
        }
    }

    // MARK: - Criteria conversion

    /// The placeholder is still showing when the user never picked a location,
    /// in which case matching falls back to their GPS position.
    private var hasSelectedLocation: Bool {
        selectedLocationName != Self.locationPlaceholder
    }

    private var editedCriteria: PreferenceCriteria {
        PreferenceCriteria(
            locationName: hasSelectedLocation ? selectedLocationName : nil,
            coordinate: hasSelectedLocation ? Coordinate(selectedCoordinate) : nil,
            radiusKm: radius,
            budget: budgetViewModel.selectedBudgetOption,
            customMinBudget: Self.budgetValue(budgetViewModel.minimumBudget),
            customMaxBudget: Self.budgetValue(budgetViewModel.maximumBudget),
            type: selectedType == Self.anyOption ? nil : selectedType,
            vibe: selectedVibe == Self.anyOption ? nil : selectedVibe,
            startMinutes: Self.minutes(from: preferredStartTime),
            endMinutes: Self.minutes(from: preferredEndTime),
            halal: selectedHalalOption,
            outputResult: outputResult,
            sortBy: selectedSortOption
        )
    }

    private static func date(fromMinutes minutes: Int) -> Date {
        Calendar.current.date(
            bySettingHour: minutes / 60,
            minute: minutes % 60,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    private static func minutes(from date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    private static func budgetText(_ value: Double?) -> String {
        guard let value, value > 0 else { return "" }
        return budgetFormatter.string(from: NSNumber(value: Int(value))) ?? ""
    }

    private func localizedPreferenceValue(_ value: String) -> String {
        switch value {
        case "Any":
            String(localized: "Any")
        case "Restaurant":
            String(localized: "Restaurant")
        case "Cafe":
            String(localized: "Cafe")
        case "Warkop":
            String(localized: "Warkop")
        case "PKL":
            String(localized: "PKL")
        case "Drinks":
            String(localized: "Drinks")
        case "Bakery":
            String(localized: "Bakery")
        case "Calm":
            String(localized: "Calm")
        case "Balanced":
            String(localized: "Balanced")
        case "Lively":
            String(localized: "Lively")
        default:
            value
        }
    }

    /// Mirrors CustomBudgetRow's grouped formatting by ignoring separators.
    private static func budgetValue(_ text: String) -> Double? {
        let digits = text.filter(\.isNumber)
        guard !digits.isEmpty, let value = Int(digits) else { return nil }
        return Double(value)
    }

    // MARK: - Subviews

    private var preferredTimeRange: String {
        let start = Self.timeFormatter.string(from: preferredStartTime)
        let end = Self.timeFormatter.string(from: preferredEndTime)
        return "\(start)  –  \(end)"
    }

    private var preferredTimePicker: some View {
        NavigationStack {
            VStack(spacing: 0) {
                preferredTimeRow(
                    title: "Starts",
                    time: preferredStartTime,
                    field: .start
                )

                Divider()
                    .padding(.leading, 20)

                preferredTimeRow(
                    title: "Ends",
                    time: preferredEndTime,
                    field: .end
                )

                Divider()

                Group {
                    if activePreferredTimeField == .start {
                        DatePicker(
                            "Start Time",
                            selection: $preferredStartTime,
                            displayedComponents: .hourAndMinute
                        )
                    } else {
                        DatePicker(
                            "End Time",
                            selection: $preferredEndTime,
                            in: preferredStartTime...,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .clipped()

                Spacer(minLength: 0)
            }
            .navigationTitle("Preferred Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isSelectingPreferredTime = false
                    }
                }
            }
            .onChange(of: preferredStartTime) { _, newStartTime in
                if preferredEndTime < newStartTime {
                    preferredEndTime = newStartTime
                }
            }
        }
    }

    private func preferredTimeRow(
        title: String,
        time: Date,
        field: PreferredTimeField
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                activePreferredTimeField = field
            }
        } label: {
            HStack {
                Text(LocalizedStringKey(title))
                    .foregroundStyle(.primary)

                Spacer()

                Text(time.formatted(date: .omitted, time: .shortened))
                    .foregroundStyle(activePreferredTimeField == field ? .red : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(
                        activePreferredTimeField == field
                            ? Color.red.opacity(0.12)
                            : Color(uiColor: .secondarySystemFill),
                        in: Capsule()
                    )
            }
            .font(.body)
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(time.formatted(date: .omitted, time: .shortened))
        .accessibilityAddTraits(activePreferredTimeField == field ? .isSelected : [])
    }

    private var outputResultPicker: some View {
        NavigationStack {
            Picker("Output Result", selection: $outputResult) {
                ForEach(3...10, id: \.self) { result in
                    Text("\(result)")
                        .tag(result)
                }
            }
            .pickerStyle(.wheel)
            .accessibilityLabel("Number of results")
            .navigationTitle("Output Result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isSelectingOutputResult = false
                    }
                }
            }
        }
    }

    private var navigationHeader: some View {
        VStack(spacing: 14) {
            HStack {
                CircleIconButton(
                    systemName: "chevron.left",
                    accessibilityLabel: "Back",
                    accessibilityInputLabels: ["Back"],
                    backgroundColor: Color(.systemBackground)
                ) { dismiss() }
                .accessibilitySortPriority(3)

                Spacer()

                CircleIconButton(
                    systemName: "checkmark",
                    accessibilityLabel: "Save preferences",
                    accessibilityInputLabels: ["Save", "Save preferences"],
                    backgroundColor: Color(.systemBackground)
                ) {
                    onSave(editedCriteria)
                    dismiss()
                }
                .accessibilityHint("Applies the selected preferences and returns to results.")
                .accessibilitySortPriority(1)
            }

            Text("Edit Preference")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .accessibilitySortPriority(2)
                .foregroundColor(.black)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}

#Preview {
    EditPreferenceView(criteria: .default) { _ in }
}
