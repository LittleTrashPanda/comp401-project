import XCTest

final class LogVisitUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testLogMealAppearsAtTopOfJournal() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        app.buttons["newLogButton"].firstMatch.tap()

        let search = app.textFields["restaurantSearchField"]
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("Sakura Sushi")
        app.buttons["addRestaurantButton"].tap()

        app.sliders["experienceSlider"].adjust(toNormalizedSliderPosition: 0.5)
        app.buttons["primaryActionButton"].tap()

        app.buttons["addDishButton"].tap()
        let dishName = app.textFields["dishNameField"]
        XCTAssertTrue(dishName.waitForExistence(timeout: 5))
        dishName.tap()
        dishName.typeText("California Roll")
        app.sliders["tasteSlider"].adjust(toNormalizedSliderPosition: 0.7)
        app.sliders["valueSlider"].adjust(toNormalizedSliderPosition: 0.9)
        app.buttons["dishDoneButton"].tap()

        app.buttons["primaryActionButton"].tap()

        let firstRow = app.buttons.matching(identifier: "journalVisitRow").firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 5))
        XCTAssertTrue(firstRow.label.contains("Sakura Sushi"), "First row was: \(firstRow.label)")
    }
}
