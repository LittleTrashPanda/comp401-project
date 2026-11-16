import SwiftUI

extension View {
    /// Registers the value-based destinations shared by the Journal and History stacks.
    func journalDestinations(store: any JournalStoreProtocol) -> some View {
        self
            .navigationDestination(for: RestaurantRoute.self) { route in
                RestaurantDetailView(store: store, restaurantID: route.id)
            }
            .navigationDestination(for: DishRoute.self) { route in
                DishDetailView(store: store, route: route)
            }
            .navigationDestination(for: HistoryRoute.self) { route in
                switch route {
                case let .restaurant(restaurant): RestaurantDetailView(store: store, restaurantID: restaurant.id)
                case let .dish(dish): DishDetailView(store: store, route: dish)
                }
            }
    }
}
