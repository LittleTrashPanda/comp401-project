import SwiftData
import Testing
@testable import ChefsJournal

/// CloudKit needs optional relationships and no unique constraints.
struct SchemaCompatibilityTests {
    private let schema = Schema(ModelContainerFactory.modelTypes)

    @Test func everyRelationshipIsOptional() {
        for entity in schema.entities {
            for relationship in entity.relationships {
                #expect(relationship.isOptional, "\(entity.name).\(relationship.name) must be optional")
            }
        }
    }

    @Test func noAttributeIsUnique() {
        for entity in schema.entities {
            for attribute in entity.attributes {
                #expect(!attribute.isUnique, "\(entity.name).\(attribute.name) must not be unique")
            }
        }
    }

    @Test func containerFactoryHonoursCloudKitFlagWhenOff() throws {
        _ = try ModelContainerFactory.make(inMemory: true, cloudKit: false)
    }
}
