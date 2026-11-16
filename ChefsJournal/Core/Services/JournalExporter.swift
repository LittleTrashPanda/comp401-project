import Foundation
import SwiftUI

/// Everything an export needs, as values.
struct JournalSnapshot: Sendable {
    var visits: [VisitSnapshot]
    /// Dish id → photo, only filled when photos are included.
    var photos: [UUID: Data] = [:]

    var restaurants: [RestaurantSnapshot] {
        RestaurantSnapshot.grouping(visits).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}

enum ExportError: LocalizedError {
    case pdfRenderingFailed

    var errorDescription: String? {
        String(localized: "The PDF couldn’t be created. Please try again.")
    }
}

/// Writes the journal as CSV (one row per dish entry) or a PDF (one section per restaurant).
struct JournalExporter {
    private static let columns: [LocalizedStringResource] = [
        "Restaurant", "Area", "Date", "Visit type", "Experience", "Dish", "Taste", "Value",
        "Would order again", "Ordered by", "Tags", "Problem for", "Visit note", "Dish note",
    ]
    private static let lineEnding = "\r\n"
    private static let listSeparator = "; "

    var locale: Locale = .autoupdatingCurrent
    var timeZone: TimeZone = .autoupdatingCurrent

    // MARK: CSV

    func csv(from snapshot: JournalSnapshot) -> Data {
        let header = Self.columns.map { $0.string(in: locale) }
        let rows = snapshot.visits.sorted { $0.date < $1.date }.flatMap(rows(for:))
        let lines = ([header] + rows).map { $0.map(Self.escaped).joined(separator: ",") }
        return Data((lines.joined(separator: Self.lineEnding) + Self.lineEnding).utf8)
    }

    private func rows(for visit: VisitSnapshot) -> [[String]] {
        let visitFields = [visit.restaurantName, visit.restaurantArea, isoDate(visit.date),
                           visit.visitType.title.string(in: locale), String(visit.experienceScore)]
        guard !visit.dishes.isEmpty else {
            return [visitFields + Array(repeating: "", count: 7) + [visit.note, ""]]
        }
        return visit.dishes.map { dish in
            visitFields + [
                dish.name, String(dish.tasteScore), String(dish.valueScore),
                (dish.wouldOrderAgain ? String(localized: "Yes") : String(localized: "No")),
                dish.orderedBy?.name ?? "",
                dish.flags.map { DietaryTag.title(for: $0.tag, locale: locale) }.joined(separator: Self.listSeparator),
                problemFor(dish),
                visit.note, dish.note,
            ]
        }
    }

    private func problemFor(_ dish: DishSnapshot) -> String {
        dish.flags.filter { !$0.problemFor.isEmpty }.map { flag in
            let names = flag.problemFor.map(\.name).joined(separator: ", ")
            return "\(DietaryTag.title(for: flag.tag, locale: locale)): \(names)"
        }
        .joined(separator: Self.listSeparator)
    }

    private func isoDate(_ date: Date) -> String {
        var format = Date.ISO8601FormatStyle().year().month().day()
        format.timeZone = timeZone
        return date.formatted(format)
    }

    /// RFC 4180: quote fields containing commas, quotes or line breaks, doubling inner quotes.
    private static func escaped(_ field: String) -> String {
        guard field.contains(where: { $0 == "," || $0 == "\"" || $0.isNewline }) else { return field }
        return "\"" + field.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    // MARK: PDF

    @MainActor
    func pdf(from snapshot: JournalSnapshot, includePhotos: Bool) throws -> Data {
        let output = NSMutableData()
        guard let consumer = CGDataConsumer(data: output),
              let context = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            throw ExportError.pdfRenderingFailed
        }
        let pages = snapshot.restaurants.isEmpty ? [nil] : snapshot.restaurants.map(Optional.some)
        for restaurant in pages {
            let page = JournalPDFPage(restaurant: restaurant, photos: includePhotos ? snapshot.photos : [:])
                .environment(\.locale, locale)
            let renderer = ImageRenderer(content: page)
            renderer.proposedSize = ProposedViewSize(width: JournalPDFPage.pageWidth, height: nil)
            renderer.render { size, draw in
                var box = CGRect(origin: .zero, size: size)
                context.beginPage(mediaBox: &box)
                draw(context)
                context.endPage()
            }
        }
        context.closePDF()
        return output as Data
    }
}
