import Foundation

/// A diner as shown in pickers.
struct DinerOption: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let dietaryProfile: String
    let isOwner: Bool
}

extension DinerOption {
    init(_ diner: Diner) {
        self.init(id: diner.id, name: diner.name, dietaryProfile: diner.dietaryProfile, isOwner: diner.isOwner)
    }
}
