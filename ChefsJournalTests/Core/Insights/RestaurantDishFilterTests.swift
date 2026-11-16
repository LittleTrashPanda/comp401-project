import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct RestaurantDishFilterTests {
    private func bellaDishes() throws -> [DishSnapshot] {
        try PreviewData.visitSnapshots(now: .now).filter { $0.restaurantName == "Bella Italia" }.flatMap(\.dishes)
    }

    @Test func filteringByElizaReturnsOnlyHerDishes() throws {
        let dishes = try bellaDishes()
        let elizaID = try #require(dishes.compactMap(\.orderedBy).first { $0.name == "Eliza" }?.id)

        let filtered = RestaurantDishFilter.diner(elizaID).apply(to: dishes)

        #expect(!filtered.isEmpty)
        #expect(Set(filtered.map(\.name)) == ["Calzone"])
    }

    @Test func filteringByGlutenReturnsOnlyCalzone() throws {
        let filtered = RestaurantDishFilter.tag(DietaryTag.containsGluten.rawValue).apply(to: try bellaDishes())
        #expect(Set(filtered.map(\.name)) == ["Calzone"])
    }

    @Test func allReturnsEverything() throws {
        let dishes = try bellaDishes()
        #expect(RestaurantDishFilter.all.apply(to: dishes).count == dishes.count)
    }

    @Test func optionsListDinersAndTagsUsedHere() throws {
        let options = RestaurantDishFilter.options(for: try bellaDishes())
        #expect(options.first == .all)
        #expect(options.contains(.tag(DietaryTag.containsGluten.rawValue)))
        #expect(options.contains { if case .diner = $0 { true } else { false } })
    }
}
