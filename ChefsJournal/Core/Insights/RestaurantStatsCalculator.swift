import Foundation

struct RestaurantSummary: Sendable, Equatable {
    let visitCount: Int
    let averageExperience: Double?
    let lastVisited: Date?
    /// The latest instance of each dish, best first.
    let bestDishes: [DishSnapshot]
}

enum RestaurantStatsCalculator {
    static func summary(for visits: [VisitSnapshot]) -> RestaurantSummary {
        RestaurantSummary(
            visitCount: visits.count,
            averageExperience: average(of: visits.map(\.experienceScore)),
            lastVisited: visits.map(\.date).max(),
            bestDishes: rankedLatestDishes(visits.flatMap(\.dishes))
        )
    }

    /// The latest instance per dish name, ranked by taste, then value, then most recent.
    static func rankedLatestDishes(_ dishes: [DishSnapshot]) -> [DishSnapshot] {
        latestInstances(of: dishes).sorted(by: isRankedHigher)
    }

    static func latestInstances(of dishes: [DishSnapshot]) -> [DishSnapshot] {
        Dictionary(grouping: dishes, by: \.matchingKey).values.compactMap { instances in
            instances.max { $0.date < $1.date }
        }
    }

    static func average(of scores: [Int]) -> Double? {
        guard !scores.isEmpty else { return nil }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }

    private static func isRankedHigher(_ lhs: DishSnapshot, _ rhs: DishSnapshot) -> Bool {
        if lhs.tasteScore != rhs.tasteScore { return lhs.tasteScore > rhs.tasteScore }
        if lhs.valueScore != rhs.valueScore { return lhs.valueScore > rhs.valueScore }
        if lhs.date != rhs.date { return lhs.date > rhs.date }
        return lhs.name < rhs.name
    }
}
