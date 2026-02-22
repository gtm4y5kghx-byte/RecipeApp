import UIKit

struct ImageStorageService {

    private static let maxImageHeight: CGFloat = 900
    private static let jpegQuality: CGFloat = 0.8
    private static let subdirectory = "recipe-images"
    private static let appGroupID = "group.com.jasenmp.RecipeApp"

    // MARK: - Public API

    static func downloadAndSaveImage(from remoteURL: String) async -> String? {
        guard let url = URL(string: remoteURL) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return saveImageData(data)
        } catch {
            return nil
        }
    }

    static func saveImageData(_ data: Data) -> String? {
        guard let image = UIImage(data: data) else { return nil }
        guard let directory = imagesDirectory() else { return nil }

        let resized = resizeImage(image)
        guard let compressed = compressImage(resized) else { return nil }

        let filename = UUID().uuidString + ".jpg"
        let fileURL = directory.appendingPathComponent(filename)

        do {
            try compressed.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            return nil
        }
    }

    static func deleteImage(at urlString: String?) {
        guard let urlString,
              let url = URL(string: urlString),
              url.isFileURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    // MARK: - Private Helpers

    private static func imagesDirectory() -> URL? {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else { return nil }

        let directory = containerURL.appendingPathComponent(subdirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static func resizeImage(_ image: UIImage) -> UIImage {
        guard image.size.height > maxImageHeight else { return image }

        let scale = maxImageHeight / image.size.height
        let newSize = CGSize(
            width: (image.size.width * scale).rounded(),
            height: maxImageHeight
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private static func compressImage(_ image: UIImage) -> Data? {
        image.jpegData(compressionQuality: jpegQuality)
    }
}
