import Foundation

enum ScoreRange {
    /// Valid saved scores. 0 means "unset" in inputs and is never persisted.
    static let valid = 1...10
    static let unset = 0
    static let maximum = 10
}
