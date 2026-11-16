import Foundation

/// Builds the display strings for a Journal visit row.
struct JournalRowFormatter {
    private static let maximumInitials = 2

    var calendar: Calendar = .current
    var locale: Locale = .autoupdatingCurrent

    func initials(for restaurantName: String) -> String {
        restaurantName
            .split(whereSeparator: \.isWhitespace)
            .prefix(Self.maximumInitials)
            .compactMap(\.first)
            .map { String($0).uppercased(with: locale) }
            .joined()
    }

    func dishSummary(for dishes: [DishSnapshot]) -> String {
        switch dishes.count {
        case 0:
            return String(localized: "No dishes logged", locale: locale)
        case 1 where dishes[0].wouldOrderAgain:
            return String(localized: "\(dishes[0].name) · Would order again", locale: locale)
        default:
            return dishes.map(\.name).joined(separator: ", ")
        }
    }

    func dateLine(for visit: VisitSnapshot, now: Date) -> String {
        let day = dayDescription(for: visit.date, now: now)
        let visitType = visit.visitType.title.string(in: locale)
        return String(localized: "\(day) · \(visitType)", locale: locale)
    }

    func row(for visit: VisitSnapshot, now: Date) -> JournalRow {
        JournalRow(
            id: visit.id,
            restaurantID: visit.restaurantID,
            restaurantName: visit.restaurantName,
            initials: initials(for: visit.restaurantName),
            dateLine: dateLine(for: visit, now: now),
            dishSummary: dishSummary(for: visit.dishes),
            experienceScore: visit.experienceScore
        )
    }

    private func dayDescription(for date: Date, now: Date) -> String {
        if calendar.isDate(date, inSameDayAs: now) {
            return String(localized: "Today", locale: locale)
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now), calendar.isDate(date, inSameDayAs: yesterday) {
            return String(localized: "Yesterday", locale: locale)
        }
        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).locale(locale))
    }
}

struct JournalRow: Identifiable, Hashable {
    let id: UUID
    let restaurantID: UUID
    let restaurantName: String
    let initials: String
    let dateLine: String
    let dishSummary: String
    let experienceScore: Int
}
