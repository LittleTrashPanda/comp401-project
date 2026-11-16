import SwiftUI
import UIKit

/// One restaurant's section of the PDF export: visits, dishes and (optionally) photos.
struct JournalPDFPage: View {
    static let pageWidth: CGFloat = 612
    private static let margin: CGFloat = 40
    private static let photoSide: CGFloat = 96

    let restaurant: RestaurantSnapshot?
    let photos: [UUID: Data]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if let restaurant {
                header(for: restaurant)
                ForEach(restaurant.visits.sorted { $0.date > $1.date }) { visit in
                    visitSection(visit)
                }
            } else {
                Text("Your journal is empty.")
                    .font(.journalTitle)
            }
        }
        .padding(Self.margin)
        .frame(width: Self.pageWidth, alignment: .leading)
        .foregroundStyle(.black)
        .background(.white)
    }

    private func header(for restaurant: RestaurantSnapshot) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            Text(restaurant.name)
                .font(.journalTitle)
            if !restaurant.area.isEmpty {
                Text(restaurant.area)
                    .font(.callout)
            }
            Text("\(restaurant.visits.count) visits")
                .font(.footnote)
        }
    }

    private func visitSection(_ visit: VisitSnapshot) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Divider()
            Text("\(visit.date.formatted(date: .long, time: .omitted)) · \(String(localized: visit.visitType.title)) · Experience \(visit.experienceScore)/10")
                .font(.headline)
            if !visit.note.isEmpty {
                Text(visit.note)
                    .font(.callout.italic())
            }
            ForEach(visit.dishes) { dish in
                dishRow(dish)
            }
        }
    }

    private func dishRow(_ dish: DishSnapshot) -> some View {
        HStack(alignment: .top, spacing: Spacing.s) {
            if let data = photos[dish.id], let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: Self.photoSide, height: Self.photoSide)
                    .clipShape(.rect(cornerRadius: Radius.small))
            }
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("\(dish.name) — taste \(dish.tasteScore), value \(dish.valueScore)")
                    .font(.body.weight(.semibold))
                if dish.wouldOrderAgain {
                    Text("Would order again")
                        .font(.footnote)
                }
                if !dish.note.isEmpty {
                    Text(dish.note)
                        .font(.footnote)
                }
            }
        }
    }
}
