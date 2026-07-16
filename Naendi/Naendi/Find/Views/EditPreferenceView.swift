import SwiftUI

struct EditPreferenceView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                placeholder(
                    title: "Search",
                    systemImage: "magnifyingglass",
                    height: 72
                )

                placeholder(
                    title: "Map",
                    systemImage: "map",
                    height: 320
                )

                Spacer(minLength: 0)

                placeholder(
                    title: "Bottom Sheet",
                    systemImage: "rectangle.bottomhalf.inset.filled",
                    height: 180
                )
            }
            .padding()
            .navigationTitle("Edit Preferences")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { }
                }
            }
        }
    }

    private func placeholder(
        title: String,
        systemImage: String,
        height: CGFloat
    ) -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.secondary.opacity(0.12))
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    EditPreferenceView()
}
