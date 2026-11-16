import SwiftUI

/// The three-step New Visit flow. In edit mode it starts at step 2 and updates the visit.
struct NewVisitSheet: View {
    let onSaved: () -> Void

    @StateObject private var viewModel: NewVisitViewModel
    @Environment(\.dismiss) private var dismiss

    init(store: any JournalStoreProtocol, mode: NewVisitViewModel.Mode = .create, onSaved: @escaping () -> Void = {}) {
        self.onSaved = onSaved
        _viewModel = StateObject(wrappedValue: NewVisitViewModel(store: store, mode: mode))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.section) {
                    NewVisitStepHeader(step: viewModel.currentStep, isEditing: viewModel.isEditing)
                    currentStepView
                }
                .padding(.horizontal, Spacing.gutter)
                .padding(.bottom, Spacing.section)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(.journalPaper)
            .safeAreaInset(edge: .bottom) { primaryButton }
            .toolbar { leadingToolbarItem }
            .navigationBarTitleDisplayMode(.inline)
            .alert("Discard this draft?", isPresented: $viewModel.isConfirmingDiscard) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("The restaurant, scores and dishes you entered will be lost.")
            }
            .alert("Couldn’t save", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(item: $viewModel.dishEditor) { context in
                DishEditorSheet(context: context, suggestions: viewModel.dishSuggestions, onDone: viewModel.commitDish)
            }
        }
        .interactiveDismissDisabled(viewModel.hasUnsavedContent)
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch viewModel.currentStep {
        case .restaurant:
            ChooseRestaurantStep(viewModel: viewModel)
        case .details:
            VisitDetailsStep(viewModel: viewModel)
        case .dishes:
            AddDishesStep(viewModel: viewModel)
        }
    }

    private var primaryButton: some View {
        Button(viewModel.isOnLastStep ? "Save Log" : "Continue", action: primaryAction)
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canAdvance)
            .accessibilityIdentifier("primaryActionButton")
            .padding(.horizontal, Spacing.gutter)
            .padding(.vertical, Spacing.s)
    }

    private var leadingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if viewModel.isOnFirstStep {
                Button("Cancel") {
                    if viewModel.requestCancel() { dismiss() }
                }
            } else {
                Button("Back", systemImage: "chevron.left", action: viewModel.goBack)
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } })
    }

    private func primaryAction() {
        guard viewModel.isOnLastStep else {
            viewModel.advance()
            return
        }
        do {
            try viewModel.save()
            onSaved()
            dismiss()
        } catch {
            // The ViewModel has already set errorMessage, which the alert shows.
        }
    }
}

/// "Step n of 3", the progress track and the step title.
private struct NewVisitStepHeader: View {
    let step: NewVisitViewModel.Step
    let isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(isEditing ? "Edit visit · Step \(step.rawValue) of 3" : "Step \(step.rawValue) of 3")
                .font(.journalEyebrow)
                .textCase(.uppercase)
                .tracking(Typography.eyebrowTracking)
                .foregroundStyle(.journalMuted)
            ProgressView(value: Double(step.rawValue), total: Double(NewVisitViewModel.Step.allCases.count))
                .tint(.journalCobalt)
                .accessibilityHidden(true)
            Text(title)
                .font(.journalTitle)
                .foregroundStyle(.journalInk)
                .accessibilityAddTraits(.isHeader)
        }
        .padding(.top, Spacing.s)
    }

    private var title: LocalizedStringKey {
        switch step {
        case .restaurant: "Where did you eat?"
        case .details: "How was the visit?"
        case .dishes: "What did you order?"
        }
    }
}

#Preview("New visit") {
    let container = PreviewData.makeContainer()
    NewVisitSheet(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
}

#Preview("Empty journal, accessibility size") {
    let container = PreviewData.makeContainer(seeded: false)
    NewVisitSheet(store: JournalStore(modelContext: container.mainContext))
        .modelContainer(container)
        .environment(\.dynamicTypeSize, .accessibility3)
}
