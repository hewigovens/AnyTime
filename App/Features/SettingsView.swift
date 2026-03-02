import AnyTimeCore
import StoreKit
import SwiftUI

struct SettingsView: View {
    @Bindable var store: WorldClockStore
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        Form {
            Section("Display") {
                Picker(selection: $store.labelStyle) {
                    ForEach(ClockLabelStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                } label: {
                    SettingsRowLabel(
                        title: "Primary label",
                        systemImage: "textformat.alt",
                        tint: AppTheme.actionBlue
                    )
                }

                Picker(selection: $store.dateStyle) {
                    ForEach(ClockDateStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                } label: {
                    SettingsRowLabel(
                        title: "Clock format",
                        systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                        tint: AppTheme.accent
                    )
                }

                LabeledContent {
                    Text(store.dateStyle.formatted(date: store.referenceDate, in: store.referenceTimeZone))
                        .font(.subheadline.weight(.medium))
                        .monospacedDigit()
                } label: {
                    SettingsRowLabel(
                        title: "Preview",
                        systemImage: "eye",
                        tint: AppTheme.magic
                    )
                }
            }

            Section("About") {
                LabeledContent {
                    Text(Bundle.main.releaseVersion)
                } label: {
                    SettingsRowLabel(
                        title: "Version",
                        systemImage: "app.badge",
                        tint: AppTheme.actionBlue
                    )
                }

                Button {
                    guard let reviewURL = URL(string: Self.appStoreReviewURL) else {
                        requestReview()
                        return
                    }
                    openURL(reviewURL)
                } label: {
                    SettingsRowLabel(
                        title: "Rate on App Store",
                        systemImage: "star.bubble",
                        tint: AppTheme.warm
                    )
                }
            }

            Section("Reset") {
                Button(role: .destructive) {
                    store.restoreDefaults()
                } label: {
                    SettingsRowLabel(
                        title: "Restore Default",
                        systemImage: "arrow.counterclockwise.circle",
                        tint: .red
                    )
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SettingsRowLabel: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(tint.opacity(0.14))
                )

            Text(title)
        }
    }
}

private extension Bundle {
    var releaseVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

private extension SettingsView {
    static let appStoreReviewURL = "https://apps.apple.com/us/app/anytime-timezone-calculator/id1291735859?action=write-review"
}
