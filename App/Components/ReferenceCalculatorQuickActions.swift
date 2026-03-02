import AnyTimeCore
import SwiftUI

struct QuickShift: Identifiable {
    let label: String
    let systemImage: String
    let role: QuickActionRole
    let performsPaste: Bool
    let action: (WorldClockStore) -> Void

    init(
        label: String,
        systemImage: String,
        role: QuickActionRole,
        performsPaste: Bool = false,
        action: @escaping (WorldClockStore) -> Void
    ) {
        self.label = label
        self.systemImage = systemImage
        self.role = role
        self.performsPaste = performsPaste
        self.action = action
    }

    var id: String {
        label
    }
}

struct QuickActionButtonStyle: ButtonStyle {
    let role: QuickActionRole

    func makeBody(configuration: Configuration) -> some View {
        let fill = fillColor
        let foreground = foregroundColor

        return configuration.label
            .foregroundStyle(foreground)
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                Capsule(style: .continuous)
                    .fill(fill.opacity(configuration.isPressed ? 0.82 : 1))
            )
            .overlay {
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(role == .warm ? 0.28 : 0.18), lineWidth: 1)
            }
            .shadow(
                color: fill.opacity(configuration.isPressed ? 0.08 : 0.24),
                radius: configuration.isPressed ? 6 : 10,
                y: configuration.isPressed ? 2 : 5
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private var fillColor: Color {
        switch role {
        case .cool:
            AppTheme.actionBlue
        case .warm:
            AppTheme.warm
        case .magic:
            AppTheme.magic
        }
    }

    private var foregroundColor: Color {
        switch role {
        case .cool, .magic:
            .white
        case .warm:
            AppTheme.warmInk
        }
    }
}

enum QuickActionRole {
    case cool
    case warm
    case magic
}
