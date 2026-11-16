import Foundation
import Testing
@testable import ChefsJournal

struct HeadsUpCalculatorTests {
    private let eliza = DinerReference(id: UUID(), name: "Eliza")
    private let liam = DinerReference(id: UUID(), name: "Liam")
    private let gluten = DietaryTag.containsGluten.rawValue

    @Test func tagWithoutProblemForProducesNoItem() {
        let roll = DishSnapshot(name: "California Roll", flags: [FlagSnapshot(tag: DietaryTag.containsShellfish.rawValue, problemFor: [])])
        #expect(HeadsUpCalculator.items(for: [roll]).isEmpty)
    }

    @Test func calzoneGlutenForElizaProducesOneItem() {
        let calzone = DishSnapshot(name: "Calzone", flags: [FlagSnapshot(tag: gluten, problemFor: [eliza])])
        let items = HeadsUpCalculator.items(for: [calzone])
        #expect(items == [HeadsUpItem(dishName: "Calzone", tag: gluten, dinerNames: ["Eliza"])])
        #expect(items.first?.line(locale: Locale(identifier: "en_US")) == "Calzone — contains gluten (Eliza)")
    }

    @Test func sameFlagOnTwoVisitsIsDeduplicated() {
        let first = DishSnapshot(name: "Calzone", flags: [FlagSnapshot(tag: gluten, problemFor: [eliza])])
        let second = DishSnapshot(name: "calzone ", flags: [FlagSnapshot(tag: gluten, problemFor: [eliza])])
        #expect(HeadsUpCalculator.items(for: [first, second]).count == 1)
    }

    @Test func twoDinersMergeIntoOneItem() {
        let first = DishSnapshot(name: "Tiramisu", flags: [FlagSnapshot(tag: DietaryTag.containsDairy.rawValue, problemFor: [liam])])
        let second = DishSnapshot(name: "Tiramisu", flags: [FlagSnapshot(tag: DietaryTag.containsDairy.rawValue, problemFor: [eliza])])
        let items = HeadsUpCalculator.items(for: [first, second])
        #expect(items.count == 1)
        #expect(items.first?.dinerNames == ["Eliza", "Liam"])
    }

    @Test func itemsAreSortedByDishName() {
        let dishes = [
            DishSnapshot(name: "Tiramisu", flags: [FlagSnapshot(tag: DietaryTag.containsDairy.rawValue, problemFor: [liam])]),
            DishSnapshot(name: "Calzone", flags: [FlagSnapshot(tag: gluten, problemFor: [eliza])]),
        ]
        #expect(HeadsUpCalculator.items(for: dishes).map(\.dishName) == ["Calzone", "Tiramisu"])
    }
}
