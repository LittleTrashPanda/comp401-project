import Foundation
import SwiftData

enum ModelContainerFactory {
    static let modelTypes: [any PersistentModel.Type] = [Restaurant.self, Visit.self, DishEntry.self]

    static func make(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(modelTypes)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
