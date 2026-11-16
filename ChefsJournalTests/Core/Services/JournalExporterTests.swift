import Foundation
import Testing
@testable import ChefsJournal

struct JournalExporterTests {
    private let header = "Restaurant,Area,Date,Visit type,Experience,Dish,Taste,Value,Would order again,Ordered by,Tags,Problem for,Visit note,Dish note"
    private let exporter = JournalExporter(locale: Locale(identifier: "en_US"), timeZone: TimeZone(identifier: "UTC")!)
    private let date = Date(timeIntervalSince1970: 1_793_923_200) // 6 Nov 2026 UTC

    private func lines(_ data: Data) -> [String] {
        String(decoding: data, as: UTF8.self).components(separatedBy: "\r\n").filter { !$0.isEmpty }
    }

    private func visit(note: String = "", dishes: [DishSnapshot]) -> VisitSnapshot {
        VisitSnapshot(date: date, visitType: .dineIn, experienceScore: 5, note: note,
                      restaurantName: "Sakura Sushi", restaurantArea: "Downtown", dishes: dishes)
    }

    @Test func headerMatchesColumnOrder() {
        #expect(lines(exporter.csv(from: JournalSnapshot(visits: []))).first == header)
    }

    @Test func emptyJournalGivesHeaderOnly() {
        #expect(lines(exporter.csv(from: JournalSnapshot(visits: []))) == [header])
    }

    @Test func oneRowPerDishWithTagsJoined() {
        let eliza = DinerReference(id: UUID(), name: "Eliza")
        let roll = DishSnapshot(name: "California Roll", tasteScore: 7, valueScore: 9, wouldOrderAgain: true,
                                orderedBy: DinerReference(id: UUID(), name: "Me"),
                                flags: [FlagSnapshot(tag: DietaryTag.containsShellfish.rawValue, problemFor: []),
                                        FlagSnapshot(tag: "Sesame", problemFor: [eliza])])
        let soup = DishSnapshot(name: "Miso Soup", tasteScore: 6, valueScore: 6)
        let rows = lines(exporter.csv(from: JournalSnapshot(visits: [visit(dishes: [roll, soup])])))

        #expect(rows.count == 3)
        #expect(rows[1] == "Sakura Sushi,Downtown,2026-11-06,Dine-in,5,California Roll,7,9,Yes,Me,Contains shellfish; Sesame,Sesame: Eliza,,")
        #expect(rows[2].hasPrefix("Sakura Sushi,Downtown,2026-11-06,Dine-in,5,Miso Soup,6,6,No,,,,"))
    }

    @Test func noteWithCommaQuoteAndNewlineIsQuoted() {
        let note = "Long wait, \"cramped\"\nGet take-out"
        let csv = String(decoding: exporter.csv(from: JournalSnapshot(visits: [visit(note: note, dishes: [DishSnapshot(name: "Roll", tasteScore: 7, valueScore: 9)])])),
                         as: UTF8.self)
        #expect(csv.contains("\"Long wait, \"\"cramped\"\"\nGet take-out\""))
    }

    @Test @MainActor func pdfIsGeneratedForAJournal() throws {
        let data = try exporter.pdf(from: JournalSnapshot(visits: [visit(dishes: [DishSnapshot(name: "Roll", tasteScore: 7, valueScore: 9)])]),
                                    includePhotos: false)
        #expect(String(decoding: data.prefix(4), as: UTF8.self) == "%PDF")
    }
}
