import MapKit
import SwiftUI

/// Edits a copy of the user's preferences. Everything lives in local state so
/// Back can discard cleanly; only Save hands the result back to the caller,
/// which is what persists it and re-runs the search.
struct EditPreferenceView: View {
    @Environment(\.dismiss) var dismiss

    let onSave: (PreferenceCriteria) -> Void

    @State var isSelectingLocation = false
    @State var selectedLocationName: String
    @State var selectedCoordinate: CLLocationCoordinate2D
    @State var radius: Double
    @State var budgetViewModel: EditPreferenceViewModel
    @State var selectedType: String
    @State var selectedVibe: String
    @State var selectedHalalOption: HalalPreference
    @State var isSelectingOutputResult = false
    @State var outputResult: Int
    @State var selectedSortOption: SortOption
    @State var isSelectingPreferredTime = false
    @State var activePreferredTimeField: PreferredTimeField = .start
    @State var preferredStartTime: Date
    @State var preferredEndTime: Date

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
                        VStack(alignment: .leading, spacing: 8) {
                            CustomBudgetRow(
                                minimumBudget: $budgetViewModel.minimumBudget,
                                maximumBudget: $budgetViewModel.maximumBudget
                            )

                            if let validationMessage = budgetViewModel.budgetValidationMessage {
                                Text(validationMessage)
                                    .font(.footnote)
                                    .foregroundStyle(.red)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal, 18)
                                    .accessibilityLabel("Budget error")
                                    .accessibilityValue(validationMessage)
                            }
                        }
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

}

#Preview {
    EditPreferenceView(criteria: .default) { _ in }
}
