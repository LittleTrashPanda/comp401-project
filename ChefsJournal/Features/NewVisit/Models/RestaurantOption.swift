import Foundation

/// A restaurant row in the New Visit search.
struct RestaurantOption: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let area: String
    let visitCount: Int
}

extension RestaurantOption {
    init(_ restaurant: Restaurant) {
        self.init(id: restaurant.id, name: restaurant.name, area: restaurant.area, visitCount: restaurant.visits?.count ?? 0)
    }
}

/// The dish being added or edited in the nested editor sheet. `index` is nil when adding.
struct DishEditorContext: Identifiable {
    let id = UUID()
    let index: Int?
    let draft: DishDraft
}
