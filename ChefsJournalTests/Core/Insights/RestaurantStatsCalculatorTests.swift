import Foundation
import Testing
@testable import ChefsJournal

struct RestaurantStatsCalculatorTests {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func visit(daysAgo: Int, experience: Int, dishes: [DishSnapshot] = []) -> VisitSnapshot {
        VisitSnapshot(date: now.addingTimeInterval(-86_400 * Double(daysAgo)), experienceScore: experience, dishes: dishes)
    }

    @Test func bellaAverageIsSevenPointEight() throws {
        let scores = [8, 9, 7, 8, 7, 8]
        let visits = scores.enumerated().map { visit(daysAgo: 100 - $0.offset * 10, experience: $0.element) }

        let summary = RestaurantStatsCalculator.summary(for: visits)

        #expect(summary.visitCount == 6)
        let average = try #require(summary.averageExperience)
        #expect(abs(average - 47.0 / 6.0) < 0.0001)
        #expect(ScoreFormatting.average(average, locale: Locale(identifier: "en_US")) == "7.8")
        #expect(summary.lastVisited == visits.last?.date)
    }

    @Test func sakuraSummaryHasOneVisitAndBestDish() {
        let roll = DishSnapshot(name: "California Roll", tasteScore: 7, valueScore: 9, wouldOrderAgain: true)
        let summary = RestaurantStatsCalculator.summary(for: [visit(daysAgo: 0, experience: 5, dishes: [roll])])

        #expect(summary.visitCount == 1)
        #expect(summary.averageExperience == 5.0)
        #expect(summary.bestDishes.map(\.name) == ["California Roll"])
    }

    @Test func emptyVisitsGiveEmptySummary() {
        let summary = RestaurantStatsCalculator.summary(for: [])
        #expect(summary.visitCount == 0)
        #expect(summary.averageExperience == nil)
        #expect(summary.lastVisited == nil)
        #expect(summary.bestDishes.isEmpty)
    }

    @Test func bestDishesUseLatestInstanceAndRankTasteThenValueThenRecency() {
        let older = now.addingTimeInterval(-86_400 * 30)
        let newer = now
        let dishes = [
            DishSnapshot(name: "Calzone", tasteScore: 10, valueScore: 10, date: older),
            DishSnapshot(name: "calzone ", tasteScore: 5, valueScore: 5, date: newer),
            DishSnapshot(name: "Tiramisu", tasteScore: 9, valueScore: 8, date: older),
            DishSnapshot(name: "Carbonara", tasteScore: 9, valueScore: 7, date: newer),
            DishSnapshot(name: "Lasagne", tasteScore: 9, valueScore: 8, date: newer),
        ]
        let summary = RestaurantStatsCalculator.summary(for: [VisitSnapshot(date: newer, experienceScore: 8, dishes: dishes)])

        #expect(summary.bestDishes.map(\.name) == ["Lasagne", "Tiramisu", "Carbonara", "calzone "])
    }
}
