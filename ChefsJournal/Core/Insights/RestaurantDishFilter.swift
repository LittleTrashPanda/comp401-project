import Foundation

/// The chips above a restaurant's dish list: all dishes, one diner's, or one tag's.
enum RestaurantDishFilter: Hashable, Sendable {
    case all
    case diner(UUID)
    case tag(String)

    func apply(to dishes: [DishSnapshot]) -> [DishSnapshot] {
        switch self {
        case .all:
            dishes
        case let .diner(id):
            dishes.filter { $0.orderedBy?.id == id }
        case let .tag(tag):
            dishes.filter { dish in dish.flags.contains { $0.tag == tag } }
        }
    }

    /// "All", then each diner who ordered here, then each tag used here.
    static func options(for dishes: [DishSnapshot]) -> [RestaurantDishFilter] {
        let diners = Set(dishes.compactMap(\.orderedBy)).sorted { $0.name < $1.name }
        let tags = Set(dishes.flatMap(\.flags).map(\.tag)).sorted()
        return [.all] + diners.map { .diner($0.id) } + tags.map { .tag($0) }
    }
}
