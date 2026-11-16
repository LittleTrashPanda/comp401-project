import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct DishDetailViewModelTests {
    private let locale = Locale(identifier: "en_US")
    private let now = Date(timeIntervalSince1970: 1_800_000_000)
    private let sakuraID = UUID()

    private func visits() -> [VisitSnapshot] {
        let older = now.addingTimeInterval(-86_400 * 30)
        return [
            VisitSnapshot(id: UUID(), date: older, restaurantID: sakuraID, restaurantName: "Sakura Sushi",
                          dishes: [DishSnapshot(name: "California Roll", tasteScore: 7, valueScore: 9, date: older, restaurantID: sakuraID)]),
            VisitSnapshot(id: UUID(), date: now, restaurantID: sakuraID, restaurantName: "Sakura Sushi",
                          dishes: [DishSnapshot(name: "california roll", tasteScore: 8, valueScore: 6, wouldOrderAgain: true, date: now, restaurantID: sakuraID)]),
            VisitSnapshot(id: UUID(), date: now, restaurantID: UUID(), restaurantName: "Tokyo House",
                          dishes: [DishSnapshot(name: "California Roll", tasteScore: 1, valueScore: 1, date: now)]),
        ]
    }

    @Test func averagesInstancesAtSameRestaurantOnly() throws {
        let route = DishRoute(restaurantID: sakuraID, dishName: "California Roll")
        let display = try #require(DishDetailViewModel.makeDisplay(from: visits(), route: route, now: now, locale: locale))

        #expect(display.instances.count == 2)
        #expect(display.averageTasteText == "7.5")
        #expect(display.averageValueText == "7.5")
        #expect(display.lastOrdered == now)
        #expect(display.latest.tasteScore == 8)
        #expect(display.latest.wouldOrderAgain)
        #expect(display.restaurantName == "Sakura Sushi")
    }

    @Test func unknownDishGivesNoDisplay() {
        let route = DishRoute(restaurantID: sakuraID, dishName: "Ramen")
        #expect(DishDetailViewModel.makeDisplay(from: visits(), route: route, now: now, locale: locale) == nil)
    }
}
