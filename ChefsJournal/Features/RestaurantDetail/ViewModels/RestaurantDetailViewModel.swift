import Combine
import Foundation
import os

@MainActor
final class RestaurantDetailViewModel: ObservableObject {
    @Published var visitPendingDeletion: Visit?
    @Published var editContext: VisitEditContext?
    @Published var errorMessage: String?
    @Published private(set) var didRemoveRestaurant = false
    @Published var dishFilter = RestaurantDishFilter.all

    let store: any JournalStoreProtocol

    init(store: any JournalStoreProtocol) {
        self.store = store
    }

    // MARK: Display

    func display(for visits: [Visit], now: Date = .now) -> RestaurantDetailDisplay {
        let photos = Dictionary(visits.flatMap(\.orderedDishes).compactMap { dish in dish.photoData.map { (dish.id, $0) } },
                                uniquingKeysWith: { first, _ in first })
        return Self.makeDisplay(from: visits.map(VisitSnapshot.init), photos: photos, filter: dishFilter, now: now)
    }

    static func makeDisplay(from visits: [VisitSnapshot], photos: [UUID: Data], filter: RestaurantDishFilter = .all,
                            now: Date, locale: Locale = .autoupdatingCurrent) -> RestaurantDetailDisplay {
        let summary = RestaurantStatsCalculator.summary(for: visits)
        let newestFirst = visits.sorted { $0.date > $1.date }
        let allDishes = visits.flatMap(\.dishes)
        let filteredDishes = RestaurantStatsCalculator.rankedLatestDishes(filter.apply(to: allDishes))
        let oldestFirst = newestFirst.reversed()
        return RestaurantDetailDisplay(
            name: newestFirst.first?.restaurantName ?? "",
            area: newestFirst.first?.restaurantArea ?? "",
            visitCountText: summary.visitCount.formatted(.number.locale(locale)),
            averageExperienceText: summary.averageExperience.map { ScoreFormatting.average($0, locale: locale) } ?? "—",
            lastVisitedText: summary.lastVisited.map { $0.lastVisitedDescription(relativeTo: now).string(in: locale) } ?? "—",
            latestExperience: newestFirst.first?.experienceScore,
            experiencePoints: oldestFirst.map { ScoreChartView.Point(date: $0.date, score: $0.experienceScore) },
            trend: TrendCalculator.trend(for: oldestFirst.map(\.experienceScore)),
            headsUpLines: HeadsUpCalculator.items(for: allDishes).map { $0.line(locale: locale) },
            filterChips: filterChips(for: allDishes, locale: locale),
            dishes: filteredDishes.map { dish in
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

    private static func filterChips(for dishes: [DishSnapshot], locale: Locale) -> [DishFilterChip] {
        let dinerNames = Dictionary(dishes.compactMap(\.orderedBy).map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
        return RestaurantDishFilter.options(for: dishes).map { filter in
            switch filter {
            case .all: DishFilterChip(filter: filter, title: String(localized: "All dishes", locale: locale))
            case let .diner(id): DishFilterChip(filter: filter, title: dinerNames[id] ?? "")
            case let .tag(tag): DishFilterChip(filter: filter, title: DietaryTag.title(for: tag, locale: locale))
            }
        }
    }

    // MARK: Actions

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
