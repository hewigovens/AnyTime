import CoreGraphics
import Observation

@MainActor
@Observable
final class PullDownMonitor {
    var contentOffset: CGFloat = 0

    var pullDistance: CGFloat {
        max(0, -contentOffset)
    }
}
