import SwiftUI

struct CircleIconButton: View {
    let systemName: String
    let accessibilityLabel: String
    let accessibilityHint: String?
    let accessibilityInputLabels: [String]
    let foregroundColor: Color
    let backgroundColor: Color
    let size: CGFloat
    let action: () -> Void

    @ScaledMetric(relativeTo: .body) private var iconSize = 17
    @GestureState private var isPressed = false

    init(
        systemName: String,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        accessibilityInputLabels: [String]? = nil,
        foregroundColor: Color = .primary,
        backgroundColor: Color = .white,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.systemName = systemName
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.accessibilityInputLabels = accessibilityInputLabels ?? [accessibilityLabel]
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.size = max(size, 44)
        self.action = action
    }

    private var resolvedSize: CGFloat {
        max(size, iconSize + 24)
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(foregroundColor)
                .frame(width: resolvedSize, height: resolvedSize)
                .background {
                    Circle().fill(backgroundColor)
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.94 : 1)
        .opacity(isPressed ? 0.82 : 1)
        .shadow(
            color: .black.opacity(isPressed ? 0.08 : 0.14),
            radius: isPressed ? 3 : 7,
            y: isPressed ? 1 : 3
        )
        .animation(.smooth(duration: 0.18), value: isPressed)
        .simultaneousGesture(pressGesture)
        .accessibilityLabel(Text(accessibilityLabel))
        .accessibilityHint(Text(accessibilityHint ?? ""))
        .accessibilityInputLabels(accessibilityInputLabels.map(Text.init))
    }

    private var pressGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }
    }
}

#Preview {
    HStack(spacing: 20) {
        CircleIconButton(
            systemName: "chevron.left",
            accessibilityLabel: "Back"
        ) { }

        CircleIconButton(
            systemName: "checkmark",
            accessibilityLabel: "Save",
            foregroundColor: .black,
            backgroundColor: Color("color_green")
        ) { }
    }
    .padding()
    .background(Color(uiColor: .systemGroupedBackground))
}
