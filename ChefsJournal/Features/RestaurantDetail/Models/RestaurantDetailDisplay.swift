import Foundation

struct RestaurantDetailDisplay {
    let name: String
    let area: String
    let visitCountText: String
    let averageExperienceText: String
    let lastVisitedText: String
    let latestExperience: Int?
    let dishes: [RestaurantDishRow]
    /// Newest first.
    let visits: [RestaurantVisitRow]
}

struct RestaurantDishRow: Identifiable {
    let id: UUID
    let name: String
    let tasteScore: Int
    let valueScore: Int
    let wouldOrderAgain: Bool
    let photoData: Data?
}

struct RestaurantVisitRow: Identifiable {
    let id: UUID
    let date: Date
    let visitTypeText: String
    let experienceScore: Int
    let note: String
    let dishNames: String
}

/// A visit opened for editing in the New Visit sheet.
struct VisitEditContext: Identifiable {
    let id = UUID()
    let visit: Visit
    let draft: VisitDraft
}
