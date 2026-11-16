import Foundation

/// A dish that's a problem for one or more diners because of a dietary tag.
struct HeadsUpItem: Sendable, Hashable {
    let dishName: String
    let tag: String
    let dinerNames: [String]

    /// e.g. "Calzone — contains gluten (Eliza)".
    func line(locale: Locale = .autoupdatingCurrent) -> String {
        let tagText = DietaryTag.title(for: tag, locale: locale).lowercased(with: locale)
        let names = dinerNames.formatted(.list(type: .and).locale(locale))
        return String(localized: "\(dishName) — \(tagText) (\(names))", locale: locale)
    }
}

enum HeadsUpCalculator {
    /// Only tags marked as a problem for a diner produce an item. Items are merged per dish name + tag.
    static func items(for dishes: [DishSnapshot]) -> [HeadsUpItem] {
        var namesByKey: [String: (dishName: String, tag: String, diners: Set<String>)] = [:]
        for dish in dishes {
            for flag in dish.flags where !flag.problemFor.isEmpty {
                let key = "\(dish.matchingKey)|\(flag.tag.matchingKey)"
                var entry = namesByKey[key] ?? (dish.name.trimmed, flag.tag, [])
                entry.diners.formUnion(flag.problemFor.map(\.name))
                namesByKey[key] = entry
            }
        }
        return namesByKey.values
            .map { HeadsUpItem(dishName: $0.dishName, tag: $0.tag, dinerNames: $0.diners.sorted()) }
            .sorted { ($0.dishName.matchingKey, $0.tag) < ($1.dishName.matchingKey, $1.tag) }
    }
}
