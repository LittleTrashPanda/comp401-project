import SwiftUI

/// Icon, serif title and helper text, with an optional call to action.
struct EmptyStateView<Actions: View>: View {
    let systemImage: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey
    @ViewBuilder var actions: () -> Actions

    var body: some View {
        VStack(spacing: Spacing.s) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(.journalMuted)
                .accessibilityHidden(true)
            Text(title)
                .font(.journalCardTitle)
                .foregroundStyle(.journalInk)
            Text(message)
                .font(.callout)
                .foregroundStyle(.journalMuted)
                .multilineTextAlignment(.center)
            actions()
                .padding(.top, Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.section)
    }
}

extension EmptyStateView where Actions == EmptyView {
    init(systemImage: String, title: LocalizedStringKey, message: LocalizedStringKey) {
        self.init(systemImage: systemImage, title: title, message: message) { EmptyView() }
    }
}

#Preview("No matches") {
    EmptyStateView(systemImage: "magnifyingglass", title: "No matches", message: "Try a different search or fewer filters.")
}

#Preview("With action, accessibility size") {
    EmptyStateView(systemImage: "book.closed", title: "No visits yet", message: "Log your first meal to start your journal.") {
        Button("New Log") {}
            .buttonStyle(PrimaryButtonStyle())
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}
