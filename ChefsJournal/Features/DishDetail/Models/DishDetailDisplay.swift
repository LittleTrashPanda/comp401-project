import Foundation

struct DishDetailDisplay: Equatable {
    let restaurantName: String
    let name: String
    /// The most recent instance at this restaurant.
    let latest: DishSnapshot
    /// Every instance at this restaurant, newest first.
    let instances: [DishSnapshot]
    let averageTasteText: String
    let averageValueText: String
    let lastOrdered: Date
    let lastOrderedText: String
}
