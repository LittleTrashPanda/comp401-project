import Testing
@testable import ChefsJournal

struct DishDraftTests {
    @Test func blankNameIsIncomplete() {
        #expect(!DishDraft(name: "   ", tasteScore: 7, valueScore: 9).isComplete)
    }

    @Test func nameAndBothScoresIsComplete() {
        #expect(DishDraft(name: "California Roll", tasteScore: 7, valueScore: 9).isComplete)
    }
}
