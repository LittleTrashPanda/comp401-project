import CoreGraphics
import Foundation
import ImageIO
import Testing
import UniformTypeIdentifiers
@testable import ChefsJournal

struct PhotoProcessorTests {
    static func makeImageData(width: Int, height: Int) throws -> Data {
        let context = try #require(CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                                             space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        context.setFillColor(CGColor(red: 0.8, green: 0.3, blue: 0.2, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = try #require(context.makeImage())
        let data = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, image, nil)
        #expect(CGImageDestinationFinalize(destination))
        return data as Data
    }

    private func pixelSize(of data: Data) throws -> (width: Int, height: Int) {
        let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
        let properties = try #require(CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
        let width = try #require(properties[kCGImagePropertyPixelWidth] as? Int)
        let height = try #require(properties[kCGImagePropertyPixelHeight] as? Int)
        return (width, height)
    }

    @Test func largeImageIsDownsampledToSixteenHundredPreservingAspect() async throws {
        let original = try Self.makeImageData(width: 4000, height: 3000)

        let output = try await PhotoProcessor().downsampledJPEG(from: original)

        let size = try pixelSize(of: output)
        #expect(max(size.width, size.height) == 1600)
        #expect(size.width == 1600 && size.height == 1200)
    }

    @Test func smallImageIsNotUpscaled() async throws {
        let original = try Self.makeImageData(width: 800, height: 600)
        let output = try await PhotoProcessor().downsampledJPEG(from: original)
        let size = try pixelSize(of: output)
        #expect(size.width == 800 && size.height == 600)
    }

    @Test func invalidDataThrowsUnreadableImage() async {
        await #expect(throws: PhotoError.unreadableImage) {
            try await PhotoProcessor().downsampledJPEG(from: Data("not an image".utf8))
        }
    }

    @Test func thumbnailFitsRequestedPixelSize() async throws {
        let original = try Self.makeImageData(width: 4000, height: 3000)
        let thumbnail = try await PhotoProcessor().thumbnail(from: original, pointSize: 50, scale: 3)
        #expect(max(thumbnail.width, thumbnail.height) == 150)
    }
}
