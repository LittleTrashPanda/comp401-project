import SwiftUI

struct PrivacyInsightsView: View {
    @StateObject private var viewModel = PrivacyInsightsViewModel()

    var body: some View {
        List {
            Section {
                Toggle("Contribute anonymous insights",
                       isOn: Binding(get: { viewModel.isOptedIn }, set: viewModel.setOptIn))
            } footer: {
                Text("Off unless you turn it on. Chef's Journal has no insights service yet, so nothing is sent today; this saves your choice.")
            }
            Section("May be contributed") {
                Label("Dish names with taste and value scores", systemImage: "fork.knife")
                Label("Restaurant names with experience scores", systemImage: "star")
            }
            Section("Never contributed") {
                Label("Your notes and photos", systemImage: "note.text")
                Label("Diners and dietary profiles", systemImage: "person.2")
                Label("Who you are, or when and where you ate", systemImage: "lock")
            }
        }
        .scrollContentBackground(.hidden)
        .background(.journalPaper)
        .navigationTitle("Privacy & Insights")
        .alert("Turn off contribution?", isPresented: $viewModel.isConfirmingTurnOff) {
            Button("Turn Off", role: .destructive, action: viewModel.confirmTurnOff)
            Button("Keep On", role: .cancel) {}
        } message: {
            Text("No further data will be shared from this iPhone.")
        }
    }
}

#Preview {
    NavigationStack { PrivacyInsightsView() }
}

#Preview("Accessibility size") {
    NavigationStack { PrivacyInsightsView() }
        .environment(\.dynamicTypeSize, .accessibility3)
}
