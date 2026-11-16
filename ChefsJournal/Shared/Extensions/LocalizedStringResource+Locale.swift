import Foundation

extension LocalizedStringResource {
    /// Resolves the resource to a String in a given locale (tests pin en_US).
    func string(in locale: Locale) -> String {
        var resource = self
        resource.locale = locale
        return String(localized: resource)
    }
}
