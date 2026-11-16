import Foundation

extension DishDraft {
    /// A draft prefilled from a saved entry; keeps the entry's id so updates replace it.
    init(entry: DishEntry) {
        self.init(id: entry.id, name: entry.name, tasteScore: entry.tasteScore, valueScore: entry.valueScore,
                  wouldOrderAgain: entry.wouldOrderAgain, note: entry.note, photoData: entry.photoData,
                  orderedByDinerID: entry.orderedBy?.id,
                  flags: (entry.flags ?? []).sorted { $0.tag < $1.tag }.map { flag in
                      DietaryFlagDraft(tag: flag.tag, problemForDinerIDs: Set((flag.problemFor ?? []).map(\.id)))
                  })
    }
}

extension VisitDraft {
    /// A draft prefilled from a saved visit, for edit mode.
    init(visit: Visit) {
        self.init(
            restaurantName: visit.restaurant?.name ?? "",
            restaurantArea: visit.restaurant?.area ?? "",
            date: visit.date,
            visitType: visit.visitType,
            experienceScore: visit.experienceScore,
            note: visit.note,
            dishes: visit.orderedDishes.map(DishDraft.init(entry:))
        )
    }
}
