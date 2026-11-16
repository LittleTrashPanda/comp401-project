import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct DishEditorViewModelTagTests {
    private let me = DinerOption(id: UUID(), name: "Me", dietaryProfile: "", isOwner: true)
    private let eliza = DinerOption(id: UUID(), name: "Eliza", dietaryProfile: "Gluten intolerant", isOwner: false)

    private func makeViewModel() -> DishEditorViewModel {
        DishEditorViewModel(draft: DishDraft(), isEditing: false, suggestions: [], diners: [me, eliza])
    }

    @Test func newDishDefaultsToOwner() {
        #expect(makeViewModel().draft.orderedByDinerID == me.id)
    }

    @Test func taggedWithoutProblemForShowsNote() {
        let viewModel = makeViewModel()
        viewModel.toggleTag(DietaryTag.containsShellfish.rawValue)
        #expect(viewModel.showsNoHeadsUpNote)
        viewModel.toggleProblem(DietaryTag.containsShellfish.rawValue, dinerID: eliza.id)
        #expect(!viewModel.showsNoHeadsUpNote)
    }

    @Test func profileKeywordSuggestsButNeverAutoAdds() {
        let viewModel = makeViewModel()
        viewModel.toggleTag(DietaryTag.containsGluten.rawValue)

        #expect(viewModel.suggestedDiners(for: DietaryTag.containsGluten.rawValue) == [eliza])
        #expect(viewModel.draft.flags.first?.problemForDinerIDs.isEmpty == true)
    }

    @Test func customTagIsAddedOnce() {
        let viewModel = makeViewModel()
        viewModel.addCustomTag("  Sesame ")
        viewModel.addCustomTag("sesame")
        #expect(viewModel.draft.flags.map(\.tag) == ["Sesame"])
    }
}
