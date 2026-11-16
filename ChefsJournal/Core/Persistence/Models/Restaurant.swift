import Foundation
import SwiftData

@Model
final class Restaurant {
    var id: UUID = UUID()
    var name: String = ""
    var area: String = ""
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Visit.restaurant)
    var visits: [Visit]? = []

    init(name: String, area: String = "", createdAt: Date = .now) {
        self.name = name
        self.area = area
        self.createdAt = createdAt
    }

    var lastVisitDate: Date? {
        (visits ?? []).map(\.date).max()
    }
}
