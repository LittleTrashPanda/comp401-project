import Foundation
import Testing
@testable import ChefsJournal

@MainActor
struct RestaurantDetailViewModelTests {
    private let locale = Locale(identifier: "en_US")
    private let now = Date.now

    private func bella() throws -> [VisitSnapshot] {
        try PreviewData.visitSnapshots(now: now).filter { $0.restaurantName == "Bella Italia" }
    }

    @Test func bellaSummaryShowsSixVisitsAndAverage() throws {
        let display = RestaurantDetailViewModel.makeDisplay(from: try bella(), photos: [:], now: now, locale: locale)

        #expect(display.visitCountText == "6")
        #expect(display.averageExperienceText == "7.8")
        #expect(display.lastVisitedText == "3 weeks ago")
        #expect(display.latestExperience == 8)
        #expect(display.visits.count == 6)
    }

    @Test func dishesAreOrderedBestFirst() throws {
        let display = RestaurantDetailViewModel.makeDisplay(from: try bella(), photos: [:], now: now, locale: locale)
        #expect(display.dishes.map(\.name) == ["Tiramisu", "Spaghetti Carbonara", "Calzone"])
    }

    @Test func visitsAreNewestFirst() throws {
        let display = RestaurantDetailViewModel.makeDisplay(from: try bella(), photos: [:], now: now, locale: locale)
        let dates = display.visits.map(\.date)
        #expect(dates == dates.sorted(by: >))
    }

    @Test func deletingOnlyVisitMarksRestaurantRemoved() throws {
        let journal = try TestJournal()
        let visit = try journal.store.saveNewVisit(Fixtures.visit())
        let viewModel = RestaurantDetailViewModel(store: journal.store)

        viewModel.requestDelete(visit)
        viewModel.confirmDelete(remainingVisitCount: 1)

        #expect(viewModel.didRemoveRestaurant)
        #expect(try journal.count(Restaurant.self) == 0)
    }
}

@MainActor
struct RestaurantDetailTrendTests {
    @Test func bellaChartsAllSixScoresAsSteady() throws {
        let now = Date.now
        let bella = try PreviewData.visitSnapshots(now: now).filter { $0.restaurantName == "Bella Italia" }
        let display = RestaurantDetailViewModel.makeDisplay(from: bella, photos: [:], now: now)

        #expect(display.experiencePoints.map(\.score) == [8, 9, 7, 8, 7, 8])
        #expect(display.trend == .steady)
    }

    @Test func singleVisitHasNoTrend() throws {
        let now = Date.now
        let sakura = try PreviewData.visitSnapshots(now: now).filter { $0.restaurantName == "Sakura Sushi" }
        let display = RestaurantDetailViewModel.makeDisplay(from: sakura, photos: [:], now: now)
        #expect(display.trend == nil)
        #expect(display.experiencePoints.count == 1)
    }
}
