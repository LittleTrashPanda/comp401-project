import os
import SwiftData
import SwiftUI

@main
struct ChefsJournalApp: App {
    @State private var modelContainer: ModelContainer
    @State private var journalStore: JournalStore
    @State private var didFailToOpenStore: Bool
    @AppStorage(PreferenceKey.iCloudSyncEnabled) private var isSyncEnabled = false

    init() {
        let launch = AppLaunch.openJournal(cloudKit: CloudSyncConfiguration.isActive())
        _modelContainer = State(initialValue: launch.container)
        _journalStore = State(initialValue: JournalStore(modelContext: launch.container.mainContext))
        _didFailToOpenStore = State(initialValue: launch.didFailToOpenStore)
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(store: journalStore)
                .id(ObjectIdentifier(modelContainer))
                .onChange(of: isSyncEnabled) { rebuildContainer() }
                .alert("Your journal couldn’t be opened", isPresented: $didFailToOpenStore) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Anything you log now won’t be kept after you close the app. Restart Chef's Journal to try again.")
                }
        }
        .modelContainer(modelContainer)
    }

    /// Reopens the store with or without CloudKit when the sync preference changes.
    private func rebuildContainer() {
        guard CloudSyncConfiguration.isAvailable else { return }
        let launch = AppLaunch.openJournal(cloudKit: CloudSyncConfiguration.isActive())
        modelContainer = launch.container
        journalStore = JournalStore(modelContext: launch.container.mainContext)
        didFailToOpenStore = launch.didFailToOpenStore
    }
}

/// Builds the app's container, honouring the DEBUG launch arguments used by UI tests and manual checks.
@MainActor
enum AppLaunch {
    static let uiTestingArgument = "-uiTesting"
    static let seedSampleDataArgument = "-seedSampleData"
    static let seedLargeJournalArgument = "-seedLargeJournal"
    private static let largeJournalVisitCount = 500

    struct Result {
        let container: ModelContainer
        /// True when the on-disk store failed and a temporary in-memory one is in use.
        let didFailToOpenStore: Bool
    }

    static func openJournal(
        cloudKit: Bool,
        arguments: [String] = ProcessInfo.processInfo.arguments,
        makeContainer: (_ inMemory: Bool, _ cloudKit: Bool) throws -> ModelContainer = ModelContainerFactory.make
    ) -> Result {
        let inMemory = arguments.contains(uiTestingArgument)
        do {
            let container = try makeContainer(inMemory, cloudKit && !inMemory)
            seedIfRequested(container, arguments: arguments)
            return Result(container: container, didFailToOpenStore: false)
        } catch {
            Logger.persistence.fault("Opening the journal failed: \(error.localizedDescription, privacy: .public)")
            return Result(container: makeFallbackContainer(), didFailToOpenStore: true)
        }
    }

    private static func makeFallbackContainer() -> ModelContainer {
        do {
            return try ModelContainerFactory.make(inMemory: true)
        } catch {
            fatalError("Could not create even an in-memory journal: \(error)")
        }
    }

    private static func seedIfRequested(_ container: ModelContainer, arguments: [String]) {
        #if DEBUG
        do {
            if arguments.contains(seedSampleDataArgument) {
                try PreviewData.seed(into: container.mainContext, now: .now)
            }
            if arguments.contains(seedLargeJournalArgument) {
                try PreviewData.seedLargeJournal(into: container.mainContext, visitCount: largeJournalVisitCount, now: .now)
            }
        } catch {
            Logger.persistence.error("Seeding sample data failed: \(error.localizedDescription, privacy: .public)")
        }
        #endif
    }
}
