import SwiftData
import SwiftUI

struct DishDetailView: View {
    let route: DishRoute

    @StateObject private var viewModel: DishDetailViewModel
    @Query(sort: \Visit.date, order: .reverse) private var visits: [Visit]
    @Environment(\.dismiss) private var dismiss

    init(store: any JournalStoreProtocol, route: DishRoute) {
        self.route = route
        _viewModel = StateObject(wrappedValue: DishDetailViewModel(store: store))
    }

    var body: some View {
        Group {
            if let display = viewModel.display(for: visits, route: route) {
                content(display)
            } else {
                EmptyStateView(systemImage: "fork.knife", title: "Dish not found",
                               message: "This dish is no longer in your journal.")
            }
        }
        .background(.journalPaper)
        .navigationBarTitleDisplayMode(.inline)
        .modifier(DishDetailDialogs(viewModel: viewModel, instanceCount: instanceCount))
        .sheet(item: $viewModel.editorContext) { context in
            DishEditorSheet(context: context, suggestions: [], diners: viewModel.diners, onDone: viewModel.saveEdit)
        }
        .task { viewModel.loadDiners() }
        .onChange(of: viewModel.shouldDismiss) { _, shouldDismiss in if shouldDismiss { dismiss() } }
    }

    private var instanceCount: Int {
        viewModel.display(for: visits, route: route)?.instances.count ?? 0
    }

    private func content(_ display: DishDetailDisplay) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.section) {
                DishHeroView(photoData: latestEntry(display)?.photoData, display: display)
                DishInstancesSection(display: display) { instance in
                    if let entry = viewModel.entry(withID: instance.id, in: visits) { viewModel.beginEditing(entry) }
                }
                if display.comparison.count > 1 {
                    DishCompareSection(rows: display.comparison)
                }
                if let latest = latestEntry(display) {
                    Button("Delete this dish entry", systemImage: "trash", role: .destructive) {
                        viewModel.requestDelete(latest)
                    }
                    .buttonStyle(OutlineButtonStyle(tint: .journalTomato))
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.bottom, Spacing.section)
        }
        .toolbar {
            if let latest = latestEntry(display) {
                Button("Edit") { viewModel.beginEditing(latest) }
            }
        }
    }

    private func latestEntry(_ display: DishDetailDisplay) -> DishEntry? {
        viewModel.entry(withID: display.latest.id, in: visits)
    }
}

private struct DishDetailDialogs: ViewModifier {
    @ObservedObject var viewModel: DishDetailViewModel
    let instanceCount: Int

    func body(content: Content) -> some View {
        content
            .alert("Delete this dish entry?", isPresented: deletionBinding) {
                Button("Delete Dish", role: .destructive) { viewModel.confirmDeleteDish(instanceCount: instanceCount) }
                if viewModel.pendingDishIsLastInVisit {
                    Button("Delete Visit", role: .destructive, action: viewModel.confirmDeleteVisit)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(viewModel.pendingDishIsLastInVisit
                     ? "This is the only dish in its visit. You can delete just the dish, or the whole visit."
                     : "This removes it from that visit. Other visits are not affected.")
            }
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
    }

    private var deletionBinding: Binding<Bool> {
        Binding(get: { viewModel.dishPendingDeletion != nil }, set: { if !$0, viewModel.dishPendingDeletion != nil { viewModel.dishPendingDeletion = nil } })
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0, viewModel.errorMessage != nil { viewModel.errorMessage = nil } })
    }
}

#Preview("Two instances") {
    let container = PreviewData.makeContainer()
    let bella = PreviewData.restaurantID(named: "Bella Italia", in: container)
    NavigationStack {
        DishDetailView(store: JournalStore(modelContext: container.mainContext),
                       route: DishRoute(restaurantID: bella, dishName: "Tiramisu"))
    }
    .modelContainer(container)
}

#Preview("Accessibility size") {
    let container = PreviewData.makeContainer()
    let sakura = PreviewData.restaurantID(named: "Sakura Sushi", in: container)
    NavigationStack {
        DishDetailView(store: JournalStore(modelContext: container.mainContext),
                       route: DishRoute(restaurantID: sakura, dishName: "California Roll"))
    }
    .modelContainer(container)
    .environment(\.dynamicTypeSize, .accessibility3)
}
