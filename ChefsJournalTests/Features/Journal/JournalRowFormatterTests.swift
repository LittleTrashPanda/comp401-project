import Foundation
import Testing
@testable import ChefsJournal

struct JournalRowFormatterTests {
    private let formatter = JournalRowFormatter(calendar: Calendar(identifier: .gregorian), locale: Locale(identifier: "en_US"))
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    @Test(arguments: [("Bella Italia", "BI"), ("Sakura", "S"), ("hearthside steak house", "HS"), ("  ", "")])
    func initials(name: String, expected: String) {
        #expect(formatter.initials(for: name) == expected)
    }

    @Test func singleDishWouldOrderAgainSubtitle() {
        let dishes = [DishSnapshot(name: "California Roll", wouldOrderAgain: true)]
        #expect(formatter.dishSummary(for: dishes) == "California Roll · Would order again")
    }

    @Test func singleDishWithoutOrderAgainShowsName() {
        #expect(formatter.dishSummary(for: [DishSnapshot(name: "Calzone")]) == "Calzone")
    }

    @Test func twoDishesAreCommaJoined() {
        let dishes = [DishSnapshot(name: "Spaghetti Carbonara", wouldOrderAgain: true), DishSnapshot(name: "Calzone")]
        #expect(formatter.dishSummary(for: dishes) == "Spaghetti Carbonara, Calzone")
    }

    @Test func noDishesGivesPrompt() {
        #expect(formatter.dishSummary(for: []) == "No dishes logged")
    }

    @Test func dateLineForTakeOutToday() {
        let visit = VisitSnapshot(date: now, visitType: .takeOut)
        #expect(formatter.dateLine(for: visit, now: now) == "Today · Take-out")
    }

    @Test func dateLineForDineInYesterday() {
        let visit = VisitSnapshot(date: now.addingTimeInterval(-86_400), visitType: .dineIn)
        #expect(formatter.dateLine(for: visit, now: now) == "Yesterday · Dine-in")
    }
}
