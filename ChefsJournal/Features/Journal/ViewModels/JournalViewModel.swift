import Combine
import Foundation

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var isPresentingNewVisit = false
    @Published var toastMessage: String?

    private let formatter: JournalRowFormatter

    init(formatter: JournalRowFormatter = JournalRowFormatter()) {
        self.formatter = formatter
    }

    func rows(for visits: [Visit], now: Date) -> [JournalRowDisplay] {
        visits.map { visit in
            JournalRowDisplay(
                row: formatter.row(for: VisitSnapshot(visit), now: now),
                photoData: visit.orderedDishes.lazy.compactMap(\.photoData).first
            )
        }
    }

    /// Up to two favourites not visited for three weeks, as card text.
    func beenAWhileCards(for visits: [Visit], now: Date) -> [BeenAWhileCard] {
        let restaurants = RestaurantSnapshot.grouping(visits.map(VisitSnapshot.init))
        return BeenAWhileFinder.suggestions(restaurants: restaurants, now: now).map { suggestion in
            let average = ScoreFormatting.average(suggestion.averageExperience)
            let lastVisited = String(localized: suggestion.lastVisited.lastVisitedDescription(relativeTo: now))
            return BeenAWhileCard(
                id: suggestion.id,
                name: suggestion.name,
                detail: String(localized: "You rate it \(average) on average. Last visited \(lastVisited).")
            )
        }
    }

    func startNewLog() {
        isPresentingNewVisit = true
    }

    func visitSaved() {
        toastMessage = String(localized: "Visit saved to your journal")
    }
}

struct BeenAWhileCard: Identifiable, Hashable {
    let id: UUID
    let name: String
    let detail: String
}

struct JournalRowDisplay: Identifiable {
    let row: JournalRow
    let photoData: Data?

    var id: UUID { row.id }
}
