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
    let tastePoints: [ScoreChartView.Point]
    let valuePoints: [ScoreChartView.Point]
    let trend: Trend?
    /// The same dish at every restaurant, for the Compare table.
    let comparison: [ComparisonRow]
}
