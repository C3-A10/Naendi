import SwiftUI

struct PreferenceSearchField: View {
    @Binding var query: String

    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 22, weight: .regular))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $query)
                .font(.system(size: 17))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Button {
                query = ""
            } label: {
                Image(systemName: query.isEmpty ? "mic" : "xmark.circle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(query.isEmpty ? "Voice search" : "Clear search")
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
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
