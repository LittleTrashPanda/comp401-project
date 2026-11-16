import Foundation

/// Answers History questions such as "8+ average, not visited in 3 weeks" from value snapshots.
enum HistoryQueryEngine {
    static func results(restaurants: [RestaurantSnapshot], filter: HistoryFilter, now: Date,
                        calendar: Calendar = .current) -> [HistoryResult] {
        let candidates = switch filter.segment {
        case .restaurants: restaurantResults(restaurants, filter: filter)
        case .dishes: dishResults(restaurants, filter: filter)
        }
        let filtered = candidates.filter { passesThresholds($0, filter: filter, now: now, calendar: calendar) }
        return sort(filtered, by: filter.sort)
    }

    // MARK: Restaurants

    private static func restaurantResults(_ restaurants: [RestaurantSnapshot], filter: HistoryFilter) -> [HistoryResult] {
        restaurants.compactMap { restaurant in
            guard let lastVisited = restaurant.visits.map(\.date).max(),
                  matchesSearch(restaurant, text: filter.searchText),
                  matchesAttributes(restaurant.visits, dishes: restaurant.dishes, filter: filter) else { return nil }
            let scores = restaurantScores(restaurant, type: filter.scoreType)
            guard let average = RestaurantStatsCalculator.average(of: scores) else { return nil }
            return HistoryResult(
                id: restaurant.id.uuidString, kind: .restaurant, name: restaurant.name,
                restaurantID: restaurant.id, restaurantName: restaurant.name,
                visitCount: restaurant.visits.count, lastVisited: lastVisited, average: average,
                scoresOldestFirst: restaurant.visits.sorted { $0.date < $1.date }.map(\.experienceScore)
            )
        }
    }

    /// Experience uses visits; taste and value use the averages of the restaurant's dishes.
    private static func restaurantScores(_ restaurant: RestaurantSnapshot, type: HistoryFilter.ScoreType) -> [Int] {
        switch type {
        case .experience: restaurant.visits.map(\.experienceScore)
        case .taste: restaurant.dishes.map(\.tasteScore)
        case .value: restaurant.dishes.map(\.valueScore)
        }
    }

    private static func matchesSearch(_ restaurant: RestaurantSnapshot, text: String) -> Bool {
        let query = text.trimmed
        guard !query.isEmpty else { return true }
        let haystacks = [restaurant.name] + restaurant.visits.map(\.note) + restaurant.dishes.flatMap { [$0.name, $0.note] }
        return haystacks.contains { $0.localizedStandardContains(query) }
    }

    private static func matchesAttributes(_ visits: [VisitSnapshot], dishes: [DishSnapshot], filter: HistoryFilter) -> Bool {
        if let visitType = filter.visitType, !visits.contains(where: { $0.visitType == visitType }) { return false }
        if let tag = filter.tag, !dishes.contains(where: { $0.hasTag(tag) }) { return false }
        if let dinerID = filter.dinerID, !dishes.contains(where: { $0.orderedBy?.id == dinerID }) { return false }
        if filter.wouldOrderAgainOnly,
           !RestaurantStatsCalculator.latestInstances(of: dishes).contains(where: \.wouldOrderAgain) { return false }
        return true
    }

    // MARK: Dishes

    private static func dishResults(_ restaurants: [RestaurantSnapshot], filter: HistoryFilter) -> [HistoryResult] {
        restaurants.flatMap { restaurant in
            Dictionary(grouping: restaurant.dishes, by: \.matchingKey).values.compactMap { instances in
                dishCandidate(instances.sorted { $0.date < $1.date }, restaurant: restaurant, filter: filter)
            }
        }
    }

    private static func dishCandidate(_ oldestFirst: [DishSnapshot], restaurant: RestaurantSnapshot,
                                      filter: HistoryFilter) -> HistoryResult? {
        guard let latest = oldestFirst.last, matchesSearch(oldestFirst, restaurantName: restaurant.name, text: filter.searchText),
              dishMatchesAttributes(oldestFirst, latest: latest, filter: filter) else { return nil }
        let scores = filter.scoreType == .value ? oldestFirst.map(\.valueScore) : oldestFirst.map(\.tasteScore)
        guard let average = RestaurantStatsCalculator.average(of: scores) else { return nil }
        return HistoryResult(
            id: "\(restaurant.id.uuidString)|\(latest.matchingKey)", kind: .dish, name: latest.name,
            restaurantID: restaurant.id, restaurantName: restaurant.name, visitCount: oldestFirst.count,
            lastVisited: latest.date, average: average, scoresOldestFirst: scores
        )
    }

    private static func matchesSearch(_ instances: [DishSnapshot], restaurantName: String, text: String) -> Bool {
        let query = text.trimmed
        guard !query.isEmpty else { return true }
        let haystacks = [restaurantName] + instances.flatMap { [$0.name, $0.note] }
        return haystacks.contains { $0.localizedStandardContains(query) }
    }

    private static func dishMatchesAttributes(_ instances: [DishSnapshot], latest: DishSnapshot, filter: HistoryFilter) -> Bool {
        if let visitType = filter.visitType, !instances.contains(where: { $0.visitType == visitType }) { return false }
        if let tag = filter.tag, !instances.contains(where: { $0.hasTag(tag) }) { return false }
        if let dinerID = filter.dinerID, !instances.contains(where: { $0.orderedBy?.id == dinerID }) { return false }
        if filter.wouldOrderAgainOnly, !latest.wouldOrderAgain { return false }
        return true
    }

    // MARK: Shared

    private static func passesThresholds(_ result: HistoryResult, filter: HistoryFilter, now: Date, calendar: Calendar) -> Bool {
        if let minimum = filter.minimumAverage, result.average < Double(minimum) { return false }
        if let olderThan = filter.lastVisitedOlderThan,
           calendar.daysBetween(result.lastVisited, and: now) < olderThan.minimumDays { return false }
        return true
    }

    private static func sort(_ results: [HistoryResult], by sort: HistoryFilter.Sort) -> [HistoryResult] {
        results.sorted { lhs, rhs in
            switch sort {
            case .score where lhs.average != rhs.average: lhs.average > rhs.average
            case .recency where lhs.lastVisited != rhs.lastVisited: lhs.lastVisited > rhs.lastVisited
            case .visits where lhs.visitCount != rhs.visitCount: lhs.visitCount > rhs.visitCount
            default: lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
        }
    }
}

extension DishSnapshot {
    func hasTag(_ tag: String) -> Bool {
        flags.contains { $0.tag == tag }
    }
}

extension Calendar {
    /// Whole calendar days from `start` to `end`, never negative.
    func daysBetween(_ start: Date, and end: Date) -> Int {
        max(0, dateComponents([.day], from: startOfDay(for: start), to: startOfDay(for: end)).day ?? 0)
    }
}
