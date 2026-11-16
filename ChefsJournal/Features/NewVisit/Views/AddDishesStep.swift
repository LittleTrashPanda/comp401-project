import SwiftUI

/// Step 3: the dishes added so far, plus Add Dish.
struct AddDishesStep: View {
    @ObservedObject var viewModel: NewVisitViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            ForEach(Array(viewModel.draft.dishes.enumerated()), id: \.element.id) { index, dish in
                AddedDishRow(dish: dish) { viewModel.beginEditingDish(at: index) }
                Divider().overlay(.journalRule)
            }
            Button("Add Dish", systemImage: "plus", action: viewModel.beginAddingDish)
                .buttonStyle(OutlineButtonStyle())
                .accessibilityIdentifier("addDishButton")
            if !viewModel.draft.hasCompleteDishes {
                Text("Add at least one complete dish to save this visit.")
                    .font(.footnote)
                    .foregroundStyle(.journalMuted)
            }
        }
    }
}

private struct AddedDishRow: View {
    let dish: DishDraft
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: Spacing.s) {
            if dish.photoData != nil {
                PhotoThumbnailView(photoData: dish.photoData, placeholderText: "", shape: .arched)
            }
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(dish.name)
                    .font(.journalRowName)
                if dish.wouldOrderAgain {
                    Label("Would order again", systemImage: "checkmark")
                        .font(.caption)
                        .foregroundStyle(.journalSuccess)
                }
            }
            Spacer()
            ScorePairView(taste: dish.tasteScore, value: dish.valueScore)
            Button("Edit", action: onEdit)
                .frame(minWidth: Sizing.minimumTapTarget, minHeight: Sizing.minimumTapTarget)
                .accessibilityLabel(Text("Edit \(dish.name)"))
        }
    }
}
