import SwiftUI

extension View {
    /// Registers the value-based destinations shared by the Journal and History stacks.
    func journalDestinations(store: any JournalStoreProtocol) -> some View {
        navigationDestination(for: RestaurantRoute.self) { route in
            Text("Restaurant")
                .navigationTitle("Restaurant")
                .id(route.id)
        }
    }
}
