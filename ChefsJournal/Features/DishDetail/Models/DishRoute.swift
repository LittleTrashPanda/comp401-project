import Foundation

/// Navigation value that opens a dish's page: every instance of `dishName` at one restaurant.
struct DishRoute: Hashable {
    let restaurantID: UUID
    let dishName: String
}
