import Foundation

enum ScoreFormatting {
    /// Averages are shown with one decimal place, e.g. "7.8".
    static func average(_ value: Double, locale: Locale = .autoupdatingCurrent) -> String {
        value.formatted(.number.precision(.fractionLength(1)).locale(locale))
    }
}
