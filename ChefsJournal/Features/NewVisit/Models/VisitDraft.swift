import Foundation

/// An editable visit before it is saved.
struct VisitDraft: Sendable, Equatable {
    var restaurantName = ""
    var restaurantArea = ""
    var date = Date.now
    var visitType = VisitType.dineIn
    var experienceScore = ScoreRange.unset
    var note = ""
    var dishes: [DishDraft] = []

    var hasRestaurant: Bool {
        !restaurantName.trimmed.isEmpty
    }

    var hasValidDetails: Bool {
        ScoreRange.valid.contains(experienceScore)
    }

    var hasCompleteDishes: Bool {
        !dishes.isEmpty && dishes.allSatisfy(\.isComplete)
    }

    var isComplete: Bool {
        hasRestaurant && hasValidDetails && hasCompleteDishes
    }
}
