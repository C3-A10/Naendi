import SwiftUI

struct RadiusSlider: View {
    @Binding var value: Double

    let range: ClosedRange<Double>
    let step: Double

    private var progress: CGFloat {
        CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    var body: some View {
        GeometryReader { proxy in
            let trackWidth = proxy.size.width
            let knobSize: CGFloat = 24
            let knobX = max(0, min(trackWidth - knobSize, progress * (trackWidth - knobSize)))
            let labelX = max(18, min(trackWidth - 18, knobX + knobSize / 2))

            ZStack(alignment: .topLeading) {
                Capsule()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(height: 5)
                    .offset(y: 8)

                Capsule()
                    .fill(Color("color_green"))
                    .frame(width: knobX + knobSize / 2, height: 5)
                    .offset(y: 8)

                Circle()
                    .fill(Color("color_green"))
                    .frame(width: knobSize, height: knobSize)
                    .offset(x: knobX)

                Text(formatted(range.lowerBound))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .offset(y: 28)
                    .opacity(labelX < 46 ? 0 : 1)
                    .animation(.easeInOut(duration: 0.15), value: labelX < 46)
                    .accessibilityHidden(true)

                Text(formattedValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36)
                    .offset(x: labelX - 18, y: 28)
                    .accessibilityHidden(true)

                Text(formatted(range.upperBound))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 22, alignment: .trailing)
                    .offset(x: trackWidth - 22, y: 28)
                    .opacity(labelX > trackWidth - 40 ? 0 : 1)
                    .animation(.easeInOut(duration: 0.15), value: labelX > trackWidth - 40)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(at: gesture.location.x, width: trackWidth, knobSize: knobSize)
                    }
            )
        }
        .frame(height: 48)
        .accessibilityRepresentation {
            Slider(value: $value, in: range, step: step) {
                Text("Maximum search radius")
            }
            .accessibilityValue(accessibilityValue)
            .accessibilityHint("Swipe up or down with one finger to adjust the radius.")
        }
    }

    private var formattedValue: String {
        formatted(value)
    }

    private var accessibilityValue: String {
        String(localized: "\(formattedValue) kilometers")
    }

    private func formatted(_ number: Double) -> String {
        return number.formatted(.number.precision(.fractionLength(0...2)))
    }

    private func updateValue(at xPosition: CGFloat, width: CGFloat, knobSize: CGFloat) {
        let usableWidth = max(width - knobSize, 1)
        let rawProgress = min(max((xPosition - knobSize / 2) / usableWidth, 0), 1)
        let rawValue = range.lowerBound + Double(rawProgress) * (range.upperBound - range.lowerBound)
        let steppedValue = (rawValue / step).rounded() * step
        value = min(max(steppedValue, range.lowerBound), range.upperBound)
    }
}

#Preview {
    @Previewable @State var radius = 1.0

    RadiusSlider(value: $radius, range: 0.25...10, step: 0.25)
        .padding(.horizontal, 32)
}
