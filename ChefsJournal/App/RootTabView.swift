import os
import SwiftUI

struct RootTabView: View {
    let store: any JournalStoreProtocol

    var body: some View {
        TabView {
            Tab("Journal", systemImage: "book.closed") {
                JournalView(store: store)
            }
            Tab("History", systemImage: "clock") {
                HistoryView(store: store)
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsView(store: store)
            }
        }
        .tint(.journalCobalt)
        .task { seedOwner() }
    }

    private func seedOwner() {
        do {
            try store.seedOwnerIfNeeded()
        } catch {
            Logger.persistence.error("Creating the owner diner failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview("Light") {
    let container = PreviewData.makeContainer()
    RootTabView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
}

#Preview("Dark") {
    let container = PreviewData.makeContainer()
    RootTabView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
