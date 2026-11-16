import Combine
import Foundation
import os

/// The add/edit diner form.
struct DinerEditor: Identifiable, Equatable {
    let id = UUID()
    let dinerID: UUID?
    var name: String
    var dietaryProfile: String

    var isNew: Bool { dinerID == nil }
}

@MainActor
final class DinersViewModel: ObservableObject {
    @Published var editor: DinerEditor?
    @Published var dinerPendingDeletion: Diner?
    @Published var errorMessage: String?

    private let store: any DinerStoreProtocol
    private var dinerBeingEdited: Diner?

    init(store: any DinerStoreProtocol) {
        self.store = store
    }

    var canSaveEditor: Bool {
        !(editor?.name.trimmed.isEmpty ?? true)
    }

    func beginAdding() {
        dinerBeingEdited = nil
        editor = DinerEditor(dinerID: nil, name: "", dietaryProfile: "")
    }

    func beginEditing(_ diner: Diner) {
        dinerBeingEdited = diner
        editor = DinerEditor(dinerID: diner.id, name: diner.name, dietaryProfile: diner.dietaryProfile)
    }

    func saveEditor() {
        guard let editor, canSaveEditor else { return }
        perform {
            if let dinerBeingEdited {
                try store.updateDiner(dinerBeingEdited, name: editor.name, dietaryProfile: editor.dietaryProfile)
            } else {
                try store.addDiner(name: editor.name, dietaryProfile: editor.dietaryProfile)
            }
        }
        self.editor = nil
        dinerBeingEdited = nil
    }

    func requestDelete(_ diner: Diner) {
        guard !diner.isOwner else { return }
        dinerPendingDeletion = diner
    }

    func confirmDelete() {
        guard let diner = dinerPendingDeletion else { return }
        dinerPendingDeletion = nil
        perform { try store.deleteDiner(diner) }
    }

    private func perform(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            Logger.persistence.error("Diner change failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = error.localizedDescription
        }
    }
}
