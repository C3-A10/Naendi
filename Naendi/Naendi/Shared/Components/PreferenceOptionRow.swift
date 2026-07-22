import SwiftUI

struct PreferenceOptionRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let value: String
    let showsDisclosure: Bool

    init(
        title: String,
        value: String,
        showsDisclosure: Bool = true
    ) {
        self.title = title
        self.value = value
        self.showsDisclosure = showsDisclosure
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        titleView
                        Spacer(minLength: 8)
                        disclosureIndicator
                    }

                    valueView
                }
            } else {
                HStack(spacing: 8) {
                    titleView
                    Spacer(minLength: 8)
                    valueView
                    disclosureIndicator
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(minHeight: 60)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
    }

    private var titleView: some View {
        Text(title)
            .font(.body)
            .foregroundStyle(.primary)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    private var disclosureIndicator: some View {
        if showsDisclosure {
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary.opacity(0.55))
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    private var valueView: some View {
        if title == "Preferred Time" {
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(minHeight: 32)
                .background(Color(uiColor: .systemBackground).opacity(0.9))
                .clipShape(Capsule())
                .layoutPriority(1)
        } else {
            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
    }

}

#Preview {
    VStack(spacing: 20) {
        PreferenceOptionRow(title: "Type", value: "Cafe")
        PreferenceOptionRow(title: "Preferred Time", value: "08:00 – 10:00")
        PreferenceOptionRow(title: "Location", value: "Search Location", showsDisclosure: false)
    }
    .padding(.horizontal, 32)
}
