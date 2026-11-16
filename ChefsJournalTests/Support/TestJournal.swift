import Foundation
import SwiftData
@testable import ChefsJournal

/// An in-memory journal for store tests. Holds the container so its context stays valid.
@MainActor
struct TestJournal {
    let container: ModelContainer
    let store: JournalStore

    var context: ModelContext { container.mainContext }

    init() throws {
        container = try ModelContainerFactory.make(inMemory: true)
        store = JournalStore(modelContext: container.mainContext)
    }

    func count<Model: PersistentModel>(_ type: Model.Type) throws -> Int {
        try context.fetchCount(FetchDescriptor<Model>())
    }
}

enum Fixtures {
    static func dish(_ name: String = "California Roll", taste: Int = 7, value: Int = 9, again: Bool = true) -> DishDraft {
        DishDraft(name: name, tasteScore: taste, valueScore: value, wouldOrderAgain: again)
    }

    static func visit(
        at restaurant: String = "Sakura Sushi",
        experience: Int = 5,
        date: Date = .now,
        dishes: [DishDraft] = [dish()]
    ) -> VisitDraft {
        VisitDraft(restaurantName: restaurant, date: date, visitType: .dineIn, experienceScore: experience, dishes: dishes)
    }
}
