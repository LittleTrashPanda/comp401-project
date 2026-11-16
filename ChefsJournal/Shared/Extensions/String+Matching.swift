import Foundation

extension String {
    /// Whitespace-trimmed copy, used before saving names.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Key for comparing names: trimmed and case- and diacritic-insensitive.
    var matchingKey: String {
        trimmed.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
