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
    let instances: [DishSnapshot]
    let onSelect: (DishSnapshot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeading(title: "At this restaurant", detail: "Tap to edit")
            ForEach(instances) { instance in
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
