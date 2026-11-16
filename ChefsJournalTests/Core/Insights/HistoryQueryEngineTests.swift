import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct HistoryQueryEngineTests {
    private let now = Date.now

    private func results(_ filter: HistoryFilter) throws -> [HistoryResult] {
        let visits = try PreviewData.visitSnapshots(now: now)
        return HistoryQueryEngine.results(restaurants: RestaurantSnapshot.grouping(visits), filter: filter, now: now)
    }

    @Test func minimumAverageEightAndThreeWeeksReturnsHearthsideOnly() throws {
        var filter = HistoryFilter()
        filter.minimumAverage = 8
        filter.lastVisitedOlderThan = .threeWeeks

        let found = try results(filter)

        #expect(found.map(\.name) == ["Hearthside Steakhouse"])
        #expect(found.first?.visitCount == 5)
        #expect(found.first?.average == 8.6)
    }

    @Test func searchMatchesNoteText() throws {
        var filter = HistoryFilter()
        filter.searchText = "TAKE-OUT"
        #expect(try results(filter).map(\.name) == ["Sakura Sushi"])
    }

    @Test func searchIsDiacriticInsensitive() throws {
        var filter = HistoryFilter()
        filter.searchText = "tíramisu"
        #expect(try results(filter).map(\.name) == ["Bella Italia"])
    }

    @Test func sortByVisitsPutsBellaFirst() throws {
        var filter = HistoryFilter()
        filter.sort = .visits
        #expect(try results(filter).first?.name == "Bella Italia")
    }

    @Test func sortByScorePutsHearthsideFirst() throws {
        #expect(try results(HistoryFilter()).first?.name == "Hearthside Steakhouse")
    }

    @Test func dishSegmentFiltersByTag() throws {
        var filter = HistoryFilter()
        filter.segment = .dishes
        filter.tag = DietaryTag.containsGluten.rawValue
        let found = try results(filter)
        #expect(found.map(\.name) == ["Calzone"])
        #expect(found.first?.restaurantName == "Bella Italia")
    }

    @Test func wouldOrderAgainOnlyExcludesCalzone() throws {
        var filter = HistoryFilter()
        filter.segment = .dishes
        filter.wouldOrderAgainOnly = true
        let names = try results(filter).map(\.name)
        #expect(!names.contains("Calzone"))
        #expect(names.contains("Tiramisu"))
    }

    @Test func dishesAtDifferentRestaurantsStaySeparate() throws {
        var filter = HistoryFilter()
        filter.segment = .dishes
        filter.searchText = "California"
        #expect(try results(filter).map(\.restaurantName).sorted() == ["Sakura Sushi", "Tokyo House"])
    }

    @Test func restaurantTasteScoreUsesDishAverages() throws {
        var filter = HistoryFilter()
        filter.scoreType = .value
        filter.searchText = "Hearthside"
        #expect(try results(filter).first?.average == 7.0)
    }

    @Test func emptyJournalReturnsNoResults() {
        #expect(HistoryQueryEngine.results(restaurants: [], filter: HistoryFilter(), now: now).isEmpty)
    }
}
