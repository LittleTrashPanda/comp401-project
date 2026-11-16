import SwiftData
import Testing
@testable import ChefsJournal

@MainActor
struct AppLaunchTests {
    private struct OpenFailure: Error {}

    @Test func failingStoreFallsBackInMemoryAndReportsIt() {
        let launch = AppLaunch.openJournal(cloudKit: false, arguments: []) { _, _ in throw OpenFailure() }
        #expect(launch.didFailToOpenStore)
    }

    @Test func workingStoreReportsNoFailure() {
        let launch = AppLaunch.openJournal(cloudKit: false, arguments: []) { _, cloudKit in
            try ModelContainerFactory.make(inMemory: true, cloudKit: cloudKit)
        }
        #expect(!launch.didFailToOpenStore)
    }
}
