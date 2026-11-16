import Foundation
import Testing
@testable import ChefsJournal

struct BeenAWhileFinderTests {
    private let calendar = Calendar(identifier: .gregorian)
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func restaurant(_ name: String, scores: [Int], lastVisitDaysAgo: Int) -> RestaurantSnapshot {
        let id = UUID()
        let visits = scores.enumerated().map { index, score in
            VisitSnapshot(date: now.addingTimeInterval(-86_400 * Double(lastVisitDaysAgo + (scores.count - 1 - index) * 10)),
                          experienceScore: score, restaurantID: id, restaurantName: name)
        }
        return RestaurantSnapshot(id: id, name: name, visits: visits)
    }

    @Test func averageOfExactlyEightAtTwentyOneDaysIsIncluded() {
        let found = BeenAWhileFinder.suggestions(restaurants: [restaurant("A", scores: [8, 8], lastVisitDaysAgo: 21)],
                                                 now: now, calendar: calendar)
        #expect(found.map(\.name) == ["A"])
    }

    @Test func averageBelowEightIsExcluded() {
        let found = BeenAWhileFinder.suggestions(restaurants: [restaurant("A", scores: [8, 8, 8, 8, 8, 8, 8, 8, 8, 7], lastVisitDaysAgo: 30)],
                                                 now: now, calendar: calendar)
        #expect(found.isEmpty)
    }

    @Test func twentyDaysIsExcluded() {
        let found = BeenAWhileFinder.suggestions(restaurants: [restaurant("A", scores: [9], lastVisitDaysAgo: 20)],
                                                 now: now, calendar: calendar)
        #expect(found.isEmpty)
    }

    @Test func atMostTwoSortedByAverage() {
        let restaurants = [
            restaurant("A", scores: [8], lastVisitDaysAgo: 30),
            restaurant("B", scores: [10], lastVisitDaysAgo: 30),
            restaurant("C", scores: [9], lastVisitDaysAgo: 30),
        ]
        let found = BeenAWhileFinder.suggestions(restaurants: restaurants, now: now, calendar: calendar)
        #expect(found.map(\.name) == ["B", "C"])
    }
}
