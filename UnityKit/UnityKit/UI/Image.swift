
import SpriteKit

extension UI {

    public final class Image: UIBehaviour {

        public enum ImageType {
            case simple(Size)
            case filled
        }

        private var spriteNode: SKSpriteNode?
        public var type: ImageType = .filled {
            didSet {
                updateImage()
            }
        }

        public var sourceImage: UIImage? {
            didSet {
                updateImage()
            }
        }

        public var color: Color = .white {
            didSet {
                updateImage()
            }
        }

        private func updateImage() {

            spriteNode?.removeFromParent()

            guard let sourceImage = sourceImage
                else { return }

            let texture: SKTexture
            switch type {
            case let .simple(size):
                texture = SKTexture(image: sourceImage.resize(to: size.toCGSize()))
            case .filled:
                texture = SKTexture(image: sourceImage.resize(to: skScene.size))
            }

            let sprite = SKSpriteNode(texture: texture)
            sprite.anchorPoint = CGPoint(x: 0, y: 0)
            skScene.addChild(sprite)
            spriteNode = sprite
        }

        public func loadImage(fileName: String, type: ImageType, bundle: Bundle = Bundle.main) {

            guard let url = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
                else { return }

            do {
                let imageData = try Data(contentsOf: url)
                guard let image = UIImage(data: imageData)
                    else { return }

                self.type = type
                sourceImage = image

            } catch {}
        }
    }
}
