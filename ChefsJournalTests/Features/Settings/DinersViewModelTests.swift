import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct DinersViewModelTests {
    @Test func savingNewDinerAddsIt() throws {
        let journal = try TestJournal()
        let viewModel = DinersViewModel(store: journal.store)
        viewModel.beginAdding()
        viewModel.editor?.name = "Eliza"
        viewModel.editor?.dietaryProfile = "Gluten intolerant"

        #expect(viewModel.canSaveEditor)
        viewModel.saveEditor()

        #expect(viewModel.editor == nil)
        #expect(try journal.store.diners().map(\.name) == ["Eliza"])
    }

    @Test func blankNameCannotBeSaved() throws {
        let viewModel = DinersViewModel(store: try TestJournal().store)
        viewModel.beginAdding()
        viewModel.editor?.name = "   "
        #expect(!viewModel.canSaveEditor)
    }

    @Test func ownerCannotBeOfferedForDeletion() throws {
        let journal = try TestJournal()
        try journal.store.seedOwnerIfNeeded()
        let owner = try #require(try journal.store.diners().first)
        let viewModel = DinersViewModel(store: journal.store)

        viewModel.requestDelete(owner)

        #expect(viewModel.dinerPendingDeletion == nil)
    }

    @Test func confirmingDeletionRemovesDiner() throws {
        let journal = try TestJournal()
        let liam = try journal.store.addDiner(name: "Liam", dietaryProfile: "")
        let viewModel = DinersViewModel(store: journal.store)

        viewModel.requestDelete(liam)
        viewModel.confirmDelete()

        #expect(try journal.store.diners().isEmpty)
    }
}
