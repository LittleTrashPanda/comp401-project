import SwiftData
import SwiftUI

struct HistoryView: View {
    let store: any JournalStoreProtocol

    @StateObject private var viewModel = HistoryViewModel()
    @Query(sort: \Visit.date) private var visits: [Visit]

    var body: some View {
        let snapshots = visits.map(VisitSnapshot.init)
        NavigationStack {
            List {
                HistoryControls(viewModel: viewModel)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                HistoryResultsSection(viewModel: viewModel)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(.journalPaper)
            .navigationTitle("History")
            .searchable(text: $viewModel.filter.searchText, prompt: "Restaurant, dish, or note")
            .toolbar {
                Button("Filters", systemImage: "line.3.horizontal.decrease", action: viewModel.beginEditingFilters)
            }
            .sheet(isPresented: $viewModel.isEditingFilters) {
                FilterSheet(viewModel: viewModel)
            }
            .journalDestinations(store: store)
            .task(id: HistoryRefreshKey(visits: snapshots, filter: viewModel.filter)) {
                await viewModel.refresh(visits: snapshots)
            }
        }
    }
}

private struct HistoryRefreshKey: Hashable {
    let visits: [VisitSnapshot]
    let filter: HistoryFilter
}

/// Restaurants/Dishes segment and removable active-filter chips.
private struct HistoryControls: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Picker("Show", selection: $viewModel.filter.segment) {
                Text("Restaurants").tag(HistoryFilter.Segment.restaurants)
                Text("Dishes").tag(HistoryFilter.Segment.dishes)
            }
            .pickerStyle(.segmented)
            if !viewModel.activeFilterChips.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: Spacing.xs) {
                        ForEach(viewModel.activeFilterChips) { chip in
                            ChipView(chip.title, kind: .removable { viewModel.remove(chip.kind) })
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

private struct HistoryResultsSection: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        if viewModel.results.isEmpty {
            EmptyStateView(systemImage: "magnifyingglass", title: "No matches",
                           message: "Try a different search or fewer filters.")
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        } else {
            Section {
                ForEach(Array(viewModel.results.enumerated()), id: \.element.id) { index, result in
                    NavigationLink(value: route(for: result)) {
                        HistoryRow(rank: index + 1, result: result, viewModel: viewModel)
                    }
                    .listRowBackground(Color.clear)
                    .accessibilityIdentifier("historyRow")
                }
            } header: {
                HStack {
                    Text("\(viewModel.results.count) results")
                    Spacer()
                    Text(viewModel.sortLabel)
                        .foregroundStyle(.journalMuted)
                }
                .font(.footnote.weight(.semibold))
            }
        }
    }

    private func route(for result: HistoryResult) -> HistoryRoute {
        switch result.kind {
        case .restaurant: .restaurant(RestaurantRoute(id: result.restaurantID))
        case .dish: .dish(DishRoute(restaurantID: result.restaurantID, dishName: result.name))
        }
    }
}

/// Wraps both destinations so a single NavigationLink type serves restaurants and dishes.
enum HistoryRoute: Hashable {
    case restaurant(RestaurantRoute)
    case dish(DishRoute)
}

private struct HistoryRow: View {
    let rank: Int
    let result: HistoryResult
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: Spacing.s) {
            Text(rank, format: .number)
                .font(.journalScore)
                .foregroundStyle(.journalMuted)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(result.name)
                    .font(.journalRowName)
                    .foregroundStyle(.journalInk)
                Text(viewModel.subtitle(for: result))
                    .font(.caption)
                    .foregroundStyle(.journalMuted)
                if let trend = viewModel.trend(for: result) {
                    TrendBadgeView(trend: trend)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(viewModel.averageText(for: result))
                .font(.journalScore)
                .foregroundStyle(.journalCobalt)
                .accessibilityLabel(Text("Average \(viewModel.averageText(for: result))"))
        }
        .padding(.vertical, Spacing.xxs)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Results") {
    let container = PreviewData.makeContainer()
    HistoryView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
}

#Preview("Empty, accessibility size") {
    let container = PreviewData.makeContainer(seeded: false)
    HistoryView(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
        .environment(\.dynamicTypeSize, .accessibility3)
}
