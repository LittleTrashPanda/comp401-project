import Foundation
import Testing
@testable import ChefsJournal

struct DateRelativeTests {
    private static let calendar = Calendar(identifier: .gregorian)
    private static let now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 16, hour: 12))!

    @Test(arguments: [
        (0, "Today"),
        (1, "Yesterday"),
        (3, "3 days ago"),
        (21, "3 weeks ago"),
        (62, "2 months ago"),
    ])
    func lastVisitedDescription(daysAgo: Int, expected: String) throws {
        let date = try #require(Self.calendar.date(byAdding: .day, value: -daysAgo, to: Self.now))
        let description = date.lastVisitedDescription(relativeTo: Self.now, calendar: Self.calendar)
        #expect(String(localized: description) == expected)
    }
}
