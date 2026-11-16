import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct BackupViewModelTests {
    private func makeViewModel(available: Bool = true) -> BackupViewModel {
        let defaults = UserDefaults(suiteName: "BackupViewModelTests-\(UUID().uuidString)")!
        return BackupViewModel(defaults: defaults, isSyncAvailable: available)
    }

    @Test(arguments: [
        (SyncStatus.off, "Your journal currently stays private on this iPhone."),
        (.syncing, "Syncing…"),
        (.synced(Date.now), "Last synced just now"),
        (.failed("Not signed in to iCloud."), "Sync failed: Not signed in to iCloud."),
        (.unavailable, "iCloud sync isn’t set up in this build of Chef's Journal."),
    ])
    func statusText(status: SyncStatus, expected: String) {
        let viewModel = makeViewModel()
        viewModel.status = status
        #expect(viewModel.statusText == expected)
    }

    @Test func syncIsOffByDefault() {
        #expect(!makeViewModel().isSyncEnabled)
    }

    @Test func unavailableSyncCannotBeTurnedOn() {
        let viewModel = makeViewModel(available: false)
        viewModel.setSyncEnabled(true)
        #expect(!viewModel.isSyncEnabled)
        #expect(viewModel.status == .unavailable)
    }

    @Test func eventMappingCoversSuccessFailureAndInProgress() {
        let date = Date.now
        #expect(SyncStatusMonitor.status(endDate: nil, succeeded: false, errorDescription: nil) == .syncing)
        #expect(SyncStatusMonitor.status(endDate: date, succeeded: true, errorDescription: nil) == .synced(date))
        #expect(SyncStatusMonitor.status(endDate: date, succeeded: false, errorDescription: "Offline") == .failed("Offline"))
    }
}
