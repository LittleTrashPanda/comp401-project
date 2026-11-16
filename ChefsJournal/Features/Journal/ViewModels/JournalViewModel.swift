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

    func startNewLog() {
        isPresentingNewVisit = true
    }

    func visitSaved() {
        toastMessage = String(localized: "Visit saved to your journal")
    }
}

struct JournalRowDisplay: Identifiable {
    let row: JournalRow
    let photoData: Data?

    var id: UUID { row.id }
}
