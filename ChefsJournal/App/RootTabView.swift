import SwiftUI

struct RootTabView: View {
    let store: any JournalStoreProtocol

    var body: some View {
        TabView {
            Tab("Journal", systemImage: "book.closed") {
                JournalView(store: store)
            }
            Tab("History", systemImage: "clock") {
                PlaceholderTab(title: "History")
            }
            Tab("Settings", systemImage: "gearshape") {
                PlaceholderTab(title: "Settings")
            }
        }
        .tint(.journalCobalt)
    }
}

private struct PlaceholderTab: View {
    let title: LocalizedStringKey

    var body: some View {
        NavigationStack {
            Color.journalPaper
                .ignoresSafeArea()
                .navigationTitle(title)
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
