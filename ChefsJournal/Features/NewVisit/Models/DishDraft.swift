import Foundation

/// An editable dish entry before it is saved.
struct DishDraft: Sendable, Equatable, Identifiable {
    var id = UUID()
    var name = ""
    var tasteScore = ScoreRange.unset
    var valueScore = ScoreRange.unset
    var wouldOrderAgain = false
    var note = ""
    var photoData: Data?
    var orderedByDinerID: UUID?
    var flags: [DietaryFlagDraft] = []

    var isComplete: Bool {
        !name.trimmed.isEmpty
            && ScoreRange.valid.contains(tasteScore)
            && ScoreRange.valid.contains(valueScore)
    }

    var hasContent: Bool {
        !name.trimmed.isEmpty || tasteScore != ScoreRange.unset || valueScore != ScoreRange.unset
            || !note.trimmed.isEmpty || photoData != nil
    }
}

/// A dietary tag on a draft dish and the diners it's a problem for.
struct DietaryFlagDraft: Sendable, Equatable, Hashable {
    var tag: String
    var problemForDinerIDs: Set<UUID> = []
}
