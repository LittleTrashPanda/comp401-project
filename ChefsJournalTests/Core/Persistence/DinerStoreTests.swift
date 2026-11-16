import Foundation
import SwiftData
import Testing
@testable import ChefsJournal

@MainActor
struct DinerStoreTests {
    @Test func ownerSeededOnce() throws {
        let journal = try TestJournal()
        try journal.store.seedOwnerIfNeeded()
        try journal.store.seedOwnerIfNeeded()

        let diners = try journal.store.diners()
        #expect(diners.count == 1)
        #expect(diners.first?.name == "Me")
        #expect(diners.first?.isOwner == true)
    }

    @Test func deletingOwnerThrows() throws {
        let journal = try TestJournal()
        try journal.store.seedOwnerIfNeeded()
        let owner = try #require(try journal.store.diners().first)

        #expect(throws: JournalStoreError.cannotDeleteOwner) { try journal.store.deleteDiner(owner) }
        #expect(try journal.count(Diner.self) == 1)
    }

    @Test func deletingDinerNullifiesOrderedByAndProblemFor() throws {
        let journal = try TestJournal()
        let eliza = try journal.store.addDiner(name: "Eliza", dietaryProfile: "Gluten intolerant")
        var calzone = Fixtures.dish("Calzone")
        calzone.orderedByDinerID = eliza.id
        calzone.flags = [DietaryFlagDraft(tag: DietaryTag.containsGluten.rawValue, problemForDinerIDs: [eliza.id])]
        let visit = try journal.store.saveNewVisit(Fixtures.visit(at: "Bella Italia", dishes: [calzone]))
        let dish = try #require(visit.dishes?.first)
        #expect(dish.orderedBy?.name == "Eliza")
        #expect(dish.flags?.first?.problemFor?.map(\.name) == ["Eliza"])

        try journal.store.deleteDiner(eliza)

        #expect(dish.orderedBy == nil)
        #expect(dish.flags?.first?.problemFor?.isEmpty ?? true)
        #expect(try journal.count(DishEntry.self) == 1)
        #expect(try journal.count(DietaryFlag.self) == 1)
    }

    @Test func addDinerRejectsBlankName() throws {
        let journal = try TestJournal()
        #expect(throws: JournalStoreError.invalidDraft) { try journal.store.addDiner(name: "  ", dietaryProfile: "") }
    }

    @Test func updateDishReplacesFlags() throws {
        let journal = try TestJournal()
        let liam = try journal.store.addDiner(name: "Liam", dietaryProfile: "")
        var tiramisu = Fixtures.dish("Tiramisu")
        tiramisu.flags = [DietaryFlagDraft(tag: DietaryTag.containsDairy.rawValue, problemForDinerIDs: [liam.id])]
        let visit = try journal.store.saveNewVisit(Fixtures.visit(dishes: [tiramisu]))
        let dish = try #require(visit.dishes?.first)

        var edited = DishDraft(entry: dish)
        edited.flags = [DietaryFlagDraft(tag: DietaryTag.containsEgg.rawValue, problemForDinerIDs: [])]
        try journal.store.updateDish(dish, with: edited)

        #expect(dish.flags?.map(\.tag) == [DietaryTag.containsEgg.rawValue])
        #expect(try journal.count(DietaryFlag.self) == 1)
    }
}
