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
    let isEditing: Bool
    private let allSuggestions: [String]
    private let photoProcessor: PhotoProcessor

    init(draft: DishDraft, isEditing: Bool, suggestions: [String], photoProcessor: PhotoProcessor = PhotoProcessor()) {
        self.draft = draft
        self.isEditing = isEditing
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
}
