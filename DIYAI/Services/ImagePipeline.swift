import UIKit

struct ImagePipeline {
    static func compressImage(_ image: UIImage, quality: CGFloat = 0.8) -> Data? {
        image.jpegData(compressionQuality: quality)
    }

    static func thumbnail(from image: UIImage, maxDimension: CGFloat = 512) -> UIImage {
        let maxSide = max(image.size.width, image.size.height)
        let scale = maxDimension / maxSide
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
