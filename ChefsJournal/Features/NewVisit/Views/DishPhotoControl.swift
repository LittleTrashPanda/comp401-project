import PhotosUI
import SwiftUI

/// Camera tile when empty; thumbnail with Change/Remove when a photo is attached.
struct DishPhotoControl: View {
    @ObservedObject var viewModel: DishEditorViewModel
    @State private var libraryItem: PhotosPickerItem?
    @State private var isShowingLibrary = false

    var body: some View {
        Menu {
            if viewModel.isCameraAvailable {
                Button("Take Photo", systemImage: "camera") { Task { await viewModel.takePhoto() } }
            }
            Button("Choose from Library", systemImage: "photo.on.rectangle") { isShowingLibrary = true }
            if viewModel.draft.photoData != nil {
                Button("Remove Photo", systemImage: "trash", role: .destructive, action: viewModel.removePhoto)
            }
        } label: {
            label
        }
        .photosPicker(isPresented: $isShowingLibrary, selection: $libraryItem, matching: .images)
        .fullScreenCover(isPresented: $viewModel.isShowingCamera) {
            CameraPicker { data in Task { await viewModel.attachPhoto(from: data) } }
                .ignoresSafeArea()
        }
        .task(id: libraryItem) { await loadLibraryItem() }
    }

    @ViewBuilder
    private var label: some View {
        HStack(spacing: Spacing.s) {
            if viewModel.draft.photoData != nil {
                PhotoThumbnailView(photoData: viewModel.draft.photoData, placeholderText: "", shape: .arched)
                Text("Change photo")
            } else {
                Image(systemName: "camera")
                    .font(.title2)
                    .frame(width: Sizing.visitRowPhoto, height: Sizing.visitRowPhoto)
                    .background(.journalCobaltSoft, in: .rect(cornerRadius: Radius.small))
                    .accessibilityHidden(true)
                Text("Camera or Photo Library")
            }
            Spacer()
            if viewModel.isProcessingPhoto {
                ProgressView()
            }
        }
        .frame(minHeight: Sizing.minimumTapTarget)
        .contentShape(.rect)
    }

    private func loadLibraryItem() async {
        guard let libraryItem else { return }
        do {
            if let data = try await libraryItem.loadTransferable(type: Data.self) {
                await viewModel.attachPhoto(from: data)
            }
        } catch {
            viewModel.photoErrorMessage = PhotoError.unreadableImage.localizedDescription
        }
        self.libraryItem = nil
    }
}
