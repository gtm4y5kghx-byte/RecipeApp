import Testing
import UIKit
@testable import RecipeApp

@Suite("Image Storage Service")
struct ImageStorageServiceTests {

    // MARK: - saveImageData

    @Test("saveImageData saves file and returns file URL string")
    func testSaveImageDataSavesFile() {
        let imageData = createTestImageData(width: 100, height: 100)

        let result = ImageStorageService.saveImageData(imageData)

        #expect(result != nil)
        #expect(result!.hasPrefix("file://"))

        if let urlString = result, let url = URL(string: urlString) {
            #expect(FileManager.default.fileExists(atPath: url.path))
            // Clean up
            try? FileManager.default.removeItem(at: url)
        }
    }

    @Test("saveImageData saves to app group container")
    func testSaveImageDataUsesAppGroupContainer() {
        let imageData = createTestImageData(width: 100, height: 100)

        let result = ImageStorageService.saveImageData(imageData)

        #expect(result != nil)
        #expect(result!.contains("recipe-images"))

        // Clean up
        if let urlString = result, let url = URL(string: urlString) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    @Test("saveImageData returns nil for invalid data")
    func testSaveImageDataReturnsNilForInvalidData() {
        let garbageData = Data([0xFF, 0x00, 0x42, 0x13])

        let result = ImageStorageService.saveImageData(garbageData)

        #expect(result == nil)
    }

    @Test("saveImageData produces JPEG output")
    func testSaveImageDataProducesJPEG() {
        let imageData = createTestImageData(width: 100, height: 100)

        let result = ImageStorageService.saveImageData(imageData)

        #expect(result != nil)

        if let urlString = result, let url = URL(string: urlString) {
            let savedData = try? Data(contentsOf: url)
            #expect(savedData != nil)
            // JPEG magic bytes: 0xFF 0xD8
            #expect(savedData![0] == 0xFF)
            #expect(savedData![1] == 0xD8)
            // Clean up
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - Resize Behavior

    @Test("saveImageData resizes tall images to max 900px height")
    func testResizeTallImage() {
        let imageData = createTestImageData(width: 600, height: 1200)

        let result = ImageStorageService.saveImageData(imageData)

        #expect(result != nil)

        if let urlString = result, let url = URL(string: urlString) {
            let savedData = try? Data(contentsOf: url)
            let savedImage = UIImage(data: savedData!)
            #expect(savedImage != nil)
            #expect(savedImage!.size.height <= 900)
            // Aspect ratio preserved: 600/1200 = 0.5, so width should be ~450
            #expect(savedImage!.size.width <= 450 + 1) // +1 for rounding
            #expect(savedImage!.size.width >= 450 - 1)
            // Clean up
            try? FileManager.default.removeItem(at: url)
        }
    }

    @Test("saveImageData does not upscale small images")
    func testDoesNotUpscaleSmallImages() {
        let imageData = createTestImageData(width: 200, height: 400)

        let result = ImageStorageService.saveImageData(imageData)

        #expect(result != nil)

        if let urlString = result, let url = URL(string: urlString) {
            let savedData = try? Data(contentsOf: url)
            let savedImage = UIImage(data: savedData!)
            #expect(savedImage != nil)
            // Should remain at original dimensions (within JPEG re-encoding tolerance)
            #expect(savedImage!.size.height <= 400 + 1)
            #expect(savedImage!.size.height >= 400 - 1)
            #expect(savedImage!.size.width <= 200 + 1)
            #expect(savedImage!.size.width >= 200 - 1)
            // Clean up
            try? FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - deleteImage

    @Test("deleteImage removes file from disk")
    func testDeleteImageRemovesFile() {
        let imageData = createTestImageData(width: 50, height: 50)
        let urlString = ImageStorageService.saveImageData(imageData)

        #expect(urlString != nil)

        if let urlString, let url = URL(string: urlString) {
            #expect(FileManager.default.fileExists(atPath: url.path))

            ImageStorageService.deleteImage(at: urlString)

            #expect(FileManager.default.fileExists(atPath: url.path) == false)
        }
    }

    @Test("deleteImage handles nil gracefully")
    func testDeleteImageHandlesNil() {
        // Should not crash
        ImageStorageService.deleteImage(at: nil)
    }

    @Test("deleteImage handles non-existent file gracefully")
    func testDeleteImageHandlesNonExistentFile() {
        // Should not crash
        ImageStorageService.deleteImage(at: "file:///nonexistent/path/image.jpg")
    }

    @Test("deleteImage ignores remote URLs")
    func testDeleteImageIgnoresRemoteURLs() {
        // Should not crash or attempt to delete anything
        ImageStorageService.deleteImage(at: "https://example.com/image.jpg")
    }

    // MARK: - Helpers

    private func createTestImageData(width: CGFloat, height: CGFloat) -> Data {
        let size = CGSize(width: width, height: height)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let image = renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return image.pngData()!
    }
}
