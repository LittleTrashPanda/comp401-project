import SwiftUI

/// Area eyebrow, serif name and the summary strip.
struct RestaurantHeaderView: View {
    let display: RestaurantDetailDisplay

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            if !display.area.isEmpty {
                Text(display.area)
                    .font(.journalEyebrow)
                    .textCase(.uppercase)
                    .tracking(Typography.eyebrowTracking)
                    .foregroundStyle(.journalMuted)
            }
            Text(display.name)
                .font(.journalTitle)
                .foregroundStyle(.journalInk)
                .accessibilityAddTraits(.isHeader)
            SummaryStripView(columns: [
                .init(value: display.visitCountText, caption: "Visits"),
                .init(value: display.averageExperienceText, caption: "Avg. experience"),
                .init(value: display.lastVisitedText, caption: "Last visited"),
            ])
        }
        .padding(.top, Spacing.m)
    }
}

/// Latest experience stamp; the chart arrives once there are enough visits.
struct ExperienceHistorySection: View {
    let latestExperience: Int?
    let visitCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text("Experience history")
                .font(.headline)
            HStack(spacing: Spacing.m) {
                if let latestExperience {
                    ExperienceStampView(score: latestExperience)
                }
                Text("Not enough visits yet")
                    .font(.callout)
                    .foregroundStyle(.journalMuted)
            }
        }
    }
}

/// "Dishes — Best first": the latest instance of each dish.
struct RestaurantDishesSection: View {
    let restaurantID: UUID?
    let dishes: [RestaurantDishRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeading(title: "Dishes", detail: "Best first")
            ForEach(dishes) { dish in
                if let restaurantID {
                    NavigationLink(value: DishRoute(restaurantID: restaurantID, dishName: dish.name)) {
                        RestaurantDishRowView(dish: dish)
                    }
                    .buttonStyle(.plain)
                }
                Divider().overlay(.journalRule)
            }
        }
    }
}

private struct RestaurantDishRowView: View {
    let dish: RestaurantDishRow

    var body: some View {
        HStack(spacing: Spacing.s) {
            PhotoThumbnailView(photoData: dish.photoData, placeholderText: String(dish.name.prefix(1)),
                               shape: .arched, side: Sizing.dishRowPhoto)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(dish.name)
                    .font(.journalRowName)
                    .foregroundStyle(.journalInk)
                if dish.wouldOrderAgain {
                    Label("Would order again", systemImage: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.journalSuccess)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ScorePairView(taste: dish.tasteScore, value: dish.valueScore)
        }
        .padding(.vertical, Spacing.s)
        .contentShape(.rect)
    }
}

/// Every visit, newest first. Tapping a visit offers edit or delete.
struct RestaurantVisitsSection: View {
    let rows: [RestaurantVisitRow]
    let onSelect: (RestaurantVisitRow) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeading(title: "Visits", detail: "Tap to edit or delete")
            ForEach(rows) { row in
                Button { onSelect(row) } label: {
                    RestaurantVisitRowView(row: row)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("visitRow")
                Divider().overlay(.journalRule)
            }
        }
    }
}

private struct RestaurantVisitRowView: View {
    let row: RestaurantVisitRow

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            ExperienceStampView(score: row.experienceScore, size: .compact)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("\(row.date.formatted(date: .abbreviated, time: .omitted)) · \(row.visitTypeText)")
                    .font(.caption)
                    .foregroundStyle(.journalMuted)
                if !row.dishNames.isEmpty {
                    Text(row.dishNames)
                        .font(.callout)
                        .foregroundStyle(.journalInk)
                }
                if !row.note.isEmpty {
                    Text("“\(row.note)”")
                        .font(.system(.callout, design: .serif).italic())
                        .foregroundStyle(.journalMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, Spacing.s)
        .contentShape(.rect)
    }
}

/// Bold heading with a muted detail on the right, e.g. "Dishes — Best first".
struct SectionHeading: View {
    let title: LocalizedStringKey
    var detail: LocalizedStringKey?

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.journalMuted)
            }
        }
        .padding(.bottom, Spacing.xs)
    }
}
