import Combine
import Foundation

/// State for the Add/Edit Dish sheet.
@MainActor
final class DishEditorViewModel: ObservableObject {
    private static let suggestionLimit = 6

    @Published var draft: DishDraft
    let isEditing: Bool
    private let allSuggestions: [String]

    init(draft: DishDraft, isEditing: Bool, suggestions: [String]) {
        self.draft = draft
        self.isEditing = isEditing
        self.allSuggestions = suggestions
    }

    var canFinish: Bool { draft.isComplete }

    /// Earlier dish names from this restaurant that match what's typed, excluding an exact match.
    var visibleSuggestions: [String] {
        let typed = draft.name.trimmed
        let key = typed.matchingKey
        let matches = typed.isEmpty ? allSuggestions : allSuggestions.filter {
            $0.localizedStandardContains(typed) && $0.matchingKey != key
        }
        return Array(matches.prefix(Self.suggestionLimit))
    }

    func applySuggestion(_ name: String) {
        draft.name = name
    }
}
