import SwiftUI

struct SearchSuggestion: Identifiable, Hashable {
    let title: String
    let subtitle: String

    var id: String { "\(title)|\(subtitle)" }
}

struct PreferenceSearchField: View {
    @Binding var query: String

    var placeholder: String = "Search"
    var suggestions: [SearchSuggestion] = []
    var onSelectSuggestion: ((SearchSuggestion) -> Void)?

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            field

            if isFocused, !suggestions.isEmpty {
                suggestionList
            }
        }
    }

    private var field: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $query)
                .focused($isFocused)
                .font(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .accessibilityLabel("Search location")
                .accessibilityHint("Enter a place or address in Surabaya.")

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

    private var suggestionList: some View {
        VStack(spacing: 0) {
            ForEach(suggestions) { suggestion in
                Button {
                    isFocused = false
                    onSelectSuggestion?(suggestion)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(suggestion.title)
                            .font(.body)
                            .foregroundStyle(.primary)

                        if !suggestion.subtitle.isEmpty {
                            Text(suggestion.subtitle)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if suggestion != suggestions.last {
                    Divider().padding(.leading, 20)
                }
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
    }
}

#Preview {
    @Previewable @State var query = "Coffee"

    PreferenceSearchField(
        query: $query,
        placeholder: "Search preferences",
        suggestions: [
            SearchSuggestion(title: "Coffee Toffee", subtitle: "Jl. Raya Gubeng, Surabaya"),
            SearchSuggestion(title: "Kopi Kenangan", subtitle: "Tunjungan Plaza, Surabaya")
        ]
    ) { _ in }
    .padding()
}
