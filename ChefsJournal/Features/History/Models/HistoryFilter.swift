import Foundation

/// Everything the History tab can search, filter and sort by.
struct HistoryFilter: Sendable, Hashable {
    enum Segment: String, Sendable, CaseIterable {
        case restaurants
        case dishes
    }

    enum ScoreType: String, Sendable, CaseIterable {
        case experience
        case taste
        case value
    }

    enum LastVisited: String, Sendable, CaseIterable {
        case oneWeek
        case threeWeeks
        case threeMonths

        var minimumDays: Int {
            switch self {
            case .oneWeek: 7
            case .threeWeeks: 21
            case .threeMonths: 90
            }
        }
    }

    enum Sort: String, Sendable, CaseIterable {
        case score
        case recency
        case visits
    }

    var segment = Segment.restaurants
    var searchText = ""
    var minimumAverage: Int?
    var scoreType = ScoreType.experience
    var lastVisitedOlderThan: LastVisited?
    var visitType: VisitType?
    var tag: String?
    var dinerID: UUID?
    var wouldOrderAgainOnly = false
    var sort = Sort.score
}

/// One ranked row in History: a restaurant, or a dish at one restaurant.
struct HistoryResult: Identifiable, Sendable, Hashable {
    enum Kind: Sendable, Hashable {
        case restaurant
        case dish
    }

    let id: String
    let kind: Kind
    let name: String
    let restaurantID: UUID
    let restaurantName: String
    let visitCount: Int
    let lastVisited: Date
    let average: Double
    /// Scores oldest first, for the trend badge.
    let scoresOldestFirst: [Int]
}
