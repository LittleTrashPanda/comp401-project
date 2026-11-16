import Foundation

extension Date {
    private static let daysPerWeek = 7
    private static let daysPerMonth = 30
    private static let daysPerYear = 365

    /// A short, human description of how long ago this date was, e.g. "3 weeks ago".
    func lastVisitedDescription(relativeTo now: Date, calendar: Calendar = .current) -> LocalizedStringResource {
        let days = calendar.daysBetween(self, and: now)

        switch days {
        case 0:
            return "Today"
        case 1:
            return "Yesterday"
        case ..<Self.daysPerWeek:
            return "\(days) days ago"
        case ..<Self.daysPerMonth:
            let weeks = days / Self.daysPerWeek
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        case ..<Self.daysPerYear:
            let months = days / Self.daysPerMonth
            return months == 1 ? "1 month ago" : "\(months) months ago"
        default:
            let years = days / Self.daysPerYear
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }
    }
}
