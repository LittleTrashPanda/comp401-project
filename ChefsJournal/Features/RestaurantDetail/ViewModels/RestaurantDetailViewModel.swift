import Combine
import Foundation
import os

@MainActor
final class RestaurantDetailViewModel: ObservableObject {
    @Published var visitForActions: Visit?
    @Published var visitPendingDeletion: Visit?
    @Published var editContext: VisitEditContext?
    @Published var errorMessage: String?
    @Published private(set) var didRemoveRestaurant = false

    let store: any JournalStoreProtocol

    init(store: any JournalStoreProtocol) {
        self.store = store
    }

    // MARK: Display

    func display(for visits: [Visit], now: Date = .now) -> RestaurantDetailDisplay {
        let photos = Dictionary(visits.flatMap(\.orderedDishes).compactMap { dish in dish.photoData.map { (dish.id, $0) } },
                                uniquingKeysWith: { first, _ in first })
        return Self.makeDisplay(from: visits.map(VisitSnapshot.init), photos: photos, now: now)
    }

    static func makeDisplay(from visits: [VisitSnapshot], photos: [UUID: Data], now: Date,
                            locale: Locale = .autoupdatingCurrent) -> RestaurantDetailDisplay {
        let summary = RestaurantStatsCalculator.summary(for: visits)
        let newestFirst = visits.sorted { $0.date > $1.date }
        return RestaurantDetailDisplay(
            name: newestFirst.first?.restaurantName ?? "",
            area: newestFirst.first?.restaurantArea ?? "",
            visitCountText: summary.visitCount.formatted(.number.locale(locale)),
            averageExperienceText: summary.averageExperience.map { ScoreFormatting.average($0, locale: locale) } ?? "—",
            lastVisitedText: summary.lastVisited.map { $0.lastVisitedDescription(relativeTo: now).string(in: locale) } ?? "—",
            latestExperience: newestFirst.first?.experienceScore,
            dishes: summary.bestDishes.map { dish in
                RestaurantDishRow(id: dish.id, name: dish.name, tasteScore: dish.tasteScore, valueScore: dish.valueScore,
                                  wouldOrderAgain: dish.wouldOrderAgain, photoData: photos[dish.id])
            },
            visits: newestFirst.map { visit in
                RestaurantVisitRow(id: visit.id, date: visit.date, visitTypeText: visit.visitType.title.string(in: locale),
                                   experienceScore: visit.experienceScore, note: visit.note,
                                   dishNames: visit.dishes.map(\.name).joined(separator: ", "))
            }
        )
    }

    // MARK: Actions

    func showActions(for visit: Visit) {
        visitForActions = visit
    }

    func beginEditing(_ visit: Visit) {
        editContext = VisitEditContext(visit: visit, draft: VisitDraft(visit: visit))
    }

    func requestDelete(_ visit: Visit) {
        visitPendingDeletion = visit
    }

    /// Deletes the pending visit. `remainingVisitCount` is the restaurant's visit count before deleting.
    func confirmDelete(remainingVisitCount: Int) {
        guard let visit = visitPendingDeletion else { return }
        visitPendingDeletion = nil
        do {
            try store.deleteVisit(visit)
            didRemoveRestaurant = remainingVisitCount <= 1
        } catch {
            Logger.persistence.error("Deleting a visit failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }
}
