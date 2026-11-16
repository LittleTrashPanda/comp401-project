import SwiftData
import SwiftUI

struct JournalView: View {
    let store: any JournalStoreProtocol

    @StateObject private var viewModel = JournalViewModel()
    @Query(sort: \Visit.date, order: .reverse) private var visits: [Visit]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: Spacing.section) {
                    JournalHeroView(onNewLog: viewModel.startNewLog)
                    recentVisits
                }
                .padding(.horizontal, Spacing.gutter)
                .padding(.bottom, Spacing.section)
            }
            .background(.journalPaper)
            .toolbar(.hidden, for: .navigationBar)
            .journalDestinations(store: store)
            .successToast(message: $viewModel.toastMessage)
            .sheet(isPresented: $viewModel.isPresentingNewVisit) {
                NewVisitSheet(store: store, onSaved: viewModel.visitSaved)
            }
        }
    }

    @ViewBuilder
    private var recentVisits: some View {
        if visits.isEmpty {
            EmptyStateView(systemImage: "book.closed", title: "No visits yet",
                           message: "Log your first meal and it will appear here.") {
                Button("New Log", systemImage: "plus", action: viewModel.startNewLog)
                    .buttonStyle(PrimaryButtonStyle())
            }
        } else {
            JournalRecentVisitsSection(rows: viewModel.rows(for: visits, now: .now))
        }
    }
}

private struct JournalRecentVisitsSection: View {
    let rows: [JournalRowDisplay]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent visits")
                    .font(.headline)
                Spacer()
                Text("Newest first")
                    .font(.caption)
                    .foregroundStyle(.journalMuted)
            }
            .padding(.bottom, Spacing.xs)
            ForEach(rows) { display in
                NavigationLink(value: RestaurantRoute(id: display.row.restaurantID)) {
                    JournalVisitRow(row: display.row, photoData: display.photoData)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("journalVisitRow")
                Divider().overlay(.journalRule)
            }
        }
    }
}

#Preview("Populated") {
    let container = PreviewData.makeContainer()
    JournalView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
}

#Preview("Empty") {
    let container = PreviewData.makeContainer(seeded: false)
    JournalView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
}

#Preview("Dark, accessibility size") {
    let container = PreviewData.makeContainer()
    JournalView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
        .preferredColorScheme(.dark)
        .environment(\.dynamicTypeSize, .accessibility3)
}
