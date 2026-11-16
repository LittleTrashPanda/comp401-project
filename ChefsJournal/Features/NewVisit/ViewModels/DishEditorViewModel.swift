import Combine
import Foundation
import os

/// State for the Add/Edit Dish sheet.
@MainActor
final class DishEditorViewModel: ObservableObject {
    private static let suggestionLimit = 6

    @Published var draft: DishDraft
    @Published private(set) var isProcessingPhoto = false
    @Published var photoErrorMessage: String?
    @Published var isShowingCamera = false
    @Published var isAddingCustomTag = false
    @Published var customTagText = ""
    let isEditing: Bool
    let diners: [DinerOption]
    private let allSuggestions: [String]
    private let photoProcessor: PhotoProcessor

    init(draft: DishDraft, isEditing: Bool, suggestions: [String], diners: [DinerOption] = [],
         photoProcessor: PhotoProcessor = PhotoProcessor()) {
        var initialDraft = draft
        if !isEditing, initialDraft.orderedByDinerID == nil {
            initialDraft.orderedByDinerID = diners.first(where: \.isOwner)?.id
        }
        self.draft = initialDraft
        self.isEditing = isEditing
        self.diners = diners
        self.allSuggestions = suggestions
        self.photoProcessor = photoProcessor
    }

    var canFinish: Bool { draft.isComplete }

    /// Earlier dish names from this restaurant that match what's typed, excluding an exact match.
    var visibleSuggestions: [String] {
        let typed = draft.name.trimmed
        let key = typed.matchingKey
        let matches = typed.isEmpty ? allSuggestions : allSuggestions.filter {
            $0.localizedStandardContains(typed) && $0.matchingKey != key
        }
        return Array(matches.prefix(Self.suggestionLimit))
    }

    func applySuggestion(_ name: String) {
        draft.name = name
    }

    // MARK: Photo

    func attachPhoto(from data: Data) async {
        isProcessingPhoto = true
        defer { isProcessingPhoto = false }
        do {
            draft.photoData = try await photoProcessor.downsampledJPEG(from: data)
        } catch {
            Logger.photos.error("Attaching a photo failed: \(error.localizedDescription, privacy: .public)")
            photoErrorMessage = error.localizedDescription
        }
    }

    func removePhoto() {
        draft.photoData = nil
    }

    func takePhoto() async {
        guard await CameraPicker.requestAccess() else {
            photoErrorMessage = PhotoError.cameraAccessDenied.localizedDescription
            return
        }
        isShowingCamera = true
    }

    var isCameraAvailable: Bool { CameraPicker.isCameraAvailable }

    // MARK: Dietary tags

    /// Preset tags plus any custom tags already on this dish.
    var availableTags: [String] {
        let presets = DietaryTag.allCases.map(\.rawValue)
        let custom = draft.flags.map(\.tag).filter { !presets.contains($0) }
        return presets + custom
    }

    var selectedTags: [String] { draft.flags.map(\.tag) }

    func isTagSelected(_ tag: String) -> Bool {
        draft.flags.contains { $0.tag == tag }
    }

    func toggleTag(_ tag: String) {
        if let index = draft.flags.firstIndex(where: { $0.tag == tag }) {
            draft.flags.remove(at: index)
        } else {
            draft.flags.append(DietaryFlagDraft(tag: tag))
        }
    }

    func addCustomTag(_ text: String) {
        let tag = text.trimmed
        customTagText = ""
        guard !tag.isEmpty, !draft.flags.contains(where: { $0.tag.matchingKey == tag.matchingKey }) else { return }
        draft.flags.append(DietaryFlagDraft(tag: tag))
    }

    func isProblem(_ tag: String, for dinerID: UUID) -> Bool {
        draft.flags.first { $0.tag == tag }?.problemForDinerIDs.contains(dinerID) ?? false
    }

    func toggleProblem(_ tag: String, dinerID: UUID) {
        guard let index = draft.flags.firstIndex(where: { $0.tag == tag }) else { return }
        if draft.flags[index].problemForDinerIDs.contains(dinerID) {
            draft.flags[index].problemForDinerIDs.remove(dinerID)
        } else {
            draft.flags[index].problemForDinerIDs.insert(dinerID)
        }
    }

    func problemForNames(_ tag: String) -> [String] {
        diners.filter { isProblem(tag, for: $0.id) }.map(\.name)
    }

    /// True when some tag isn't a problem for anyone, so it won't create a Heads-up.
    var showsNoHeadsUpNote: Bool {
        draft.flags.contains { $0.problemForDinerIDs.isEmpty }
    }

    /// Diners whose dietary profile mentions this tag but who aren't marked yet. Only a suggestion.
    func suggestedDiners(for tag: String) -> [DinerOption] {
        let keywords = DietaryTag(rawValue: tag)?.profileKeywords ?? [tag.matchingKey]
        return diners.filter { diner in
            let profile = diner.dietaryProfile.matchingKey
            return !isProblem(tag, for: diner.id) && keywords.contains { !$0.isEmpty && profile.contains($0) }
        }
    }
}
