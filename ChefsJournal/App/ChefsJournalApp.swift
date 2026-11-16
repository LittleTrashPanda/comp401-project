import os
import SwiftData
import SwiftUI

@main
struct ChefsJournalApp: App {
    @State private var modelContainer: ModelContainer
    @State private var journalStore: JournalStore

    init() {
        let container = AppLaunch.makeModelContainer()
        _modelContainer = State(initialValue: container)
        _journalStore = State(initialValue: JournalStore(modelContext: container.mainContext))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(store: journalStore)
        }
        .modelContainer(modelContainer)
    }
}

/// Builds the app's container, honouring the DEBUG launch arguments used by UI tests and manual checks.
@MainActor
enum AppLaunch {
    static let uiTestingArgument = "-uiTesting"
    static let seedSampleDataArgument = "-seedSampleData"
    static let seedLargeJournalArgument = "-seedLargeJournal"
    private static let largeJournalVisitCount = 500

    static func makeModelContainer() -> ModelContainer {
        let arguments = ProcessInfo.processInfo.arguments
        let inMemory = arguments.contains(uiTestingArgument)
        do {
            let container = try ModelContainerFactory.make(inMemory: inMemory)
            seedIfRequested(container, arguments: arguments)
            return container
        } catch {
            Logger.persistence.fault("Opening the journal failed: \(error.localizedDescription, privacy: .public)")
            return makeFallbackContainer()
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
