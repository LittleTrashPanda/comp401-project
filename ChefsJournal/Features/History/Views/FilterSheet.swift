import SwiftData
import SwiftUI

/// Edits a copy of the History filter; Apply commits it, Cancel discards it.
struct FilterSheet: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Query(sort: \Diner.createdAt) private var diners: [Diner]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                scoreSection
                lastVisitedSection
                attributesSection
                Section {
                    Picker("Sort by", selection: $viewModel.filterDraft.sort) {
                        ForEach(HistoryFilter.Sort.allCases, id: \.self) { Text(HistoryViewModel.title(for: $0)).tag($0) }
                    }
                }
                Section {
                    Button("Reset all filters", role: .destructive, action: viewModel.resetFilterDraft)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply", action: viewModel.applyFilterDraft)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var scoreSection: some View {
        Section {
            ScoreSliderView(title: "Minimum average", score: minimumAverage)
            Picker("Score", selection: $viewModel.filterDraft.scoreType) {
                ForEach(HistoryFilter.ScoreType.allCases, id: \.self) { Text(HistoryViewModel.title(for: $0)).tag($0) }
            }
            .pickerStyle(.segmented)
        } footer: {
            Text("“—” means any average. Restaurant taste and value use the averages of their dishes.")
        }
    }

    private var lastVisitedSection: some View {
        Section("Last visited") {
            CheckRow(title: "Any time", isChecked: viewModel.filterDraft.lastVisitedOlderThan == nil) {
                viewModel.filterDraft.lastVisitedOlderThan = nil
            }
            ForEach(HistoryFilter.LastVisited.allCases, id: \.self) { option in
                CheckRow(title: HistoryViewModel.title(for: option), isChecked: viewModel.filterDraft.lastVisitedOlderThan == option) {
                    viewModel.filterDraft.lastVisitedOlderThan = option
                }
            }
        }
    }

    private var attributesSection: some View {
        Section {
            Picker("Visit type", selection: $viewModel.filterDraft.visitType) {
                Text("Any").tag(VisitType?.none)
                ForEach(VisitType.allCases, id: \.self) { Text($0.title).tag(Optional($0)) }
            }
            .pickerStyle(.navigationLink)
            Picker("Dietary tag", selection: $viewModel.filterDraft.tag) {
                Text("Any").tag(String?.none)
                ForEach(viewModel.availableTags, id: \.self) { Text(DietaryTag.title(for: $0)).tag(Optional($0)) }
            }
            .pickerStyle(.navigationLink)
            Picker("Diner", selection: $viewModel.filterDraft.dinerID) {
                Text("Any").tag(UUID?.none)
                ForEach(diners) { Text($0.name).tag(Optional($0.id)) }
            }
            .pickerStyle(.navigationLink)
            Toggle("Would order again only", isOn: $viewModel.filterDraft.wouldOrderAgainOnly)
        }
    }

    private var minimumAverage: Binding<Int> {
        Binding(
            get: { viewModel.filterDraft.minimumAverage ?? ScoreRange.unset },
            set: { viewModel.filterDraft.minimumAverage = $0 == ScoreRange.unset ? nil : $0 }
        )
    }
}

private struct CheckRow: View {
    let title: LocalizedStringResource
    let isChecked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.journalInk)
                Spacer()
                if isChecked {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.journalCobalt)
                }
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isChecked ? .isSelected : [])
    }
}

#Preview {
    let container = PreviewData.makeContainer()
    FilterSheet(viewModel: HistoryViewModel())
        .modelContainer(container)
}
