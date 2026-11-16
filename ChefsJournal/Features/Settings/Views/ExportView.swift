import SwiftData
import SwiftUI

struct ExportView: View {
    @StateObject private var viewModel = ExportViewModel()
    @Query(sort: \Visit.date) private var visits: [Visit]

    var body: some View {
        List {
            Section {
                Picker("Format", selection: $viewModel.format) {
                    Text("CSV").tag(ExportViewModel.Format.csv)
                    Text("PDF").tag(ExportViewModel.Format.pdf)
                }
                .pickerStyle(.segmented)
                Toggle("Include photos", isOn: $viewModel.includePhotos)
                    .disabled(!viewModel.canIncludePhotos)
            } footer: {
                Text(viewModel.canIncludePhotos
                     ? "PDF has one section per restaurant."
                     : "CSV is a spreadsheet with one row per dish. It can’t hold photos; choose PDF to include them.")
            }
            Section {
                Text(viewModel.summary(for: visits))
                    .font(.callout)
                Button(action: { viewModel.generate(from: visits) }) {
                    Label("Export", systemImage: "square.and.arrow.down")
                }
                .disabled(viewModel.state == .generating)
                stateRow
            }
        }
        .scrollContentBackground(.hidden)
        .background(.journalPaper)
        .navigationTitle("Export")
        .fileExporter(isPresented: $viewModel.isExporting, document: viewModel.document,
                      contentType: viewModel.format.contentType, defaultFilename: viewModel.defaultFilename,
                      onCompletion: viewModel.exportFinished)
    }

    @ViewBuilder
    private var stateRow: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .generating:
            Label { Text("Generating…") } icon: { ProgressView() }
        case .ready:
            Label("Export ready", systemImage: "checkmark")
                .foregroundStyle(.journalSuccess)
        case let .failed(message):
            Label(message, systemImage: "exclamationmark.triangle")
                .foregroundStyle(.journalTomato)
        }
    }
}

#Preview {
    let container = PreviewData.makeContainer()
    NavigationStack { ExportView() }
        .modelContainer(container)
}

#Preview("Empty journal") {
    let container = PreviewData.makeContainer(seeded: false)
    NavigationStack { ExportView() }
        .modelContainer(container)
}
