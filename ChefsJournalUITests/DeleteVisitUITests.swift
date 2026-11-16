import XCTest

final class DeleteVisitUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testDeletingOnlyVisitReturnsToJournalAndRemovesRow() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-seedSampleData"]
        app.launch()

        let sakuraRow = app.buttons.matching(identifier: "journalVisitRow").matching(NSPredicate(format: "label CONTAINS 'Sakura Sushi'")).firstMatch
        XCTAssertTrue(sakuraRow.waitForExistence(timeout: 5))
        sakuraRow.tap()

        let visitRow = app.buttons["visitRow"].firstMatch
        XCTAssertTrue(visitRow.waitForExistence(timeout: 5))
        visitRow.tap()
        app.buttons["Delete Visit"].firstMatch.tap()
        let confirm = app.alerts.buttons["Delete"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        confirm.tap()

        XCTAssertTrue(app.staticTexts["My journal"].waitForExistence(timeout: 5))
        XCTAssertFalse(sakuraRow.exists)
    }
}
