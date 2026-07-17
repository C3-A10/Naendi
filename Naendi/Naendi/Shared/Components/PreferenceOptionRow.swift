import SwiftUI

struct PreferenceOptionRow: View {
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
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 18))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 12)

            valueView

            if showsDisclosure {
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.55))
            }
        }
        .padding(.horizontal, 28)
        .frame(height: 60)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.85), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
    }

    @ViewBuilder
    private var valueView: some View {
        if title == "Preferred Time" {
            HStack(spacing: 8) {
                timeValue("08:00")
                Text("-")
                timeValue("10:00")
            }
            .font(.system(size: 18))
            .foregroundStyle(.secondary)
        } else {
            Text(value)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    private func timeValue(_ value: String) -> some View {
        Text(value)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(Color(uiColor: .systemBackground).opacity(0.9))
            .clipShape(Capsule())
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
