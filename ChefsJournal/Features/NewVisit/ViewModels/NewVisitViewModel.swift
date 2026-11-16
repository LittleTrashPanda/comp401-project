import Combine
import Foundation
import os

@MainActor
final class NewVisitViewModel: ObservableObject {
    enum Mode {
        case create
        case edit(Visit, draft: VisitDraft)
    }

    enum Step: Int, CaseIterable, Comparable {
        case restaurant = 1
        case details
        case dishes

        static func < (lhs: Step, rhs: Step) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    private static let recentRestaurantLimit = 5

    @Published var draft: VisitDraft
    @Published private(set) var currentStep: Step
    @Published var searchQuery = "" {
        didSet { refreshSearchResults() }
    }
    @Published private(set) var searchResults: [RestaurantOption] = []
    @Published private(set) var isNewRestaurant = false
    @Published var dishEditor: DishEditorContext?
    @Published var isConfirmingDiscard = false
    @Published var errorMessage: String?
    @Published private(set) var diners: [DinerOption] = []

    private let store: any JournalStoreProtocol
    private let mode: Mode
    private let initialDraft: VisitDraft
    private var selectedRestaurant: Restaurant?

    init(store: any JournalStoreProtocol, mode: Mode = .create) {
        self.store = store
        self.mode = mode
        switch mode {
        case .create:
            let emptyDraft = VisitDraft()
            draft = emptyDraft
            initialDraft = emptyDraft
            currentStep = .restaurant
        case let .edit(visit, editDraft):
            draft = editDraft
            initialDraft = editDraft
            currentStep = .details
            selectedRestaurant = visit.restaurant
        }
    }

    // MARK: State

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    var firstStep: Step { isEditing ? .details : .restaurant }

    var isOnFirstStep: Bool { currentStep == firstStep }

    var isOnLastStep: Bool { currentStep == .dishes }

    var canAdvance: Bool {
        switch currentStep {
        case .restaurant: draft.hasRestaurant
        case .details: draft.hasValidDetails
        case .dishes: draft.hasCompleteDishes
        }
    }

    var hasUnsavedContent: Bool {
        draft != initialDraft || !searchQuery.trimmed.isEmpty
    }

    var isSearching: Bool { !searchQuery.trimmed.isEmpty }

    /// "Add “X”" is offered only when no existing restaurant has exactly that name.
    var showsAddRow: Bool {
        isSearching && !searchResults.contains { $0.name.matchingKey == searchQuery.matchingKey }
    }

    var dishSuggestions: [String] {
        guard let selectedRestaurant else { return [] }
        return store.dishNameSuggestions(for: selectedRestaurant)
    }

    /// Heads-up lines for an existing restaurant with flagged dishes. Empty for new restaurants.
    var headsUpLines: [String] {
        guard let selectedRestaurant else { return [] }
        let dishes = (selectedRestaurant.visits ?? []).flatMap { visit in
            visit.orderedDishes.map { DishSnapshot($0, visit: visit) }
        }
        return HeadsUpCalculator.items(for: dishes).map { $0.line() }
    }

    func loadDiners() {
        do {
            diners = try store.diners().map(DinerOption.init)
        } catch {
            Logger.persistence.error("Loading diners failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Step 1

    func refreshSearchResults() {
        do {
            let matches = try store.restaurants(matching: searchQuery)
            let limited = isSearching ? matches : Array(matches.prefix(Self.recentRestaurantLimit))
            searchResults = limited.map(RestaurantOption.init)
        } catch {
            Logger.persistence.error("Restaurant search failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }

    func select(_ option: RestaurantOption) {
        do {
            selectedRestaurant = try store.existingRestaurant(named: option.name)
            draft.restaurantName = option.name
            draft.restaurantArea = ""
            isNewRestaurant = false
            currentStep = .details
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addNewRestaurant() {
        let name = searchQuery.trimmed
        guard !name.isEmpty else { return }
        if let existing = searchResults.first(where: { $0.name.matchingKey == name.matchingKey })
            ?? existingOption(named: name) {
            select(existing)
            return
        }
        selectedRestaurant = nil
        draft.restaurantName = name
        isNewRestaurant = true
        currentStep = .details
    }

    // MARK: Navigation

    func advance() {
        guard canAdvance, let next = Step(rawValue: currentStep.rawValue + 1) else { return }
        currentStep = next
    }

    func goBack() {
        guard !isOnFirstStep, let previous = Step(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previous
    }

    /// Returns true when the sheet can close straight away; otherwise asks for confirmation.
    func requestCancel() -> Bool {
        guard hasUnsavedContent else { return true }
        isConfirmingDiscard = true
        return false
    }

    // MARK: Dishes

    func beginAddingDish() {
        dishEditor = DishEditorContext(index: nil, draft: DishDraft())
    }

    func beginEditingDish(at index: Int) {
        guard draft.dishes.indices.contains(index) else { return }
        dishEditor = DishEditorContext(index: index, draft: draft.dishes[index])
    }

    func commitDish(_ dish: DishDraft) {
        if let index = dishEditor?.index, draft.dishes.indices.contains(index) {
            draft.dishes[index] = dish
        } else {
            draft.dishes.append(dish)
        }
        dishEditor = nil
    }

    func removeDish(at offsets: IndexSet) {
        draft.dishes.remove(atOffsets: offsets)
    }

    // MARK: Save

    func save() throws {
        do {
            switch mode {
            case .create:
                try store.saveNewVisit(draft)
            case let .edit(visit, _):
                try store.updateVisit(visit, with: draft)
            }
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    private func existingOption(named name: String) -> RestaurantOption? {
        do {
            return try store.existingRestaurant(named: name).map(RestaurantOption.init)
        } catch {
            Logger.persistence.error("Restaurant lookup failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
