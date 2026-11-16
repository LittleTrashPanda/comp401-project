#if DEBUG
import Foundation
import os
import SwiftData

/// Sample journal from the project description, for previews, UI tests and fixtures.
@MainActor
enum PreviewData {
    private static let secondsPerDay: TimeInterval = 86_400
    private static let calendar = Calendar(identifier: .gregorian)

    /// An in-memory container, optionally seeded with the sample journal.
    static func makeContainer(seeded: Bool = true, now: Date = .now) -> ModelContainer {
        do {
            let container = try ModelContainerFactory.make(inMemory: true)
            if seeded {
                try seed(into: container.mainContext, now: now)
            }
            return container
        } catch {
            Logger.persistence.fault("Preview container failed: \(error.localizedDescription, privacy: .public)")
            fatalError("Preview container failed: \(error)")
        }
    }

    /// Value snapshots of every seeded visit, oldest first.
    static func visitSnapshots(now: Date) throws -> [VisitSnapshot] {
        let container = makeContainer(now: now)
        let visits = try container.mainContext.fetch(FetchDescriptor<Visit>(sortBy: [SortDescriptor(\.date)]))
        return visits.map(VisitSnapshot.init)
    }

    static func seed(into context: ModelContext, now: Date) throws {
        let store = JournalStore(modelContext: context)
        for draft in sampleVisits(now: now) {
            try store.saveNewVisit(draft)
        }
    }

    /// Generates many visits to check that large journals stay responsive.
    static func seedLargeJournal(into context: ModelContext, visitCount: Int, now: Date) throws {
        let store = JournalStore(modelContext: context)
        let names = ["Golden Wok", "Café Lumière", "Taco Norte", "Pho Real", "Olive Grove", "Curry Leaf", "Noodle Bar"]
        for index in 0..<visitCount {
            let draft = VisitDraft(
                restaurantName: "\(names[index % names.count]) \(index % 40)",
                date: now.addingTimeInterval(-secondsPerDay * Double(index)),
                visitType: index.isMultiple(of: 3) ? .takeOut : .dineIn,
                experienceScore: index % ScoreRange.maximum + 1,
                note: "Generated visit \(index)",
                dishes: [DishDraft(name: "Dish \(index % 25)", tasteScore: (index + 3) % ScoreRange.maximum + 1,
                                   valueScore: (index + 6) % ScoreRange.maximum + 1, wouldOrderAgain: index.isMultiple(of: 2))]
            )
            try store.saveNewVisit(draft)
        }
    }

    static func sampleVisits(now: Date) -> [VisitDraft] {
        sakuraAndTokyo() + bellaItalia(now: now) + hearthside(now: now)
    }

    private static func daysAgo(_ days: Int, from now: Date) -> Date {
        now.addingTimeInterval(-secondsPerDay * Double(days))
    }

    private static func fixedDate(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 19)) ?? .now
    }

    private static func sakuraAndTokyo() -> [VisitDraft] {
        [
            VisitDraft(
                restaurantName: "Tokyo House", restaurantArea: "Uptown",
                date: fixedDate(year: 2026, month: 10, day: 12), visitType: .dineIn, experienceScore: 7,
                note: "Quick lunch at the counter.",
                dishes: [DishDraft(name: "California Roll", tasteScore: 8, valueScore: 6, wouldOrderAgain: true,
                                   note: "Fresh, but small for the price.")]
            ),
            VisitDraft(
                restaurantName: "Sakura Sushi", restaurantArea: "Downtown",
                date: fixedDate(year: 2026, month: 11, day: 6), visitType: .dineIn, experienceScore: 5,
                note: "Long wait and cramped seating. Get take-out next time.",
                dishes: [DishDraft(name: "California Roll", tasteScore: 7, valueScore: 9, wouldOrderAgain: true,
                                   note: "Generous portion for the price. Compare with Tokyo House.")]
            ),
        ]
    }

    private static func bellaItalia(now: Date) -> [VisitDraft] {
        let scoresOldestFirst = [8, 9, 7, 8, 7, 8]
        let lastVisitDaysAgo = 21
        let daysBetweenVisits = 30
        return scoresOldestFirst.enumerated().map { index, score in
            let visitsAfterThis = scoresOldestFirst.count - 1 - index
            return VisitDraft(
                restaurantName: "Bella Italia", restaurantArea: "Midtown",
                date: daysAgo(lastVisitDaysAgo + visitsAfterThis * daysBetweenVisits, from: now),
                visitType: .dineIn, experienceScore: score,
                note: index == scoresOldestFirst.count - 1 ? "Family dinner. Ask for the corner table." : "",
                dishes: bellaDishes(visitIndex: index)
            )
        }
    }

    private static func bellaDishes(visitIndex: Int) -> [DishDraft] {
        let carbonara = DishDraft(name: "Spaghetti Carbonara", tasteScore: visitIndex.isMultiple(of: 2) ? 8 : 9,
                                  valueScore: 7, wouldOrderAgain: true)
        guard visitIndex >= 4 else { return [carbonara] }
        let calzone = DishDraft(name: "Calzone", tasteScore: 7, valueScore: 6, wouldOrderAgain: false,
                                note: "Eliza felt unwell afterwards.")
        let tiramisu = DishDraft(name: "Tiramisu", tasteScore: 9, valueScore: 8, wouldOrderAgain: true)
        return [carbonara, calzone, tiramisu]
    }

    private static func hearthside(now: Date) -> [VisitDraft] {
        let scoresOldestFirst = [8, 9, 8, 9, 9]
        let lastVisitDaysAgo = 21
        let daysBetweenVisits = 45
        return scoresOldestFirst.enumerated().map { index, score in
            let visitsAfterThis = scoresOldestFirst.count - 1 - index
            return VisitDraft(
                restaurantName: "Hearthside Steakhouse", restaurantArea: "Riverside",
                date: daysAgo(lastVisitDaysAgo + visitsAfterThis * daysBetweenVisits, from: now),
                visitType: .dineIn, experienceScore: score,
                note: index == scoresOldestFirst.count - 1 ? "Anniversary dinner." : "",
                dishes: [DishDraft(name: "Ribeye", tasteScore: 9, valueScore: 7, wouldOrderAgain: true)]
            )
        }
    }
}
#endif
