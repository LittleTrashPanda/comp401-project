import SwiftUI

// MARK: - Colours (asset-catalog colour sets with Any/Dark appearances)

extension ShapeStyle where Self == Color {
    /// Screen background ("Porcelain").
    static var journalPaper: Color { Color("JournalPaper") }
    /// Grouped settings and fields.
    static var journalSurface: Color { Color("JournalSurface") }
    /// Primary text and the Been-a-while card.
    static var journalInk: Color { Color("JournalInk") }
    /// Secondary text.
    static var journalMuted: Color { Color("JournalMuted") }
    /// Dividers and field borders.
    static var journalRule: Color { Color("JournalRule") }
    /// Actions, Taste/Value, selected state.
    static var journalCobalt: Color { Color("JournalCobalt") }
    /// Score stack and selected chip fill.
    static var journalCobaltSoft: Color { Color("JournalCobaltSoft") }
    /// Experience, caution, destructive.
    static var journalTomato: Color { Color("JournalTomato") }
    /// Heads-up background.
    static var journalTomatoSoft: Color { Color("JournalTomatoSoft") }
    /// Would order again, Improving, synced.
    static var journalSuccess: Color { Color("JournalSuccess") }
    /// Been-a-while eyebrow and ring, owner avatar.
    static var journalGold: Color { Color("JournalGold") }
}

// MARK: - Typography (Dynamic Type text styles only)

extension Font {
    static let journalLargeTitle = Font.system(.largeTitle, design: .serif)
    static let journalTitle = Font.system(.title, design: .serif)
    static let journalCardTitle = Font.system(.title2, design: .serif)
    static let journalRowName = Font.system(.body, design: .serif).weight(.semibold)
    static let journalScore = Font.system(.title3, design: .serif).monospacedDigit()
    static let journalLargeScore = Font.system(.largeTitle, design: .serif).monospacedDigit()
    static let journalEyebrow = Font.caption.weight(.semibold)
}

enum Typography {
    /// Letter spacing for uppercase eyebrow labels.
    static let eyebrowTracking: CGFloat = 1.4
    static let minimumScaleFactor: CGFloat = 0.6
}

// MARK: - Spacing, radius and sizes

enum Spacing {
    static let xxs: CGFloat = 3
    static let xs: CGFloat = 7
    static let s: CGFloat = 11
    static let m: CGFloat = 16
    static let gutter: CGFloat = 20
    static let section: CGFloat = 24
}

enum Radius {
    /// Fields and the score pair.
    static let small: CGFloat = 10
    /// Heads-up, grouped surfaces, search field.
    static let medium: CGFloat = 16
    /// Primary buttons and sheets.
    static let large: CGFloat = 24
    /// Top corners of the arched dish thumbnail.
    static let arch: CGFloat = 34
}

enum Layout {
    static let minimumTapTarget: CGFloat = 44
    static let hairline: CGFloat = 1
    static let stampStroke: CGFloat = 2
    static let experienceStampRegular: CGFloat = 82
    static let experienceStampCompact: CGFloat = 55
    static let visitRowPhoto: CGFloat = 52
    static let dishRowPhoto: CGFloat = 64
    static let newLogPressedOffset: CGFloat = 4
    static let disabledOpacity: Double = 0.4
    static let softFillOpacity: Double = 0.12
    static let pressedOpacity: Double = 0.8
    static let chartHeight: CGFloat = 180
    static let heroAspectRatio: CGFloat = 4.0 / 3.0
    static let avatar: CGFloat = 40
}

enum Timing {
    static let successToastDuration: Duration = .seconds(2.6)
}

