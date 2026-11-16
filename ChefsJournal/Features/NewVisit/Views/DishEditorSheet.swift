import SwiftUI

/// Add or edit a dish: name with suggestions, taste and value, would order again and a note.
struct DishEditorSheet: View {
    let onDone: (DishDraft) -> Void

    @StateObject private var viewModel: DishEditorViewModel
    @Environment(\.dismiss) private var dismiss

    init(context: DishEditorContext, suggestions: [String], onDone: @escaping (DishDraft) -> Void) {
        self.onDone = onDone
        _viewModel = StateObject(wrappedValue: DishEditorViewModel(draft: context.draft, isEditing: context.index != nil,
                                                                   suggestions: suggestions))
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                scoresSection
                Section {
                    DishPhotoControl(viewModel: viewModel)
                } header: {
                    Text("Photo")
                }
                Section {
                    Toggle("Would order again", isOn: $viewModel.draft.wouldOrderAgain)
                        .tint(.journalSuccess)
                    TextField("Note (optional)", text: $viewModel.draft.note, axis: .vertical)
                }
            }
            .scrollContentBackground(.hidden)
            .background(.journalPaper)
            .navigationTitle(viewModel.isEditing ? "Edit Dish" : "Add Dish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .alert("Photo", isPresented: photoErrorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.photoErrorMessage ?? "")
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var nameSection: some View {
        Section {
            TextField("Dish name", text: $viewModel.draft.name)
                .textInputAutocapitalization(.words)
                .accessibilityIdentifier("dishNameField")
            if !viewModel.visibleSuggestions.isEmpty {
                let flow = FlowLayout()
                flow {
                    ForEach(viewModel.visibleSuggestions, id: \.self) { name in
                        ChipView(name, kind: .selectable(isSelected: false) { viewModel.applySuggestion(name) })
                    }
                }
            }
        } header: {
            Text("Dish")
        }
    }

    private var scoresSection: some View {
        Section {
            ScoreSliderView(title: "Taste", score: $viewModel.draft.tasteScore, accessibilityIdentifier: "tasteSlider")
            ScoreSliderView(title: "Value", score: $viewModel.draft.valueScore, accessibilityIdentifier: "valueSlider")
        } header: {
            Text("Dish scores")
        } footer: {
            Text("Taste and value stay separate.")
        }
        .listRowBackground(Color.journalCobaltSoft)
    }

    private var photoErrorBinding: Binding<Bool> {
        Binding(get: { viewModel.photoErrorMessage != nil }, set: { if !$0 { viewModel.photoErrorMessage = nil } })
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
                onDone(viewModel.draft)
                dismiss()
            }
            .disabled(!viewModel.canFinish)
            .accessibilityIdentifier("dishDoneButton")
        }
    }
}

#Preview("Add dish with suggestions") {
    DishEditorSheet(context: DishEditorContext(index: nil, draft: DishDraft()),
                    suggestions: ["California Roll", "Miso Soup"], onDone: { _ in })
}

#Preview("Edit dish, accessibility size") {
    DishEditorSheet(context: DishEditorContext(index: 0, draft: DishDraft(name: "California Roll", tasteScore: 7, valueScore: 9)),
                    suggestions: [], onDone: { _ in })
        .environment(\.dynamicTypeSize, .accessibility3)
}
