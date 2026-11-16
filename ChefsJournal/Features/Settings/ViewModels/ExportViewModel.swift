import Combine
import Foundation
import os
import UniformTypeIdentifiers

@MainActor
final class ExportViewModel: ObservableObject {
    enum Format: String, CaseIterable {
        case csv
        case pdf

        var contentType: UTType { self == .csv ? .commaSeparatedText : .pdf }
        var fileExtension: String { rawValue }
    }

    enum State: Equatable {
        case idle
        case generating
        case ready
        case failed(String)
    }

    @Published var format = Format.csv
    @Published var includePhotos = false
    @Published private(set) var state = State.idle
    @Published var isExporting = false
    @Published private(set) var document: ExportDocument?

    private let exporter: JournalExporter

    init(exporter: JournalExporter = JournalExporter()) {
        self.exporter = exporter
    }

    /// CSV can't hold images, so photos only apply to PDF.
    var canIncludePhotos: Bool { format == .pdf }

    var defaultFilename: String {
        String(localized: "Chef's Journal \(Date.now.formatted(.iso8601.year().month().day()))")
    }

    func summary(for visits: [Visit]) -> String {
        let restaurantCount = Set(visits.compactMap { $0.restaurant?.id }).count
        let photos = canIncludePhotos && includePhotos ? String(localized: "Photos included") : String(localized: "No photos")
        return String(localized: "\(restaurantCount) restaurants · \(visits.count) visits · \(photos)")
    }

    func generate(from visits: [Visit]) {
        state = .generating
        let withPhotos = canIncludePhotos && includePhotos
        let snapshot = JournalSnapshot(
            visits: visits.map(VisitSnapshot.init),
            photos: withPhotos ? Self.photos(in: visits) : [:]
        )
        do {
            let data = format == .csv ? exporter.csv(from: snapshot) : try exporter.pdf(from: snapshot, includePhotos: withPhotos)
            document = ExportDocument(data: data, contentType: format.contentType)
            state = .ready
            isExporting = true
        } catch {
            Logger.export.error("Export failed: \(error.localizedDescription, privacy: .public)")
            state = .failed(error.localizedDescription)
        }
    }

    func exportFinished(_ result: Result<URL, Error>) {
        if case let .failure(error) = result {
            Logger.export.error("Saving the export failed: \(error.localizedDescription, privacy: .public)")
            state = .failed(error.localizedDescription)
        }
    }

    private static func photos(in visits: [Visit]) -> [UUID: Data] {
        Dictionary(visits.flatMap(\.orderedDishes).compactMap { dish in dish.photoData.map { (dish.id, $0) } },
                   uniquingKeysWith: { first, _ in first })
    }
}
