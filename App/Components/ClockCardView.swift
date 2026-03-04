import SwiftUI
import AnyTimeCore

struct ClockCardView: View, Equatable {
    let presentation: ClockPresentation
    let isCurrentLocation: Bool
    let currentLocationCityName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(presentation.title)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundStyle(.primary)

                        if isCurrentLocation {
                            Image(systemName: "location.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(AppTheme.magic)
                                .padding(8)
                                .background(AppTheme.magic.opacity(0.18), in: Capsule())
                                .accessibilityLabel(currentLocationAccessibilityLabel)
                        }
                    }

                    Text(presentation.subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 6) {
                    Text(presentation.formattedTime)
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(.primary)

                    if let dayText = presentation.dayText {
                        Text(dayText)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(AppTheme.accent)
                    }
                }
            }

            ViewThatFits {
                HStack(spacing: 8) {
                    ClockChip(text: presentation.utcOffsetText)
                    ClockChip(text: presentation.comparisonText, tint: AppTheme.accent)
                }

                VStack(alignment: .leading, spacing: 8) {
                    ClockChip(text: presentation.utcOffsetText)
                    ClockChip(text: presentation.comparisonText, tint: AppTheme.accent)
                }
            }
        }
        .padding(18)
        .background(AppTheme.clockSurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(
                    presentation.isReference ? AppTheme.warm.opacity(0.9) : AppTheme.cardStroke,
                    lineWidth: presentation.isReference ? 1.5 : 1
                )
        }
        .shadow(color: AppTheme.shadow, radius: 10, y: 4)
    }

    private var currentLocationAccessibilityLabel: String {
        guard let currentLocationCityName, currentLocationCityName.isEmpty == false else {
            return "Matches your current location time zone"
        }

        return "Matches your current location time zone in \(currentLocationCityName)"
    }
}

private struct ClockChip: View {
    @Environment(\.colorScheme) private var colorScheme
    let text: String
    var tint: Color = AppTheme.ink

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(tint.opacity(colorScheme == .dark ? 0.20 : 0.12), in: Capsule())
            .foregroundStyle(tint)
    }
}
