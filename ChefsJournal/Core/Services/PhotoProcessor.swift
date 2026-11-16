import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

enum PhotoError: LocalizedError, Equatable {
    case unreadableImage
    case encodingFailed
    case cameraAccessDenied

    var errorDescription: String? {
        switch self {
        case .unreadableImage: String(localized: "That photo couldn’t be read. Try a different one.")
        case .encodingFailed: String(localized: "That photo couldn’t be saved. Please try again.")
        case .cameraAccessDenied: String(localized: "Camera access is off. You can turn it on in Settings › Chef's Journal.")
        }
    }
}

/// Downsamples photos with ImageIO, off the main actor, so full-resolution images never sit in memory.
actor PhotoProcessor {
    static let maximumStoredPixelLength = 1600
    static let jpegQuality = 0.8

    func downsampledJPEG(from data: Data, maxPixelLength: Int = PhotoProcessor.maximumStoredPixelLength) throws -> Data {
        let image = try downsampledImage(from: data, maxPixelLength: maxPixelLength)
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw PhotoError.encodingFailed
        }
        let options = [kCGImageDestinationLossyCompressionQuality: Self.jpegQuality] as CFDictionary
        CGImageDestinationAddImage(destination, image, options)
        guard CGImageDestinationFinalize(destination) else { throw PhotoError.encodingFailed }
        return output as Data
    }

    func thumbnail(from data: Data, pointSize: CGFloat, scale: CGFloat) throws -> CGImage {
        try downsampledImage(from: data, maxPixelLength: Int((pointSize * scale).rounded(.up)))
    }

    private func downsampledImage(from data: Data, maxPixelLength: Int) throws -> CGImage {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions),
              CGImageSourceGetCount(source) > 0 else {
            throw PhotoError.unreadableImage
        }
        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelLength,
        ] as CFDictionary
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            throw PhotoError.unreadableImage
        }
        return image
    }
}
