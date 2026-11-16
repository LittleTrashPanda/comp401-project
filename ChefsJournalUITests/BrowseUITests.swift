import XCTest

final class BrowseUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testBellaShowsSteadyTrendAndHeadsUp() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-seedSampleData"]
        app.launch()

        let bellaRow = app.buttons.matching(identifier: "journalVisitRow")
            .matching(NSPredicate(format: "label CONTAINS 'Bella Italia'")).firstMatch
        XCTAssertTrue(bellaRow.waitForExistence(timeout: 5))
        bellaRow.tap()

        XCTAssertTrue(app.staticTexts["Calzone — contains gluten (Eliza)"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["Trend: Steady"].exists)
    }

    @MainActor
    func testGraceFindsHearthsideWithFilters() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-seedSampleData"]
        app.launch()

        app.tabBars.buttons["History"].tap()
        app.buttons["Filters"].tap()
        app.sliders.firstMatch.adjust(toNormalizedSliderPosition: 0.8)
        app.buttons["Last visited 3+ weeks ago"].tap()
        app.buttons["Apply"].tap()

        let rows = app.buttons.matching(identifier: "historyRow")
        XCTAssertTrue(rows.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(rows.count, 1)
        XCTAssertTrue(rows.firstMatch.label.contains("Hearthside Steakhouse"))
        rows.firstMatch.tap()
        XCTAssertTrue(app.staticTexts["Hearthside Steakhouse"].waitForExistence(timeout: 5))
    }
}
