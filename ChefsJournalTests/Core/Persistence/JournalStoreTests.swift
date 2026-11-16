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

@MainActor
struct JournalStoreUpdateTests {
    @Test func updateVisitChangesScoreAndKeepsDishes() throws {
        let journal = try TestJournal()
        let visit = try journal.store.saveNewVisit(Fixtures.visit(experience: 5))
        var draft = VisitDraft(visit: visit)
        draft.experienceScore = 9

        try journal.store.updateVisit(visit, with: draft)

        #expect(visit.experienceScore == 9)
        #expect(try journal.count(DishEntry.self) == 1)
        #expect(visit.dishes?.first?.name == "California Roll")
    }

    @Test func updateVisitReplacesEditedAndRemovedDishes() throws {
        let journal = try TestJournal()
        let visit = try journal.store.saveNewVisit(Fixtures.visit(dishes: [Fixtures.dish("A"), Fixtures.dish("B")]))
        var draft = VisitDraft(visit: visit)
        draft.dishes[0].tasteScore = 2
        draft.dishes.remove(at: 1)
        draft.dishes.append(Fixtures.dish("C"))

        try journal.store.updateVisit(visit, with: draft)

        #expect(visit.orderedDishes.map(\.name) == ["A", "C"])
        #expect(visit.orderedDishes.first?.tasteScore == 2)
        #expect(try journal.count(DishEntry.self) == 2)
    }

    @Test func updateDishAppliesDraft() throws {
        let journal = try TestJournal()
        let visit = try journal.store.saveNewVisit(Fixtures.visit())
        let dish = try #require(visit.dishes?.first)
        var draft = DishDraft(entry: dish)
        draft.valueScore = 3
        draft.note = "Smaller this time"

        try journal.store.updateDish(dish, with: draft)

        #expect(dish.valueScore == 3)
        #expect(dish.note == "Smaller this time")
    }
}

@MainActor
struct JournalStorePhotoTests {
    @Test func photoDataPersistsAndIsRemovedWithDish() throws {
        let journal = try TestJournal()
        let photo = try PhotoProcessorTests.makeImageData(width: 40, height: 30)
        var dish = Fixtures.dish()
        dish.photoData = photo
        let visit = try journal.store.saveNewVisit(Fixtures.visit(dishes: [dish]))

        let saved = try #require(try journal.context.fetch(FetchDescriptor<DishEntry>()).first)
        #expect(saved.photoData == photo)

        try journal.store.deleteDish(try #require(visit.dishes?.first))
        #expect(try journal.count(DishEntry.self) == 0)
    }
}

@MainActor
struct DishEditorViewModelPhotoTests {
    @Test func attachingPhotoDownsamplesIntoDraft() async throws {
        let viewModel = DishEditorViewModel(draft: DishDraft(), isEditing: false, suggestions: [])
        await viewModel.attachPhoto(from: try PhotoProcessorTests.makeImageData(width: 3200, height: 2400))
        let data = try #require(viewModel.draft.photoData)
        #expect(!data.isEmpty)
        #expect(viewModel.photoErrorMessage == nil)
    }

    @Test func unreadablePhotoShowsMessage() async {
        let viewModel = DishEditorViewModel(draft: DishDraft(), isEditing: false, suggestions: [])
        await viewModel.attachPhoto(from: Data("junk".utf8))
        #expect(viewModel.draft.photoData == nil)
        #expect(viewModel.photoErrorMessage != nil)
    }

    @Test func removePhotoClearsDraft() {
        let viewModel = DishEditorViewModel(draft: DishDraft(photoData: Data([1])), isEditing: true, suggestions: [])
        viewModel.removePhoto()
        #expect(viewModel.draft.photoData == nil)
    }
}
