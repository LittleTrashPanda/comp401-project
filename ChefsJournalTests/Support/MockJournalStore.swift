import Foundation
@testable import ChefsJournal

/// Records calls and serves unsaved models, so ViewModels can be tested without a database.
@MainActor
final class MockJournalStore: JournalStoreProtocol {
    var restaurantsToReturn: [Restaurant] = []
    var suggestionsToReturn: [String] = []
    var errorToThrow: Error?
    private(set) var savedDrafts: [VisitDraft] = []
    private(set) var updatedDrafts: [VisitDraft] = []
    private(set) var deletedVisits: [Visit] = []
    private(set) var deletedDishes: [DishEntry] = []

    func restaurants(matching query: String) throws -> [Restaurant] {
        let trimmedQuery = query.trimmed
        return trimmedQuery.isEmpty ? restaurantsToReturn : restaurantsToReturn.filter { $0.name.localizedStandardContains(trimmedQuery) }
    }

    func existingRestaurant(named name: String) throws -> Restaurant? {
        restaurantsToReturn.first { $0.name.matchingKey == name.matchingKey }
    }

    func saveNewVisit(_ draft: VisitDraft) throws -> Visit {
        if let errorToThrow { throw errorToThrow }
        savedDrafts.append(draft)
        return Visit(date: draft.date, visitType: draft.visitType, experienceScore: draft.experienceScore, note: draft.note)
    }

    func updateVisit(_ visit: Visit, with draft: VisitDraft) throws {
        if let errorToThrow { throw errorToThrow }
        updatedDrafts.append(draft)
    }

    func deleteVisit(_ visit: Visit) throws {
        if let errorToThrow { throw errorToThrow }
        deletedVisits.append(visit)
    }

    private(set) var updatedDishDrafts: [DishDraft] = []

    func updateDish(_ dish: DishEntry, with draft: DishDraft) throws {
        if let errorToThrow { throw errorToThrow }
        updatedDishDrafts.append(draft)
    }

    func deleteDish(_ dish: DishEntry) throws {
        if let errorToThrow { throw errorToThrow }
        deletedDishes.append(dish)
    }

    func dishNameSuggestions(for restaurant: Restaurant) -> [String] {
        suggestionsToReturn
    }

    // MARK: Diners

    var dinersToReturn: [Diner] = []

    func seedOwnerIfNeeded() throws {
        guard !dinersToReturn.contains(where: \.isOwner) else { return }
        dinersToReturn.insert(Diner(name: "Me", isOwner: true), at: 0)
    }

    func diners() throws -> [Diner] { dinersToReturn }

    func addDiner(name: String, dietaryProfile: String) throws -> Diner {
        let diner = Diner(name: name, dietaryProfile: dietaryProfile)
        dinersToReturn.append(diner)
        return diner
    }

    func updateDiner(_ diner: Diner, name: String, dietaryProfile: String) throws {
        diner.name = name
        diner.dietaryProfile = dietaryProfile
    }

    func deleteDiner(_ diner: Diner) throws {
        if diner.isOwner { throw JournalStoreError.cannotDeleteOwner }
        dinersToReturn.removeAll { $0.id == diner.id }
    }
}
