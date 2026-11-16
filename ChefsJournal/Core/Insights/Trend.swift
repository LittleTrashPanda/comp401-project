import Foundation

/// Direction of a score series over time.
enum Trend: String, Sendable, Hashable, CaseIterable {
    case improving
    case steady
    case slipping
}
