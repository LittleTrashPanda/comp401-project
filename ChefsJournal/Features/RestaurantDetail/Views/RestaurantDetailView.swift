import SwiftData
import SwiftUI

struct RestaurantDetailView: View {
    @StateObject private var viewModel: RestaurantDetailViewModel
    @Query private var visits: [Visit]
    @Environment(\.dismiss) private var dismiss
    @State private var visitForActions: Visit?

    init(store: any JournalStoreProtocol, restaurantID: UUID) {
        _viewModel = StateObject(wrappedValue: RestaurantDetailViewModel(store: store))
        _visits = Query(filter: #Predicate<Visit> { $0.restaurant?.id == restaurantID }, sort: \Visit.date, order: .reverse)
    }

    var body: some View {
        let display = viewModel.display(for: visits)
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.section) {
                RestaurantHeaderView(display: display)
                HeadsUpBannerView(lines: display.headsUpLines)
                ExperienceHistorySection(display: display)
                RestaurantDishesSection(restaurantID: restaurantID, dishes: display.dishes,
                                        chips: display.filterChips, selection: $viewModel.dishFilter)
                RestaurantVisitsSection(rows: display.visits) { row in
                    visitForActions = visits.first { $0.id == row.id }
                }
            }
            .padding(.horizontal, Spacing.gutter)
            .padding(.bottom, Spacing.section)
        }
        .background(.journalPaper)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let latest = visits.first {
                Button("Edit") { viewModel.beginEditing(latest) }
            }
        }
        .modifier(RestaurantDetailDialogs(viewModel: viewModel, visitForActions: $visitForActions, visitCount: visits.count))
        .sheet(item: $viewModel.editContext) { context in
            NewVisitSheet(store: viewModel.store, mode: .edit(context.visit, draft: context.draft))
        }
        .onChange(of: viewModel.didRemoveRestaurant) { _, removed in if removed { dismiss() } }
        .onChange(of: visits.isEmpty) { _, isEmpty in if isEmpty { dismiss() } }
    }

    private var restaurantID: UUID? { visits.first?.restaurant?.id }
}

/// The visit action sheet and delete confirmation, using the Figma copy.
private struct RestaurantDetailDialogs: ViewModifier {
    @ObservedObject var viewModel: RestaurantDetailViewModel
    @Binding var visitForActions: Visit?
    let visitCount: Int

    func body(content: Content) -> some View {
        content
            .confirmationDialog("Edit or delete this visit", isPresented: actionsBinding, titleVisibility: .visible,
                                presenting: visitForActions) { visit in
                Button("Edit Visit") { viewModel.beginEditing(visit) }
                Button("Delete Visit", role: .destructive) { viewModel.requestDelete(visit) }
            }
            .alert("Delete this visit?", isPresented: deletionBinding) {
                Button("Delete", role: .destructive) { viewModel.confirmDelete(remainingVisitCount: visitCount) }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(visitCount <= 1
                     ? "This is the only visit here, so the restaurant will be removed from your journal too."
                     : "This removes the visit and every dish logged in it.")
            }
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
    }

    private var actionsBinding: Binding<Bool> {
        Binding(get: { visitForActions != nil }, set: { if !$0, visitForActions != nil { visitForActions = nil } })
    }

    private var deletionBinding: Binding<Bool> {
        Binding(get: { viewModel.visitPendingDeletion != nil }, set: { if !$0, viewModel.visitPendingDeletion != nil { viewModel.visitPendingDeletion = nil } })
    }

    private var errorBinding: Binding<Bool> {
        Binding(get: { viewModel.errorMessage != nil }, set: { if !$0, viewModel.errorMessage != nil { viewModel.errorMessage = nil } })
    }
}

#Preview("Six visits") {
    let container = PreviewData.makeContainer()
    let bella = PreviewData.restaurantID(named: "Bella Italia", in: container)
    NavigationStack {
        RestaurantDetailView(store: JournalStore(modelContext: container.mainContext), restaurantID: bella)
    }
    .modelContainer(container)
}

#Preview("One visit") {
    let container = PreviewData.makeContainer()
    let sakura = PreviewData.restaurantID(named: "Sakura Sushi", in: container)
    NavigationStack {
        RestaurantDetailView(store: JournalStore(modelContext: container.mainContext), restaurantID: sakura)
    }
    .modelContainer(container)
}

#Preview("Long note, accessibility size") {
    let container = PreviewData.makeContainer()
    let sakura = PreviewData.restaurantID(named: "Sakura Sushi", in: container)
    NavigationStack {
        RestaurantDetailView(store: JournalStore(modelContext: container.mainContext), restaurantID: sakura)
    }
    .modelContainer(container)
    .environment(\.dynamicTypeSize, .accessibility3)
}
