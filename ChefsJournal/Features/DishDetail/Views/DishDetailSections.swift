import SwiftUI

/// Hero photo, restaurant eyebrow, name, large score pair and summary strip.
struct DishHeroView: View {
    let photoData: Data?
    let display: DishDetailDisplay

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            if photoData != nil {
                DishHeroPhoto(photoData: photoData)
            }
            Text(display.restaurantName)
                .font(.journalEyebrow)
                .textCase(.uppercase)
                .tracking(Typography.eyebrowTracking)
                .foregroundStyle(.journalMuted)
            Text(display.name)
                .font(.journalTitle)
                .foregroundStyle(.journalInk)
                .accessibilityAddTraits(.isHeader)
            ScorePairView(taste: display.latest.tasteScore, value: display.latest.valueScore, size: .large)
            if display.latest.wouldOrderAgain {
                Label("Would order again", systemImage: "checkmark")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.journalSuccess)
            }
            if !display.latest.note.isEmpty {
                Text("“\(display.latest.note)”")
                    .font(.system(.body, design: .serif).italic())
                    .foregroundStyle(.journalMuted)
            }
            SummaryStripView(columns: [
                .init(value: display.averageTasteText, caption: "Avg. taste"),
                .init(value: display.averageValueText, caption: "Avg. value"),
                .init(value: display.lastOrderedText, caption: "Last ordered"),
            ])
        }
        .padding(.top, Spacing.m)
    }
}

/// Full-width photo sized relative to the container, without GeometryReader.
struct DishHeroPhoto: View {
    let photoData: Data?

    var body: some View {
        Color.clear
            .aspectRatio(Sizing.heroAspectRatio, contentMode: .fit)
            .overlay {
                PhotoThumbnailView(photoData: photoData, placeholderText: "", shape: .hero, side: Sizing.heroPhotoSide)
            }
            .clipped()
            .containerRelativeFrame(.horizontal) { width, _ in width - Spacing.gutter * 2 }
    }
}

/// Every instance of the dish at this restaurant, newest first. Tap to edit.
struct DishInstancesSection: View {
    let display: DishDetailDisplay
    let onSelect: (DishSnapshot) -> Void

    private static let minimumChartPoints = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeading(title: "At this restaurant", detail: "Tap to edit")
            if let trend = display.trend {
                TrendBadgeView(trend: trend)
                    .padding(.bottom, Spacing.xs)
            }
            if display.tastePoints.count >= Self.minimumChartPoints {
                ScoreChartView(series: [
                    .init(name: "Taste", points: display.tastePoints, color: .journalCobalt),
                    .init(name: "Value", points: display.valuePoints, color: .journalCobalt, isDashed: true),
                ])
                .padding(.bottom, Spacing.s)
            } else {
                Text("Not enough history yet")
                    .font(.callout)
                    .foregroundStyle(.journalMuted)
                    .padding(.bottom, Spacing.xs)
            }
            ForEach(display.instances) { instance in
                Button { onSelect(instance) } label: {
                    HStack(alignment: .top, spacing: Spacing.s) {
                        VStack(alignment: .leading, spacing: Spacing.xxs) {
                            Text(instance.date, format: .dateTime.day().month(.abbreviated).year())
                                .font(.callout.weight(.semibold))
                            if !instance.note.isEmpty {
                                Text(instance.note)
                                    .font(.footnote)
                                    .foregroundStyle(.journalMuted)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        ScorePairView(taste: instance.tasteScore, value: instance.valueScore)
                    }
                    .padding(.vertical, Spacing.s)
                    .contentShape(.rect)
                }
                .buttonStyle(.plain)
                Divider().overlay(.journalRule)
            }
        }
    }
}

/// The same dish at each restaurant; the current restaurant's row is highlighted.
struct DishCompareSection: View {
    let rows: [ComparisonRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeading(title: "Compare")
            HStack {
                Text("Restaurant")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Taste")
                Text("Value")
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.journalMuted)
            .padding(.horizontal, Spacing.s)
            .padding(.bottom, Spacing.xxs)
            ForEach(rows) { row in
                CompareRowView(row: row)
            }
        }
    }
}

private struct CompareRowView: View {
    let row: ComparisonRow

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(row.restaurantName)
                    .font(.body.weight(row.isCurrent ? .semibold : .regular))
                Text(row.date, format: .dateTime.day().month(.abbreviated).year())
                    .font(.caption)
                    .foregroundStyle(.journalMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(row.tasteScore, format: .number)
                .font(.journalScore)
            Text(row.valueScore, format: .number)
                .font(.journalScore)
        }
        .foregroundStyle(.journalInk)
        .padding(Spacing.s)
        .background(row.isCurrent ? Color.journalCobaltSoft : .clear, in: .rect(cornerRadius: Radius.small))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(row.isCurrent
            ? "\(row.restaurantName), this restaurant: taste \(row.tasteScore), value \(row.valueScore)"
            : "\(row.restaurantName): taste \(row.tasteScore), value \(row.valueScore)"))
    }
}
