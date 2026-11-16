import SwiftUI

/// Three columns of value + caption, e.g. Visits · Avg. experience · Last visited.
struct SummaryStripView: View {
    struct Column: Identifiable {
        let id = UUID()
        let value: String
        let caption: LocalizedStringResource
    }

    let columns: [Column]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(columns.enumerated()), id: \.element.id) { index, column in
                if index > 0 {
                    Rectangle()
                        .fill(.journalRule)
                        .frame(width: Sizing.hairline)
                }
                VStack(spacing: Spacing.xxs) {
                    Text(column.value)
                        .font(.journalScore)
                        .foregroundStyle(.journalInk)
                    Text(column.caption)
                        .font(.caption)
                        .foregroundStyle(.journalMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.s)
                .accessibilityElement(children: .combine)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .overlay(alignment: .top) { Rectangle().fill(.journalRule).frame(height: Sizing.hairline) }
        .overlay(alignment: .bottom) { Rectangle().fill(.journalRule).frame(height: Sizing.hairline) }
    }
}

#Preview("Restaurant summary") {
    SummaryStripView(columns: [
        .init(value: "6", caption: "Visits"),
        .init(value: "7.8", caption: "Avg. experience"),
        .init(value: "3 weeks ago", caption: "Last visited"),
    ])
    .padding()
}

#Preview("Accessibility size") {
    SummaryStripView(columns: [
        .init(value: "7.5", caption: "Avg. taste"),
        .init(value: "7.5", caption: "Avg. value"),
        .init(value: "Today", caption: "Last ordered"),
    ])
    .padding()
    .environment(\.dynamicTypeSize, .accessibility3)
}
