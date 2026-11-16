import Foundation
import SwiftData

@Model
final class DishEntry {
    var id: UUID = UUID()
    var name: String = ""
    var tasteScore: Int = 0
    var valueScore: Int = 0
    var wouldOrderAgain: Bool = false
    var note: String = ""
    /// Position within the visit, so dishes keep the order they were logged in.
    var position: Int = 0
    @Attribute(.externalStorage) var photoData: Data?
    var visit: Visit?

    init(name: String, tasteScore: Int, valueScore: Int, wouldOrderAgain: Bool, note: String, position: Int) {
        self.name = name
        self.tasteScore = tasteScore
        self.valueScore = valueScore
        self.wouldOrderAgain = wouldOrderAgain
        self.note = note
        self.position = position
    }
}
