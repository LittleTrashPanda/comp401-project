import Foundation
import SwiftData

@Model
final class Visit {
    var id: UUID = UUID()
    var date: Date = Date.now
    var visitTypeRaw: String = VisitType.dineIn.rawValue
    var experienceScore: Int = 0
    var note: String = ""
    var restaurant: Restaurant?

    @Relationship(deleteRule: .cascade, inverse: \DishEntry.visit)
    var dishes: [DishEntry]? = []

    init(date: Date, visitType: VisitType, experienceScore: Int, note: String) {
        self.date = date
        self.visitTypeRaw = visitType.rawValue
        self.experienceScore = experienceScore
        self.note = note
    }

    var visitType: VisitType {
        get { VisitType(rawValue: visitTypeRaw) ?? .dineIn }
        set { visitTypeRaw = newValue.rawValue }
    }

    /// Dishes in the order they were added to the visit.
    var orderedDishes: [DishEntry] {
        (dishes ?? []).sorted { $0.position < $1.position }
    }
}
