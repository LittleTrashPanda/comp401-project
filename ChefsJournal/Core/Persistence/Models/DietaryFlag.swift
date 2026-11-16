import Foundation
import SwiftData

/// A dietary tag on a dish entry, optionally marked as a problem for one or more diners.
@Model
final class DietaryFlag {
    var id: UUID = UUID()
    /// A ``DietaryTag`` raw value, or free text for a custom tag.
    var tag: String = ""
    var problemFor: [Diner]? = []
    var dish: DishEntry?

    init(tag: String) {
        self.tag = tag
    }
}
