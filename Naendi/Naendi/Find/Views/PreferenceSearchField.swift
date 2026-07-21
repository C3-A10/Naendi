import SwiftUI

struct PreferenceSearchField: View {
    @Binding var query: String

    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $query)
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .accessibilityLabel("Search location")
                .accessibilityHint("Enter a city, place, or address.")

            if !query.isEmpty {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .accessibilityHidden(true)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
                .accessibilityInputLabels(["Clear search", "Clear"])
            }
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 54)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
    }
}

#Preview {
    @Previewable @State var query = "Coffee"

    PreferenceSearchField(
        query: $query,
        placeholder: "Search preferences"
    )
    .padding()
}
