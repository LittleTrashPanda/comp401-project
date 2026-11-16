import Foundation

enum TrendCalculator {
    static let minimumScores = 3
    /// The halves must differ by more than this to count as a change.
    static let threshold = 0.5

    /// Compares the mean of the first half with the mean of the last half; an odd middle score is left out.
    static func trend(for scoresOldestFirst: [Int]) -> Trend? {
        guard scoresOldestFirst.count >= minimumScores else { return nil }
        let half = scoresOldestFirst.count / 2
        guard let earlier = RestaurantStatsCalculator.average(of: Array(scoresOldestFirst.prefix(half))),
              let later = RestaurantStatsCalculator.average(of: Array(scoresOldestFirst.suffix(half))) else { return nil }
        let difference = later - earlier
        if difference > threshold { return .improving }
        if difference < -threshold { return .slipping }
        return .steady
    }
}
