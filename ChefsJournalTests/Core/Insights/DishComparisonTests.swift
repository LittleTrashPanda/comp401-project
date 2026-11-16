import Foundation
import Testing
@testable import ChefsJournal

struct DishComparisonTests {
    private let sakura = UUID()
    private let tokyo = UUID()
    private let oct12 = Date(timeIntervalSince1970: 1_791_763_200)
    private let nov6 = Date(timeIntervalSince1970: 1_793_923_200)

    private var dishes: [DishSnapshot] {
        [
            DishSnapshot(name: "California Roll", tasteScore: 8, valueScore: 6, date: oct12, restaurantID: tokyo, restaurantName: "Tokyo House"),
            DishSnapshot(name: "California Roll", tasteScore: 5, valueScore: 5, date: oct12.addingTimeInterval(-86_400 * 30),
                         restaurantID: sakura, restaurantName: "Sakura Sushi"),
            DishSnapshot(name: "California Roll", tasteScore: 7, valueScore: 9, date: nov6, restaurantID: sakura, restaurantName: "Sakura Sushi"),
            DishSnapshot(name: "Miso Soup", tasteScore: 6, valueScore: 6, date: nov6, restaurantID: sakura, restaurantName: "Sakura Sushi"),
        ]
    }

    @Test func matchesTrimmedCaseInsensitiveNameAndUsesLatestPerRestaurant() {
        let rows = DishComparison.rows(for: "california roll ", currentRestaurantID: sakura, dishes: dishes)

        #expect(rows.map(\.restaurantName) == ["Tokyo House", "Sakura Sushi"])
        #expect(rows.map(\.tasteScore) == [8, 7])
        #expect(rows.map(\.valueScore) == [6, 9])
        #expect(rows.map(\.isCurrent) == [false, true])
    }

    @Test func noMatchGivesEmptyArray() {
        #expect(DishComparison.rows(for: "Ramen", currentRestaurantID: sakura, dishes: dishes).isEmpty)
    }

    @Test func seededCaliforniaRollComparesTokyoAndSakura() async throws {
        let visits = try await PreviewData.visitSnapshots(now: .now)
        let sakuraID = try #require(visits.first { $0.restaurantName == "Sakura Sushi" }?.restaurantID)
        let rows = DishComparison.rows(for: "California Roll", currentRestaurantID: sakuraID, dishes: visits.flatMap(\.dishes))
        #expect(rows.map(\.restaurantName) == ["Tokyo House", "Sakura Sushi"])
        #expect(rows.first?.tasteScore == 8)
        #expect(rows.first?.valueScore == 6)
    }
}
