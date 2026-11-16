import Foundation
import SwiftData
import Testing
@testable import ChefsJournal

@MainActor
struct JournalStoreTests {
    @Test func saveNewVisitCreatesRestaurantVisitAndDishes() throws {
        let journal = try TestJournal()
        try journal.store.saveNewVisit(Fixtures.visit())

        #expect(try journal.count(Restaurant.self) == 1)
        #expect(try journal.count(Visit.self) == 1)
        #expect(try journal.count(DishEntry.self) == 1)
    }

    @Test func savingWithExistingNameReusesRestaurant() throws {
        let journal = try TestJournal()
        try journal.store.saveNewVisit(Fixtures.visit(at: "Sakura Sushi "))
        try journal.store.saveNewVisit(Fixtures.visit(at: "sakura sushi"))

        let restaurants = try journal.context.fetch(FetchDescriptor<Restaurant>())
        #expect(restaurants.count == 1)
        #expect(restaurants.first?.name == "Sakura Sushi")
        #expect(restaurants.first?.visits?.count == 2)
    }

    @Test func existingRestaurantMatchesTrimmedCaseInsensitiveName() throws {
        let journal = try TestJournal()
        try journal.store.saveNewVisit(Fixtures.visit(at: "Sakura Sushi"))

        #expect(try journal.store.existingRestaurant(named: "  SAKURA sushi ") != nil)
        #expect(try journal.store.existingRestaurant(named: "Sakura") == nil)
    }

    @Test func restaurantsMatchingOrdersByMostRecentVisit() throws {
        let journal = try TestJournal()
        let now = Date.now
        try journal.store.saveNewVisit(Fixtures.visit(at: "Sakura Sushi", date: now.addingTimeInterval(-86_400 * 10)))
        try journal.store.saveNewVisit(Fixtures.visit(at: "Sushi Zen", date: now))
        try journal.store.saveNewVisit(Fixtures.visit(at: "Bella Italia", date: now))

        let matches = try journal.store.restaurants(matching: "sushi").map(\.name)
        #expect(matches == ["Sushi Zen", "Sakura Sushi"])
        #expect(try journal.store.restaurants(matching: "").count == 3)
    }

    @Test func deletingOnlyVisitRemovesRestaurant() throws {
        let journal = try TestJournal()
        let visit = try journal.store.saveNewVisit(Fixtures.visit())

        try journal.store.deleteVisit(visit)

        #expect(try journal.count(Restaurant.self) == 0)
        #expect(try journal.count(Visit.self) == 0)
        #expect(try journal.count(DishEntry.self) == 0)
    }

    @Test func deletingOneOfTwoVisitsKeepsRestaurant() throws {
        let journal = try TestJournal()
        let first = try journal.store.saveNewVisit(Fixtures.visit())
        try journal.store.saveNewVisit(Fixtures.visit(dishes: [Fixtures.dish("Miso Soup")]))

        try journal.store.deleteVisit(first)

        #expect(try journal.count(Restaurant.self) == 1)
        #expect(try journal.count(Visit.self) == 1)
        let remainingDishes = try journal.context.fetch(FetchDescriptor<DishEntry>()).map(\.name)
        #expect(remainingDishes == ["Miso Soup"])
    }

    @Test func deleteDishKeepsVisit() throws {
        let journal = try TestJournal()
        let visit = try journal.store.saveNewVisit(Fixtures.visit())
        let dish = try #require(visit.dishes?.first)

        try journal.store.deleteDish(dish)

        #expect(try journal.count(DishEntry.self) == 0)
        #expect(try journal.count(Visit.self) == 1)
    }

    @Test func saveNewVisitThrowsInvalidDraft() throws {
        let journal = try TestJournal()
        let draft = Fixtures.visit(experience: 0)

        #expect(throws: JournalStoreError.invalidDraft) {
            try journal.store.saveNewVisit(draft)
        }
        #expect(try journal.count(Restaurant.self) == 0)
    }

    @Test func dishNameSuggestionsAreDistinctAndRestaurantScoped() throws {
        let journal = try TestJournal()
        let now = Date.now
        try journal.store.saveNewVisit(Fixtures.visit(date: now.addingTimeInterval(-86_400), dishes: [Fixtures.dish("Miso Soup"), Fixtures.dish("California Roll")]))
        let latest = try journal.store.saveNewVisit(Fixtures.visit(date: now, dishes: [Fixtures.dish("california roll ")]))
        try journal.store.saveNewVisit(Fixtures.visit(at: "Tokyo House", dishes: [Fixtures.dish("Ramen")]))

        let restaurant = try #require(latest.restaurant)
        #expect(journal.store.dishNameSuggestions(for: restaurant) == ["california roll", "Miso Soup"])
    }
}
