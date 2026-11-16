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

    func deleteDish(_ dish: DishEntry) throws {
        if let errorToThrow { throw errorToThrow }
        deletedDishes.append(dish)
    }

    func dishNameSuggestions(for restaurant: Restaurant) -> [String] {
        suggestionsToReturn
    }
}
