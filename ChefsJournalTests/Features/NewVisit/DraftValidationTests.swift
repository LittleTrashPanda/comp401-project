import Testing
@testable import ChefsJournal

struct DraftValidationTests {
    @Test func completeDraftIsComplete() {
        #expect(Fixtures.visit().isComplete)
    }

    @Test func draftWithZeroScoreIsIncomplete() {
        #expect(!Fixtures.visit(experience: 0).isComplete)
        #expect(!Fixtures.dish(taste: 0).isComplete)
        #expect(!Fixtures.dish(value: 11).isComplete)
    }

    @Test func draftWithBlankDishNameIsIncomplete() {
        #expect(!Fixtures.dish("   ").isComplete)
        #expect(!Fixtures.visit(dishes: [Fixtures.dish("   ")]).isComplete)
    }

    @Test func draftWithoutDishesIsIncomplete() {
        #expect(!Fixtures.visit(dishes: []).isComplete)
    }

    @Test func draftWithBlankRestaurantIsIncomplete() {
        #expect(!Fixtures.visit(at: "  ").isComplete)
    }
}
