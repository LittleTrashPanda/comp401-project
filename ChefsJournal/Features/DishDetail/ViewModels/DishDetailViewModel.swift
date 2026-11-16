import Combine
import Foundation
import os

@MainActor
final class DishDetailViewModel: ObservableObject {
    @Published var editorContext: DishEditorContext?
    @Published var dishPendingDeletion: DishEntry?
    @Published var errorMessage: String?
    @Published private(set) var shouldDismiss = false
    @Published private(set) var diners: [DinerOption] = []

    private let store: any JournalStoreProtocol
    private var entryBeingEdited: DishEntry?

    init(store: any JournalStoreProtocol) {
        self.store = store
    }

    // MARK: Display

    func display(for visits: [Visit], route: DishRoute, now: Date = .now) -> DishDetailDisplay? {
        Self.makeDisplay(from: visits.map(VisitSnapshot.init), route: route, now: now)
    }

    static func makeDisplay(from visits: [VisitSnapshot], route: DishRoute, now: Date,
                            locale: Locale = .autoupdatingCurrent) -> DishDetailDisplay? {
        let key = route.dishName.matchingKey
        let restaurantVisits = visits.filter { $0.restaurantID == route.restaurantID }
        let instances = restaurantVisits
            .flatMap(\.dishes)
            .filter { $0.matchingKey == key }
            .sorted { $0.date > $1.date }
        guard let latest = instances.first else { return nil }
        let averageTaste = RestaurantStatsCalculator.average(of: instances.map(\.tasteScore)) ?? 0
        let averageValue = RestaurantStatsCalculator.average(of: instances.map(\.valueScore)) ?? 0
        return DishDetailDisplay(
            restaurantName: restaurantVisits.first?.restaurantName ?? latest.restaurantName,
            name: latest.name,
            latest: latest,
            instances: instances,
            averageTasteText: ScoreFormatting.average(averageTaste, locale: locale),
            averageValueText: ScoreFormatting.average(averageValue, locale: locale),
            lastOrdered: latest.date,
            lastOrderedText: latest.date.lastVisitedDescription(relativeTo: now).string(in: locale)
        )
    }

    // MARK: Actions

    func loadDiners() {
        do {
            diners = try store.diners().map(DinerOption.init)
        } catch {
            Logger.persistence.error("Loading diners failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }

    func entry(withID id: UUID, in visits: [Visit]) -> DishEntry? {
        visits.lazy.flatMap { $0.dishes ?? [] }.first { $0.id == id }
    }

    func beginEditing(_ entry: DishEntry) {
        entryBeingEdited = entry
        editorContext = DishEditorContext(index: 0, draft: DishDraft(entry: entry))
    }

    func saveEdit(_ draft: DishDraft) {
        guard let entry = entryBeingEdited else { return }
        entryBeingEdited = nil
        do {
            try store.updateDish(entry, with: draft)
        } catch {
            Logger.persistence.error("Updating a dish failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }

    func requestDelete(_ entry: DishEntry) {
        dishPendingDeletion = entry
    }

    /// True when the pending dish is the only one in its visit, so the alert also offers deleting the visit.
    var pendingDishIsLastInVisit: Bool {
        (dishPendingDeletion?.visit?.dishes?.count ?? 0) <= 1
    }

    func confirmDeleteDish(instanceCount: Int) {
        guard let dish = dishPendingDeletion else { return }
        dishPendingDeletion = nil
        perform { try store.deleteDish(dish) }
        shouldDismiss = errorMessage == nil && instanceCount <= 1
    }

    func confirmDeleteVisit() {
        guard let visit = dishPendingDeletion?.visit else { return }
        dishPendingDeletion = nil
        perform { try store.deleteVisit(visit) }
        shouldDismiss = errorMessage == nil
    }

    private func perform(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            Logger.persistence.error("Deleting failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }
}
