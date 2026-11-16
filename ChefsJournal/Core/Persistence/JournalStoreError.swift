import Foundation

enum JournalStoreError: LocalizedError, Equatable {
    case invalidDraft
    case saveFailed
    case cannotDeleteOwner

    var errorDescription: String? {
        switch self {
        case .invalidDraft: String(localized: "Some details are missing. Check the restaurant, scores and dishes.")
        case .cannotDeleteOwner: String(localized: "“Me” is the phone owner and can’t be deleted.")
        case .saveFailed: String(localized: "Your journal couldn’t be saved. Please try again.")
        }
    }
}
