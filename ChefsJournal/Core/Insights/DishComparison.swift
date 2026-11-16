import Foundation

/// One restaurant's latest take on a dish, for the Compare table.
struct ComparisonRow: Identifiable, Sendable, Hashable {
    let restaurantID: UUID
    let restaurantName: String
    let date: Date
    let tasteScore: Int
    let valueScore: Int
    let isCurrent: Bool

    var id: UUID { restaurantID }
}

enum DishComparison {
    /// The latest instance of `dishName` at each restaurant, oldest order first.
    static func rows(for dishName: String, currentRestaurantID: UUID, dishes: [DishSnapshot]) -> [ComparisonRow] {
        let key = dishName.matchingKey
        let matches = dishes.filter { $0.matchingKey == key }
        return Dictionary(grouping: matches, by: \.restaurantID).values
            .compactMap { instances in instances.max { $0.date < $1.date } }
            .sorted { $0.date < $1.date }
            .map { dish in
                ComparisonRow(restaurantID: dish.restaurantID, restaurantName: dish.restaurantName, date: dish.date,
                              tasteScore: dish.tasteScore, valueScore: dish.valueScore,
                              isCurrent: dish.restaurantID == currentRestaurantID)
            }
    }
}
