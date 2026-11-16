import Foundation
import SwiftData

/// Someone the journal owner eats with. "Me" is the phone owner and can't be deleted.
@Model
final class Diner {
    var id: UUID = UUID()
    var name: String = ""
    var dietaryProfile: String = ""
    var isOwner: Bool = false
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \DishEntry.orderedBy)
    var dishes: [DishEntry]? = []

    @Relationship(deleteRule: .nullify, inverse: \DietaryFlag.problemFor)
    var problemFlags: [DietaryFlag]? = []

    init(name: String, dietaryProfile: String = "", isOwner: Bool = false, createdAt: Date = .now) {
        self.name = name
        self.dietaryProfile = dietaryProfile
        self.isOwner = isOwner
        self.createdAt = createdAt
    }
}
