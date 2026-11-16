import SwiftUI

/// Step 1: search your own restaurants or add one by name.
struct ChooseRestaurantStep: View {
    @ObservedObject var viewModel: NewVisitViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            searchField
            if viewModel.showsAddRow {
                addRow
            }
            if !viewModel.searchResults.isEmpty {
                Text(viewModel.isSearching ? "Your restaurants" : "Recently visited")
                    .font(.headline)
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.searchResults) { option in
                        RestaurantOptionRow(option: option) { viewModel.select(option) }
                        Divider().overlay(.journalRule)
                    }
                }
            }
        }
        .task { viewModel.refreshSearchResults() }
    }

    private var searchField: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.journalMuted)
                .accessibilityHidden(true)
            TextField("Restaurant name", text: $viewModel.searchQuery)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .focused($isSearchFocused)
                .onSubmit(viewModel.addNewRestaurant)
                .accessibilityIdentifier("restaurantSearchField")
        }
        .padding(Spacing.s)
        .frame(minHeight: Sizing.minimumTapTarget)
        .background(.journalSurface, in: .rect(cornerRadius: Radius.medium))
        .overlay(RoundedRectangle(cornerRadius: Radius.medium).strokeBorder(.journalRule, lineWidth: Sizing.hairline))
        .onAppear { isSearchFocused = true }
    }

    private var addRow: some View {
        Button(action: viewModel.addNewRestaurant) {
            Label {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Add “\(viewModel.searchQuery.trimmed)”")
                        .font(.body.weight(.semibold))
                    Text("Area or address can be added next")
                        .font(.caption)
                        .foregroundStyle(.journalMuted)
                }
            } icon: {
                Image(systemName: "plus")
            }
            .frame(maxWidth: .infinity, minHeight: Sizing.minimumTapTarget, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.journalCobalt)
        .accessibilityIdentifier("addRestaurantButton")
    }
}

private struct RestaurantOptionRow: View {
    let option: RestaurantOption
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(option.name)
                        .font(.journalRowName)
                        .foregroundStyle(.journalInk)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.journalMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.journalMuted)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, Spacing.s)
            .frame(minHeight: Sizing.minimumTapTarget)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        let visits = String(localized: "\(option.visitCount) visits")
        return option.area.isEmpty ? visits : String(localized: "\(option.area) · \(visits)")
    }
}
