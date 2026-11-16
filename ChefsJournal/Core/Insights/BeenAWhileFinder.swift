import Foundation

/// A favourite restaurant the person hasn't been back to lately.
struct BeenAWhileSuggestion: Identifiable, Sendable, Hashable {
    let id: UUID
    let name: String
    let averageExperience: Double
    let lastVisited: Date
}

enum BeenAWhileFinder {
    static let minimumAverage = 8.0
    static let minimumDaysSinceVisit = 21
    static let defaultLimit = 2

    /// Restaurants averaging 8+ with no visit for 3+ weeks, best first.
    static func suggestions(restaurants: [RestaurantSnapshot], now: Date, limit: Int = defaultLimit,
                            calendar: Calendar = .current) -> [BeenAWhileSuggestion] {
        let candidates: [BeenAWhileSuggestion] = restaurants.compactMap { restaurant in
            let summary = RestaurantStatsCalculator.summary(for: restaurant.visits)
            guard let average = summary.averageExperience, let lastVisited = summary.lastVisited,
                  average >= minimumAverage,
                  calendar.daysBetween(lastVisited, and: now) >= minimumDaysSinceVisit else { return nil }
            return BeenAWhileSuggestion(id: restaurant.id, name: restaurant.name, averageExperience: average, lastVisited: lastVisited)
        }
        return Array(candidates.sorted { $0.averageExperience > $1.averageExperience }.prefix(limit))
    }
}
