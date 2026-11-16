import Foundation
import SwiftData

enum ModelContainerFactory {
    static let modelTypes: [any PersistentModel.Type] = [Restaurant.self, Visit.self, DishEntry.self, Diner.self, DietaryFlag.self]

    static func make(inMemory: Bool, cloudKit: Bool = false) throws -> ModelContainer {
        let schema = Schema(modelTypes)
        let database: ModelConfiguration.CloudKitDatabase = if cloudKit, let identifier = CloudSyncConfiguration.containerIdentifier {
            .private(identifier)
        } else {
            .none
        }
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: database)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
