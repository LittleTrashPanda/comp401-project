import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct PreviewDataTests {
    @Test func seedMatchesDescriptionExamples() throws {
        let now = Date.now
        let restaurants = RestaurantSnapshot.grouping(try PreviewData.visitSnapshots(now: now))
        let summaries = Dictionary(uniqueKeysWithValues: restaurants.map { ($0.name, RestaurantStatsCalculator.summary(for: $0.visits)) })

        let bella = try #require(summaries["Bella Italia"])
        #expect(bella.visitCount == 6)
        #expect(ScoreFormatting.average(try #require(bella.averageExperience), locale: Locale(identifier: "en_US")) == "7.8")

        let hearthside = try #require(summaries["Hearthside Steakhouse"])
        #expect(hearthside.visitCount == 5)
        #expect(hearthside.averageExperience == 8.6)

        let sakura = try #require(summaries["Sakura Sushi"])
        #expect(sakura.visitCount == 1)
        #expect(sakura.averageExperience == 5.0)
        #expect(sakura.bestDishes.map(\.name) == ["California Roll"])
    }
}
