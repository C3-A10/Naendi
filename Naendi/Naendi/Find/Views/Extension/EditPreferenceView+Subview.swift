//
//  EditPreferenceView+Subview.swift
//  Naendi
//
//  Created by Bryan Samuel on 22/07/26.
//
import SwiftUI

// MARK: - Subviews

extension EditPreferenceView {

   
   var preferredTimeRange: String {
        let start = Self.timeFormatter.string(from: preferredStartTime)
        let end = Self.timeFormatter.string(from: preferredEndTime)
        return "\(start)  –  \(end)"
    }

    var preferredTimePicker: some View {
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

    func preferredTimeRow(
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

    var outputResultPicker: some View {
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

    var navigationHeader: some View {
        HStack(spacing: 16) {
            CircleIconButton(
                systemName: "chevron.left",
                accessibilityLabel: "Back",
                accessibilityInputLabels: ["Back"],
                backgroundColor: Color(.systemBackground)
            ) { dismiss() }

            Spacer(minLength: 0)

            Text("Edit Preference")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .foregroundColor(.black)

            Spacer(minLength: 0)

            CircleIconButton(
                systemName: "checkmark",
                accessibilityLabel: "Save preferences",
                accessibilityInputLabels: ["Save", "Save preferences"],
                backgroundColor: Color(.systemBackground)
            ) {
                onSave(editedCriteria)
                dismiss()
            }
            .disabled(!budgetViewModel.isBudgetValid)
            .opacity(budgetViewModel.isBudgetValid ? 1 : 0.5)
            .accessibilityHint(
                budgetViewModel.isBudgetValid
                    ? "Applies the selected preferences and returns to results."
                    : "Enter a valid custom budget range before saving."
            )
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }
}
