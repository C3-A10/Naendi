import MapKit
import SwiftUI

struct EditPreferenceView: View {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private enum PreferredTimeField {
        case start
        case end
    }

    @Environment(\.dismiss) private var dismiss

    @State private var isSelectingLocation = false
    @State private var selectedLocationName = "Search Location"
    @State private var selectedCoordinate = CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787)
    @State private var radius = 1.0
    @State private var viewModel = EditPreferenceViewModel()
    @State private var selectedType = "Cafe"
    @State private var selectedVibe = "Lively"
    @State private var selectedHalalOption = "Halal"
    @State private var isSelectingOutputResult = false
    @State private var outputResult = 5
    @State private var selectedSortOption = "Surprise Me"
    @State private var isSelectingPreferredTime = false
    @State private var activePreferredTimeField: PreferredTimeField = .start
    @State private var preferredStartTime = Calendar.current.date(
        bySettingHour: 8,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date()
    @State private var preferredEndTime = Calendar.current.date(
        bySettingHour: 10,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date()

    private let typeOptions = [
        "Restaurant",
        "Cafe",
        "Warkop",
        "PKL",
        "Drinks",
        "Bakery"
    ]

    private let vibeOptions = ["Calm", "Balanced", "Lively"]
    private let halalOptions = ["Halal", "Non-halal", "Any"]
    private let sortOptions = ["Surprise Me", "Distance"]

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

                    BudgetRow(selection: $viewModel.selectedBudgetOption)

                    if viewModel.isCustomBudgetRowVisible {
                        CustomBudgetRow(
                            minimumBudget: $viewModel.minimumBudget,
                            maximumBudget: $viewModel.maximumBudget
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Menu {
                        ForEach(typeOptions, id: \.self) { type in
                            Button {
                                selectedType = type
                            } label: {
                                if selectedType == type {
                                    Label(type, systemImage: "checkmark")
                                } else {
                                    Text(type)
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(title: "Type", value: selectedType)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Type")
                    .accessibilityValue(selectedType)
                    .accessibilityHint("Double tap to choose a place type")
                    Menu {
                        ForEach(vibeOptions, id: \.self) { vibe in
                            Button {
                                selectedVibe = vibe
                            } label: {
                                if selectedVibe == vibe {
                                    Label(vibe, systemImage: "checkmark")
                                } else {
                                    Text(vibe)
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(title: "Vibe", value: selectedVibe)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Vibe")
                    .accessibilityValue(selectedVibe)
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
                        ForEach(halalOptions, id: \.self) { option in
                            Button {
                                selectedHalalOption = option
                            } label: {
                                if selectedHalalOption == option {
                                    Label(option, systemImage: "checkmark")
                                } else {
                                    Text(option)
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(
                            title: "Halal",
                            value: selectedHalalOption
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Halal preference")
                    .accessibilityValue(selectedHalalOption)
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
                        ForEach(sortOptions, id: \.self) { option in
                            Button {
                                selectedSortOption = option
                            } label: {
                                if selectedSortOption == option {
                                    Label(option, systemImage: "checkmark")
                                } else {
                                    Text(option)
                                }
                            }
                        }
                    } label: {
                        PreferenceOptionRow(
                            title: "Sort By",
                            value: selectedSortOption
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Sort By")
                    .accessibilityValue(selectedSortOption)
                    .accessibilityHint("Double tap to choose a sorting option")
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .animation(.snappy(duration: 0.24), value: viewModel.selectedBudgetOption)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(uiColor: .systemBackground))
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
    }

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
                Text(title)
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
            .font(.system(size: 17))
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
                    accessibilityLabel: "Back"
                ) { dismiss() }

                Spacer()

                CircleIconButton(
                    systemName: "checkmark",
                    accessibilityLabel: "Save"
                ) { dismiss() }
            }

            Text("Edit Preference")
                .font(.system(size: 24, weight: .bold))
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}

#Preview {
    EditPreferenceView()
}
