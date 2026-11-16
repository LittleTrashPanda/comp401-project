import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct HistoryViewModelTests {
    @Test func refreshRunsQueryWithCurrentFilter() async throws {
        let now = Date.now
        let viewModel = HistoryViewModel()
        viewModel.filter.minimumAverage = 8
        viewModel.filter.lastVisitedOlderThan = .threeWeeks

        await viewModel.refresh(visits: try PreviewData.visitSnapshots(now: now), now: now)

        #expect(viewModel.results.map(\.name) == ["Hearthside Steakhouse"])
    }

    @Test func activeChipsReflectFiltersAndCanBeRemoved() {
        let viewModel = HistoryViewModel()
        viewModel.filter.minimumAverage = 8
        viewModel.filter.wouldOrderAgainOnly = true

        #expect(viewModel.activeFilterChips.count == 2)
        viewModel.remove(.minimumAverage)
        #expect(viewModel.filter.minimumAverage == nil)
        #expect(viewModel.activeFilterChips.count == 1)
    }

    @Test func applyingSheetDraftReplacesFilterButKeepsSearch() {
        let viewModel = HistoryViewModel()
        viewModel.filter.searchText = "sushi"
        viewModel.beginEditingFilters()
        viewModel.filterDraft.sort = .visits
        viewModel.applyFilterDraft()

        #expect(viewModel.filter.sort == .visits)
        #expect(viewModel.filter.searchText == "sushi")
    }
}

@MainActor
struct HistoryViewModelCancellationTests {
    @Test func cancelledRefreshDoesNotOverwriteResults() async throws {
        let snapshots = try PreviewData.visitSnapshots(now: .now)
        let viewModel = HistoryViewModel()

        let task = Task { await viewModel.refresh(visits: snapshots) }
        task.cancel()
        await task.value

        #expect(viewModel.results.isEmpty)
    }
}
