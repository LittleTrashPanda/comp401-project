import Foundation

/// A value copy of a dish entry, safe to pass across concurrency boundaries.
struct DishSnapshot: Sendable, Hashable, Identifiable {
    var id = UUID()
    var name = ""
    var tasteScore = 0
    var valueScore = 0
    var wouldOrderAgain = false
    var note = ""
    var hasPhoto = false
    var date = Date.distantPast
    var visitID = UUID()
    var visitType = VisitType.dineIn
    var restaurantID = UUID()
    var restaurantName = ""

    var matchingKey: String { name.matchingKey }
}

/// A value copy of a visit and its dishes.
struct VisitSnapshot: Sendable, Hashable, Identifiable {
    var id = UUID()
    var date = Date.distantPast
    var visitType = VisitType.dineIn
    var experienceScore = 0
    var note = ""
    var restaurantID = UUID()
    var restaurantName = ""
    var restaurantArea = ""
    var dishes: [DishSnapshot] = []
}

/// A value copy of a restaurant and all of its visits.
struct RestaurantSnapshot: Sendable, Hashable, Identifiable {
    var id = UUID()
    var name = ""
    var area = ""
    var visits: [VisitSnapshot] = []

    var dishes: [DishSnapshot] { visits.flatMap(\.dishes) }
}

extension DishSnapshot {
    init(_ dish: DishEntry, visit: Visit) {
        self.init(
            id: dish.id,
            name: dish.name,
            tasteScore: dish.tasteScore,
            valueScore: dish.valueScore,
            wouldOrderAgain: dish.wouldOrderAgain,
            note: dish.note,
            hasPhoto: dish.photoData != nil,
            date: visit.date,
            visitID: visit.id,
            visitType: visit.visitType,
            restaurantID: visit.restaurant?.id ?? UUID(),
            restaurantName: visit.restaurant?.name ?? ""
        )
    }
}

extension VisitSnapshot {
    init(_ visit: Visit) {
        self.init(
            id: visit.id,
            date: visit.date,
            visitType: visit.visitType,
            experienceScore: visit.experienceScore,
            note: visit.note,
            restaurantID: visit.restaurant?.id ?? UUID(),
            restaurantName: visit.restaurant?.name ?? "",
            restaurantArea: visit.restaurant?.area ?? "",
            dishes: visit.orderedDishes.map { DishSnapshot($0, visit: visit) }
        )
    }
}

extension RestaurantSnapshot {
    /// Groups visit snapshots by restaurant.
    static func grouping(_ visits: [VisitSnapshot]) -> [RestaurantSnapshot] {
        Dictionary(grouping: visits, by: \.restaurantID).compactMap { id, visits in
            guard let first = visits.first else { return nil }
            return RestaurantSnapshot(id: id, name: first.restaurantName, area: first.restaurantArea,
                                      visits: visits.sorted { $0.date < $1.date })
        }
    }
}
