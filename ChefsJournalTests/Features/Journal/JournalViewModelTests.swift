import Foundation
import SwiftData
import Testing
@testable import ChefsJournal

@MainActor
struct JournalViewModelTests {
    @Test func seededJournalShowsHearthsideBeenAWhileCard() throws {
        let now = Date.now
        let container = PreviewData.makeContainer(now: now)
        let visits = try container.mainContext.fetch(FetchDescriptor<Visit>())

        let cards = JournalViewModel().beenAWhileCards(for: visits, now: now)

        #expect(cards.map(\.name) == ["Hearthside Steakhouse"])
    }

    @Test func visitSavedShowsToast() {
        let viewModel = JournalViewModel()
        viewModel.visitSaved()
        #expect(viewModel.toastMessage == "Visit saved to your journal")
    }
}
