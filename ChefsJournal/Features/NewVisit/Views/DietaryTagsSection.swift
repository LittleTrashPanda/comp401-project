import SwiftUI

/// Preset and custom tag chips, plus a "Problem for" picker and profile suggestions for each selected tag.
struct DietaryTagsSection: View {
    @ObservedObject var viewModel: DishEditorViewModel

    var body: some View {
        Section {
            FlowLayout().callAsFunction {
                ForEach(viewModel.availableTags, id: \.self) { tag in
                    ChipView(DietaryTag.title(for: tag),
                             kind: .selectable(isSelected: viewModel.isTagSelected(tag)) { viewModel.toggleTag(tag) })
                }
                ChipView(String(localized: "+ Custom"), kind: .selectable(isSelected: false) { viewModel.isAddingCustomTag = true })
            }
            ForEach(viewModel.selectedTags, id: \.self) { tag in
                ProblemForRow(viewModel: viewModel, tag: tag)
            }
            if viewModel.showsNoHeadsUpNote {
                Text("Tagged, but not marked as a problem for a diner. No Heads-up will be created.")
                    .font(.footnote)
                    .foregroundStyle(.journalMuted)
            }
        } header: {
            Text("Dietary tags")
        }
        .alert("Custom tag", isPresented: $viewModel.isAddingCustomTag) {
            TextField("Tag name", text: $viewModel.customTagText)
            Button("Add") { viewModel.addCustomTag(viewModel.customTagText) }
            Button("Cancel", role: .cancel) { viewModel.customTagText = "" }
        }
    }
}

private struct ProblemForRow: View {
    @ObservedObject var viewModel: DishEditorViewModel
    let tag: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Menu {
                ForEach(viewModel.diners) { diner in
                    Toggle(diner.name, isOn: Binding(
                        get: { viewModel.isProblem(tag, for: diner.id) },
                        set: { _ in viewModel.toggleProblem(tag, dinerID: diner.id) }
                    ))
                }
            } label: {
                HStack {
                    Text(DietaryTag.title(for: tag))
                        .foregroundStyle(.journalInk)
                    Spacer()
                    Text(problemSummary)
                        .foregroundStyle(viewModel.problemForNames(tag).isEmpty ? .journalMuted : .journalTomato)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.journalMuted)
                        .accessibilityHidden(true)
                }
                .frame(minHeight: Sizing.minimumTapTarget)
            }
            .accessibilityLabel(Text("Problem for, \(DietaryTag.title(for: tag)): \(problemSummary)"))
            ForEach(viewModel.suggestedDiners(for: tag)) { diner in
                Button {
                    viewModel.toggleProblem(tag, dinerID: diner.id)
                } label: {
                    Label("\(diner.name)’s profile mentions this. Mark as a problem for \(diner.name)?", systemImage: "lightbulb")
                        .font(.footnote)
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private var problemSummary: String {
        let names = viewModel.problemForNames(tag)
        return names.isEmpty ? String(localized: "Problem for: nobody") : String(localized: "Problem for: \(names.formatted(.list(type: .and)))")
    }
}
