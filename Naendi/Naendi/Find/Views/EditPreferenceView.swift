import MapKit
import SwiftUI

struct EditPreferenceView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var isSelectingLocation = false
    @State private var selectedLocationName = "Search Location"
    @State private var selectedCoordinate = CLLocationCoordinate2D(latitude: 37.3377, longitude: -121.8787)
    @State private var radius = 1.0
    @State private var selectedBudgetOption: BudgetOption = .any
    @State private var minimumBudget = ""
    @State private var maximumBudget = ""

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
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.top, 8)
                .padding(.bottom, 40)
                .animation(.snappy(duration: 0.24), value: selectedBudgetOption)
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
