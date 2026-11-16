import SwiftUI

struct JournalVisitRow: View {
    let row: JournalRow
    let photoData: Data?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.s))
            : AnyLayout(HStackLayout(alignment: .center, spacing: Spacing.s))
        layout {
            PhotoThumbnailView(photoData: photoData, placeholderText: row.initials)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(row.dateLine)
                    .font(.caption)
                    .foregroundStyle(.journalMuted)
                Text(row.restaurantName)
                    .font(.journalRowName)
                    .foregroundStyle(.journalInk)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 2)
                Text(row.dishSummary)
                    .font(.footnote)
                    .foregroundStyle(.journalMuted)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ExperienceStampView(score: row.experienceScore, size: .compact)
        }
        .padding(.vertical, Spacing.s)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Rows") {
    VStack {
        JournalVisitRow(row: .init(id: UUID(), restaurantID: UUID(), restaurantName: "Sakura Sushi", initials: "SS",
                                   dateLine: "Today · Dine-in", dishSummary: "California Roll · Would order again",
                                   experienceScore: 5), photoData: nil)
        JournalVisitRow(row: .init(id: UUID(), restaurantID: UUID(), restaurantName: "Bella Italia", initials: "BI",
                                   dateLine: "Yesterday · Take-out", dishSummary: "Spaghetti Carbonara, Calzone",
                                   experienceScore: 8), photoData: nil)
    }
    .padding()
}

#Preview("Long name, accessibility size") {
    JournalVisitRow(row: .init(id: UUID(), restaurantID: UUID(),
                               restaurantName: String(repeating: "Hearthside Steakhouse ", count: 4),
                               initials: "HS", dateLine: "Today · Dine-in", dishSummary: "Ribeye · Would order again",
                               experienceScore: 10), photoData: nil)
        .padding()
        .environment(\.dynamicTypeSize, .accessibility3)
}
