import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct NewVisitViewModelTests {
    private func makeViewModel(store: MockJournalStore = MockJournalStore()) -> NewVisitViewModel {
        NewVisitViewModel(store: store)
    }

    @Test func cannotAdvanceFromStepOneWithoutRestaurant() {
        let viewModel = makeViewModel()
        #expect(viewModel.currentStep == .restaurant)
        #expect(!viewModel.canAdvance)
    }

    @Test func addingNewRestaurantMovesToDetails() {
        let viewModel = makeViewModel()
        viewModel.searchQuery = "  Sakura Sushi "
        viewModel.addNewRestaurant()

        #expect(viewModel.draft.restaurantName == "Sakura Sushi")
        #expect(viewModel.isNewRestaurant)
        #expect(viewModel.currentStep == .details)
    }

    @Test func addingExactExistingNameSelectsExistingRestaurant() {
        let store = MockJournalStore()
        store.restaurantsToReturn = [Restaurant(name: "Sakura Sushi", area: "Downtown")]
        let viewModel = makeViewModel(store: store)
        viewModel.searchQuery = "sakura sushi"
        viewModel.addNewRestaurant()

        #expect(viewModel.draft.restaurantName == "Sakura Sushi")
        #expect(!viewModel.isNewRestaurant)
        #expect(viewModel.showsAddRow == false)
    }

    @Test func cannotAdvanceFromDetailsWithUnsetExperience() {
        let viewModel = makeViewModel()
        viewModel.searchQuery = "Sakura Sushi"
        viewModel.addNewRestaurant()

        #expect(!viewModel.canAdvance)
        viewModel.draft.experienceScore = 5
        #expect(viewModel.canAdvance)
    }

    @Test func cannotSaveWithZeroDishes() {
        let viewModel = makeViewModel()
        viewModel.searchQuery = "Sakura Sushi"
        viewModel.addNewRestaurant()
        viewModel.draft.experienceScore = 5
        viewModel.advance()

        #expect(viewModel.currentStep == .dishes)
        #expect(!viewModel.canAdvance)
    }

    @Test func saveCallsSaveNewVisitOnceWithDraft() throws {
        let store = MockJournalStore()
        let viewModel = makeViewModel(store: store)
        viewModel.searchQuery = "Sakura Sushi"
        viewModel.addNewRestaurant()
        viewModel.draft.experienceScore = 5
        viewModel.draft.note = "Long wait"
        viewModel.advance()
        viewModel.beginAddingDish()
        viewModel.commitDish(Fixtures.dish())

        #expect(viewModel.canAdvance)
        try viewModel.save()

        #expect(store.savedDrafts.count == 1)
        #expect(store.savedDrafts.first?.restaurantName == "Sakura Sushi")
        #expect(store.savedDrafts.first?.experienceScore == 5)
        #expect(store.savedDrafts.first?.dishes.map(\.name) == ["California Roll"])
    }

    @Test func hasUnsavedContentAfterTypingName() {
        let viewModel = makeViewModel()
        #expect(!viewModel.hasUnsavedContent)
        viewModel.searchQuery = "Sak"
        #expect(viewModel.hasUnsavedContent)
    }

    @Test func editingDishAtIndexZeroReplacesIt() {
        let viewModel = makeViewModel()
        viewModel.beginAddingDish()
        viewModel.commitDish(Fixtures.dish("California Roll"))
        viewModel.beginAddingDish()
        viewModel.commitDish(Fixtures.dish("Miso Soup"))

        viewModel.beginEditingDish(at: 0)
        var edited = viewModel.dishEditor?.draft ?? DishDraft()
        edited.tasteScore = 10
        viewModel.commitDish(edited)

        #expect(viewModel.draft.dishes.count == 2)
        #expect(viewModel.draft.dishes[0].name == "California Roll")
        #expect(viewModel.draft.dishes[0].tasteScore == 10)
    }

    @Test func backFromDetailsReturnsToRestaurantStep() {
        let viewModel = makeViewModel()
        viewModel.searchQuery = "Sakura Sushi"
        viewModel.addNewRestaurant()
        viewModel.goBack()
        #expect(viewModel.currentStep == .restaurant)
    }

    @Test func saveFailureSurfacesErrorMessage() {
        let store = MockJournalStore()
        store.errorToThrow = JournalStoreError.saveFailed
        let viewModel = makeViewModel(store: store)
        viewModel.searchQuery = "Sakura Sushi"
        viewModel.addNewRestaurant()
        viewModel.draft.experienceScore = 5
        viewModel.beginAddingDish()
        viewModel.commitDish(Fixtures.dish())

        #expect(throws: JournalStoreError.saveFailed) { try viewModel.save() }
    }
}
