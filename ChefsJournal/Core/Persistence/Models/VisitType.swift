import Foundation

enum VisitType: String, Codable, Sendable, CaseIterable, Hashable {
    case dineIn
    case takeOut

    var title: LocalizedStringResource {
        switch self {
        case .dineIn: "Dine-in"
        case .takeOut: "Take-out"
        }
    }
}
