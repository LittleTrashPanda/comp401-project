import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct PrivacyInsightsViewModelTests {
    private func makeViewModel() -> PrivacyInsightsViewModel {
        PrivacyInsightsViewModel(defaults: UserDefaults(suiteName: "PrivacyInsightsTests-\(UUID().uuidString)")!)
    }

    @Test func defaultIsOff() {
        #expect(!makeViewModel().isOptedIn)
    }

    @Test func turningOnIsImmediate() {
        let viewModel = makeViewModel()
        viewModel.setOptIn(true)
        #expect(viewModel.isOptedIn)
    }

    @Test func requestTurnOffAsksBeforeChanging() {
        let viewModel = makeViewModel()
        viewModel.setOptIn(true)

        viewModel.requestTurnOff()
        #expect(viewModel.isConfirmingTurnOff)
        #expect(viewModel.isOptedIn)

        viewModel.confirmTurnOff()
        #expect(!viewModel.isOptedIn)
        #expect(!viewModel.isConfirmingTurnOff)
    }

    @Test func choiceIsPersisted() {
        let defaults = UserDefaults(suiteName: "PrivacyInsightsTests-\(UUID().uuidString)")!
        PrivacyInsightsViewModel(defaults: defaults).setOptIn(true)
        #expect(PrivacyInsightsViewModel(defaults: defaults).isOptedIn)
    }
}
