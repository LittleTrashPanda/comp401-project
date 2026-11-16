import Foundation
import os
import SwiftData

@MainActor
protocol DinerStoreProtocol: AnyObject {
    func seedOwnerIfNeeded() throws
    func diners() throws -> [Diner]
    @discardableResult func addDiner(name: String, dietaryProfile: String) throws -> Diner
    func updateDiner(_ diner: Diner, name: String, dietaryProfile: String) throws
    func deleteDiner(_ diner: Diner) throws
}

@MainActor
protocol JournalStoreProtocol: DinerStoreProtocol {
    func restaurants(matching query: String) throws -> [Restaurant]
    func existingRestaurant(named name: String) throws -> Restaurant?
    @discardableResult func saveNewVisit(_ draft: VisitDraft) throws -> Visit
    func updateVisit(_ visit: Visit, with draft: VisitDraft) throws
    func deleteVisit(_ visit: Visit) throws
    func updateDish(_ dish: DishEntry, with draft: DishDraft) throws
    func deleteDish(_ dish: DishEntry) throws
    func dishNameSuggestions(for restaurant: Restaurant) -> [String]
}


/// Writes the journal through SwiftData. All validation happens before anything is inserted.
@MainActor
final class JournalStore: JournalStoreProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: Restaurants

    func restaurants(matching query: String) throws -> [Restaurant] {
        let trimmedQuery = query.trimmed
        let all = try modelContext.fetch(FetchDescriptor<Restaurant>())
        let matches = trimmedQuery.isEmpty ? all : all.filter { $0.name.localizedStandardContains(trimmedQuery) }
        return matches.sorted { ($0.lastVisitDate ?? $0.createdAt) > ($1.lastVisitDate ?? $1.createdAt) }
    }

    func existingRestaurant(named name: String) throws -> Restaurant? {
        let key = name.matchingKey
        guard !key.isEmpty else { return nil }
        return try modelContext.fetch(FetchDescriptor<Restaurant>()).first { $0.name.matchingKey == key }
    }

    // MARK: Visits

    @discardableResult
    func saveNewVisit(_ draft: VisitDraft) throws -> Visit {
        guard draft.isComplete else { throw JournalStoreError.invalidDraft }
        let restaurant = try findOrCreateRestaurant(for: draft)
        let visit = Visit(date: draft.date, visitType: draft.visitType, experienceScore: draft.experienceScore, note: draft.note.trimmed)
        modelContext.insert(visit)
        visit.restaurant = restaurant
        for (position, dishDraft) in draft.dishes.enumerated() {
            try insertDish(from: dishDraft, position: position, into: visit)
        }
        try save()
        return visit
    }

    func updateVisit(_ visit: Visit, with draft: VisitDraft) throws {
        guard draft.hasValidDetails, draft.hasCompleteDishes else { throw JournalStoreError.invalidDraft }
        visit.date = draft.date
        visit.visitType = draft.visitType
        visit.experienceScore = draft.experienceScore
        visit.note = draft.note.trimmed
        if let restaurant = visit.restaurant, !draft.restaurantArea.trimmed.isEmpty {
            restaurant.area = draft.restaurantArea.trimmed
        }
        try syncDishes(of: visit, with: draft.dishes)
        try save()
    }

    func deleteVisit(_ visit: Visit) throws {
        let restaurant = visit.restaurant
        let visitID = visit.persistentModelID
        modelContext.delete(visit)
        if let restaurant, (restaurant.visits ?? []).allSatisfy({ $0.persistentModelID == visitID }) {
            modelContext.delete(restaurant)
        }
        try save()
    }

    // MARK: Dishes

    func updateDish(_ dish: DishEntry, with draft: DishDraft) throws {
        guard draft.isComplete else { throw JournalStoreError.invalidDraft }
        try apply(draft, to: dish)
        try save()
    }

    func deleteDish(_ dish: DishEntry) throws {
        modelContext.delete(dish)
        try save()
    }

    func dishNameSuggestions(for restaurant: Restaurant) -> [String] {
        let dishesNewestFirst = (restaurant.visits ?? [])
            .sorted { $0.date > $1.date }
            .flatMap(\.orderedDishes)
        var seenKeys = Set<String>()
        return dishesNewestFirst.compactMap { dish in
            seenKeys.insert(dish.name.matchingKey).inserted ? dish.name : nil
        }
    }

    // MARK: Diners

    func seedOwnerIfNeeded() throws {
        let ownerExists = try modelContext.fetchCount(FetchDescriptor<Diner>(predicate: #Predicate { $0.isOwner })) > 0
        guard !ownerExists else { return }
        modelContext.insert(Diner(name: String(localized: "Me"), isOwner: true, createdAt: .distantPast))
        try save()
    }

    func diners() throws -> [Diner] {
        try modelContext.fetch(FetchDescriptor<Diner>(sortBy: [SortDescriptor(\.createdAt)]))
            .sorted { $0.isOwner && !$1.isOwner }
    }

    @discardableResult
    func addDiner(name: String, dietaryProfile: String) throws -> Diner {
        guard !name.trimmed.isEmpty else { throw JournalStoreError.invalidDraft }
        let diner = Diner(name: name.trimmed, dietaryProfile: dietaryProfile.trimmed)
        modelContext.insert(diner)
        try save()
        return diner
    }

    func updateDiner(_ diner: Diner, name: String, dietaryProfile: String) throws {
        guard !name.trimmed.isEmpty else { throw JournalStoreError.invalidDraft }
        diner.name = name.trimmed
        diner.dietaryProfile = dietaryProfile.trimmed
        try save()
    }

    func deleteDiner(_ diner: Diner) throws {
        guard !diner.isOwner else { throw JournalStoreError.cannotDeleteOwner }
        modelContext.delete(diner)
        try save()
    }

    // MARK: Helpers

    private func findOrCreateRestaurant(for draft: VisitDraft) throws -> Restaurant {
        if let existing = try existingRestaurant(named: draft.restaurantName) {
            return existing
        }
        let restaurant = Restaurant(name: draft.restaurantName.trimmed, area: draft.restaurantArea.trimmed)
        modelContext.insert(restaurant)
        return restaurant
    }

    @discardableResult
    private func insertDish(from draft: DishDraft, position: Int, into visit: Visit) throws -> DishEntry {
        let dish = DishEntry(name: draft.name.trimmed, tasteScore: draft.tasteScore, valueScore: draft.valueScore,
                             wouldOrderAgain: draft.wouldOrderAgain, note: draft.note.trimmed, position: position)
        modelContext.insert(dish)
        dish.photoData = draft.photoData
        dish.visit = visit
        try applyDiners(from: draft, to: dish)
        return dish
    }

    private func apply(_ draft: DishDraft, to dish: DishEntry) throws {
        dish.name = draft.name.trimmed
        dish.tasteScore = draft.tasteScore
        dish.valueScore = draft.valueScore
        dish.wouldOrderAgain = draft.wouldOrderAgain
        dish.note = draft.note.trimmed
        dish.photoData = draft.photoData
        try applyDiners(from: draft, to: dish)
    }

    /// Sets "Ordered by" and replaces the dietary flags with the draft's.
    private func applyDiners(from draft: DishDraft, to dish: DishEntry) throws {
        let dinersByID = Dictionary(try fetchDiners(), uniquingKeysWith: { first, _ in first })
        dish.orderedBy = draft.orderedByDinerID.flatMap { dinersByID[$0] }
        for flag in dish.flags ?? [] {
            modelContext.delete(flag)
        }
        dish.flags = draft.flags.map { flagDraft in
            let flag = DietaryFlag(tag: flagDraft.tag)
            modelContext.insert(flag)
            flag.problemFor = flagDraft.problemForDinerIDs.compactMap { dinersByID[$0] }
            return flag
        }
    }

    private func fetchDiners() throws -> [(UUID, Diner)] {
        try modelContext.fetch(FetchDescriptor<Diner>()).map { ($0.id, $0) }
    }

    private func syncDishes(of visit: Visit, with drafts: [DishDraft]) throws {
        let existing = Dictionary(uniqueKeysWithValues: (visit.dishes ?? []).map { ($0.id, $0) })
        let keptIDs = Set(drafts.map(\.id))
        for dish in existing.values where !keptIDs.contains(dish.id) {
            modelContext.delete(dish)
        }
        for (position, draft) in drafts.enumerated() {
            if let dish = existing[draft.id] {
                try apply(draft, to: dish)
                dish.position = position
            } else {
                try insertDish(from: draft, position: position, into: visit)
            }
        }
    }

    private func save() throws {
        do {
            try modelContext.save()
        } catch {
            Logger.persistence.error("Saving the journal failed: \(error.localizedDescription, privacy: .private)")
            modelContext.rollback()
            throw JournalStoreError.saveFailed
        }
    }
}
