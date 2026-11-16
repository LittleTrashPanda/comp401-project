import Foundation

/// Preset dietary tags. Custom tags are stored as free text.
enum DietaryTag: String, CaseIterable, Sendable {
    case containsGluten
    case containsDairy
    case containsNuts
    case containsShellfish
    case containsEgg
    case containsMeat
    case vegetarian
    case vegan
    case spicy

    var title: LocalizedStringResource {
        switch self {
        case .containsGluten: "Contains gluten"
        case .containsDairy: "Contains dairy"
        case .containsNuts: "Contains nuts"
        case .containsShellfish: "Contains shellfish"
        case .containsEgg: "Contains egg"
        case .containsMeat: "Contains meat"
        case .vegetarian: "Vegetarian"
        case .vegan: "Vegan"
        case .spicy: "Spicy"
        }
    }

    /// Words that, found in a diner's dietary profile, suggest this tag may be a problem for them.
    var profileKeywords: [String] {
        switch self {
        case .containsGluten: ["gluten", "wheat", "coeliac", "celiac"]
        case .containsDairy: ["dairy", "lactose", "milk"]
        case .containsNuts: ["nut", "peanut"]
        case .containsShellfish: ["shellfish", "shrimp", "prawn", "crab"]
        case .containsEgg: ["egg"]
        case .containsMeat: ["vegetarian", "vegan", "meat"]
        case .vegetarian, .vegan: []
        case .spicy: ["spicy", "spice", "heat"]
        }
    }

    /// Display title for any stored tag: a preset's localized title, or the custom text itself.
    static func title(for storedTag: String, locale: Locale = .autoupdatingCurrent) -> String {
        DietaryTag(rawValue: storedTag)?.title.string(in: locale) ?? storedTag
    }
}
