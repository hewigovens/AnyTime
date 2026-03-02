import SwiftUI

struct PullDownEasterEggView: View {
    let monitor: PullDownMonitor
    @State private var latchedPullDistance: CGFloat = 0
    @State private var releaseTask: Task<Void, Never>?

    private let panelRevealOffset: CGFloat = 200
    private let textRevealOffset: CGFloat = 104
    private let textRevealRange: CGFloat = 72
    private let latchThreshold: CGFloat = 122

    private var pullDistance: CGFloat {
        monitor.pullDistance
    }

    private var effectivePullDistance: CGFloat {
        max(pullDistance, latchedPullDistance)
    }

    private var revealProgress: CGFloat {
        max(0, min(1, (effectivePullDistance - textRevealOffset) / textRevealRange))
    }

    private var panelHeight: CGFloat {
        max(0, min(280, effectivePullDistance - panelRevealOffset))
    }

    var body: some View {
        GeometryReader { proxy in
            if panelHeight > 1 {
                VStack(spacing: 0) {
                    Text("Fine.")
                        .font(.system(.footnote, design: .rounded).weight(.medium))
                        .foregroundStyle(AppTheme.ink.opacity(0.56))
                        .padding(.top, proxy.safeAreaInsets.top + 16)
                        .opacity(revealProgress)

                    Spacer(minLength: 0)

                    Text("We're wasting time here.")
                        .font(.system(.headline, design: .rounded).weight(.semibold))
                        .foregroundStyle(AppTheme.ink.opacity(0.72))
                        .padding(.bottom, 28)
                        .opacity(revealProgress)
                }
                .frame(maxWidth: .infinity)
                .frame(height: panelHeight, alignment: .top)
                .background(
                    LinearGradient(
                        colors: [
                            AppTheme.panelTop,
                            AppTheme.panelBottom
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(AppTheme.panelDivider)
                        .frame(height: 1)
                }
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
                .accessibilityHidden(revealProgress < 0.95)
            }
        }
        .onChange(of: pullDistance) { _, newValue in
            if newValue > latchThreshold {
                releaseTask?.cancel()
                latchedPullDistance = max(latchedPullDistance, newValue)
            } else if newValue <= 1, latchedPullDistance > 0 {
                releaseTask?.cancel()
                releaseTask = Task {
                    try? await Task.sleep(for: .milliseconds(650))
                    await MainActor.run {
                        withAnimation(.easeOut(duration: 0.2)) {
                            latchedPullDistance = 0
                        }
                    }
                }
            }
        }
    }
}
