import SwiftData
import SwiftUI

struct DinersView: View {
    @StateObject private var viewModel: DinersViewModel
    @Query(sort: \Diner.createdAt) private var diners: [Diner]

    init(store: any DinerStoreProtocol) {
        _viewModel = StateObject(wrappedValue: DinersViewModel(store: store))
    }

    var body: some View {
        List {
            Section {
                ForEach(diners) { diner in
                    Button { viewModel.beginEditing(diner) } label: {
                        DinerRow(diner: diner)
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        if !diner.isOwner {
                            Button("Delete", systemImage: "trash", role: .destructive) { viewModel.requestDelete(diner) }
                        }
                    }
                }
            } footer: {
                Text("Diners are people you eat with. Tag dishes as a problem for someone to get a Heads-up next time.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(.journalPaper)
        .navigationTitle("Diners")
        .toolbar {
            Button("Add Diner", systemImage: "plus", action: viewModel.beginAdding)
        }
        .sheet(item: $viewModel.editor) { _ in
            DinerEditorSheet(viewModel: viewModel)
        }
        .alert("Delete this diner?", isPresented: deletionBinding) {
            Button("Delete", role: .destructive, action: viewModel.confirmDelete)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Their dishes stay in your journal but are no longer attributed to anyone, and their Heads-up flags are removed.")
        }
        .alert("Something went wrong", isPresented: errorBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var deletionBinding: Binding<Bool> {
        Binding(get: { viewModel.dinerPendingDeletion != nil }, set: { if !$0, viewModel.dinerPendingDeletion != nil { viewModel.dinerPendingDeletion = nil } })
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0, viewModel.errorMessage != nil { viewModel.errorMessage = nil } })
    }
}

private struct DinerRow: View {
    let diner: Diner

    var body: some View {
        HStack(spacing: Spacing.s) {
            Text(String(diner.name.prefix(1)))
                .font(.system(.headline, design: .serif))
                .foregroundStyle(diner.isOwner ? .journalInk : .journalCobalt)
                .frame(width: Sizing.avatar, height: Sizing.avatar)
                .background(diner.isOwner ? .journalGold : .journalCobaltSoft, in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(diner.name)
                    .font(.body.weight(.semibold))
                if diner.isOwner {
                    Text("Phone owner · Can’t be deleted")
                        .font(.caption)
                        .foregroundStyle(.journalMuted)
                } else if !diner.dietaryProfile.isEmpty {
                    Text(diner.dietaryProfile)
                        .font(.caption)
                        .foregroundStyle(.journalMuted)
                }
            }
        }
        .frame(minHeight: Sizing.minimumTapTarget)
        .contentShape(.rect)
    }
}

/// The "New Diner" / "Edit Diner" mini sheet.
private struct DinerEditorSheet: View {
    @ObservedObject var viewModel: DinersViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: binding(\.name))
                TextField("Dietary profile (optional)", text: binding(\.dietaryProfile), axis: .vertical)
                Text("Profiles only suggest who a tag may affect. Nothing is flagged automatically.")
                    .font(.footnote)
                    .foregroundStyle(.journalMuted)
            }
            .navigationTitle(viewModel.editor?.isNew == false ? "Edit Diner" : "New Diner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: viewModel.saveEditor)
                        .disabled(!viewModel.canSaveEditor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func binding(_ keyPath: WritableKeyPath<DinerEditor, String>) -> Binding<String> {
        Binding(
            get: { viewModel.editor?[keyPath: keyPath] ?? "" },
            set: { viewModel.editor?[keyPath: keyPath] = $0 }
        )
    }
}

#Preview("Diners") {
    let container = PreviewData.makeContainer()
    NavigationStack {
        DinersView(store: JournalStore(modelContext: container.mainContext))
    }
    .modelContainer(container)
}

#Preview("Only owner, accessibility size") {
    let container = PreviewData.makeContainer(seeded: false)
    NavigationStack {
        DinersView(store: JournalStore(modelContext: container.mainContext))
    }
    .modelContainer(container)
    .environment(\.dynamicTypeSize, .accessibility3)
}
