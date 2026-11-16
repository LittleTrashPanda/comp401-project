import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Journal", systemImage: "book.closed") {
                PlaceholderTab(title: "My journal")
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
    RootTabView()
}

#Preview("Dark") {
    RootTabView()
        .preferredColorScheme(.dark)
}
