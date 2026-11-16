import Combine
import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    enum FilterKind: Hashable {
        case minimumAverage
        case lastVisited
        case visitType
        case tag
        case diner
        case wouldOrderAgain
    }

    struct ActiveFilterChip: Identifiable, Hashable {
        let kind: FilterKind
        let title: String

        var id: FilterKind { kind }
    }

    @Published var filter = HistoryFilter()
    @Published var filterDraft = HistoryFilter()
    @Published var isEditingFilters = false
    @Published private(set) var results: [HistoryResult] = []
    @Published private(set) var availableTags: [String] = DietaryTag.allCases.map(\.rawValue)
    @Published private(set) var dinerNames: [UUID: String] = [:]

    // MARK: Query

    func refresh(visits: [VisitSnapshot], now: Date = .now) async {
        let currentFilter = filter
        let found = await Self.query(visits: visits, filter: currentFilter, now: now)
        // A newer search or filter replaced this one while it ran; its results would be stale.
        guard !Task.isCancelled else { return }
        results = found
        let dishes = visits.flatMap(\.dishes)
        let usedTags = Set(dishes.flatMap(\.flags).map(\.tag))
        let presets = DietaryTag.allCases.map(\.rawValue)
        availableTags = presets + usedTags.subtracting(presets).sorted()
        dinerNames = Dictionary(dishes.compactMap(\.orderedBy).map { ($0.id, $0.name) }, uniquingKeysWith: { first, _ in first })
    }

    /// Runs off the main actor so typing in search stays smooth on large journals.
    private nonisolated static func query(visits: [VisitSnapshot], filter: HistoryFilter, now: Date) async -> [HistoryResult] {
        HistoryQueryEngine.results(restaurants: RestaurantSnapshot.grouping(visits), filter: filter, now: now)
    }

    // MARK: Filter sheet

    func beginEditingFilters() {
        filterDraft = filter
        isEditingFilters = true
    }

    func applyFilterDraft() {
        var applied = filterDraft
        applied.searchText = filter.searchText
        applied.segment = filter.segment
        filter = applied
        isEditingFilters = false
    }

    func resetFilterDraft() {
        filterDraft = HistoryFilter(segment: filter.segment, searchText: filter.searchText)
    }

    // MARK: Chips

    var activeFilterChips: [ActiveFilterChip] {
        var chips: [ActiveFilterChip] = []
        if let minimum = filter.minimumAverage {
            chips.append(.init(kind: .minimumAverage, title: String(localized: "\(minimum)+ average")))
        }
        if let lastVisited = filter.lastVisitedOlderThan {
            chips.append(.init(kind: .lastVisited, title: Self.title(for: lastVisited).string(in: .autoupdatingCurrent)))
        }
        if let visitType = filter.visitType {
            chips.append(.init(kind: .visitType, title: String(localized: visitType.title)))
        }
        if let tag = filter.tag {
            chips.append(.init(kind: .tag, title: DietaryTag.title(for: tag)))
        }
        if let dinerID = filter.dinerID {
            chips.append(.init(kind: .diner, title: dinerNames[dinerID] ?? String(localized: "Diner")))
        }
        if filter.wouldOrderAgainOnly {
            chips.append(.init(kind: .wouldOrderAgain, title: String(localized: "Would order again")))
        }
        return chips
    }

    func remove(_ kind: FilterKind) {
        switch kind {
        case .minimumAverage: filter.minimumAverage = nil
        case .lastVisited: filter.lastVisitedOlderThan = nil
        case .visitType: filter.visitType = nil
        case .tag: filter.tag = nil
        case .diner: filter.dinerID = nil
        case .wouldOrderAgain: filter.wouldOrderAgainOnly = false
        }
    }

    // MARK: Display strings

    var sortLabel: LocalizedStringResource { Self.title(for: filter.sort) }

    func subtitle(for result: HistoryResult, now: Date = .now) -> String {
        let lastText = String(localized: result.lastVisited.lastVisitedDescription(relativeTo: now))
        switch result.kind {
        case .restaurant:
            return String(localized: "\(result.visitCount) visits · Last visited \(lastText)")
        case .dish:
            return String(localized: "\(result.restaurantName) · Ordered \(result.visitCount) times · \(lastText)")
        }
    }

    func averageText(for result: HistoryResult) -> String {
        ScoreFormatting.average(result.average)
    }

    func trend(for result: HistoryResult) -> Trend? {
        TrendCalculator.trend(for: result.scoresOldestFirst)
    }

    static func title(for lastVisited: HistoryFilter.LastVisited) -> LocalizedStringResource {
        switch lastVisited {
        case .oneWeek: "Last visited 1+ week ago"
        case .threeWeeks: "Last visited 3+ weeks ago"
        case .threeMonths: "Last visited 3+ months ago"
        }
    }

    static func title(for sort: HistoryFilter.Sort) -> LocalizedStringResource {
        switch sort {
        case .score: "Highest average"
        case .recency: "Most recent"
        case .visits: "Most visits"
        }
    }

    static func title(for scoreType: HistoryFilter.ScoreType) -> LocalizedStringResource {
        switch scoreType {
        case .experience: "Experience"
        case .taste: "Taste"
        case .value: "Value"
        }
    }
}
