import Foundation

enum JournalStoreError: LocalizedError, Equatable {
    case invalidDraft
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .invalidDraft: String(localized: "Some details are missing. Check the restaurant, scores and dishes.")
        case .saveFailed: String(localized: "Your journal couldn’t be saved. Please try again.")
        }
    }
}
