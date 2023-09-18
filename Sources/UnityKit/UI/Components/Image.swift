import SpriteKit

extension UI {
    public final class Image: UIBehaviour {
        public enum ImageType {
            case simple(Size)
            case filled(Size)
        }

        public enum FillMethod {
            case horizontal(FillOrigin)
            case vertical(FillOrigin)
            case radial90(FillOrigin)
            case radial180(FillOrigin)
            case radial360(FillOrigin)
        }

        public enum FillOrigin {
            case bottom
            case right
            case top
            case left
        }

        private var spriteNode: SKSpriteNode?

        public var type: ImageType = .filled(.zero) {
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

        public var fillMethod: FillMethod = .horizontal(.bottom) {
            didSet {
                updateImage()
            }
        }

        public var fillAmount: Float = 1 {
            didSet {
                updateImage()
            }
        }

        public var clockwise: Bool = false {
            didSet {
                updateImage()
            }
        }

        /**
         Configurable block that passes and returns itself.

         - parameters:
         - configurationBlock: block that passes itself.
         - returns: itself
         */
        @discardableResult public func configure(_ configurationBlock: (Image) -> Void) -> Image {
            configurationBlock(self)
            return self
        }

        private func updateImage() {
            canvasObject.resume()
            defer {
                canvasObject.pause()
            }

            spriteNode?.removeFromParent()

            guard let sourceImage = sourceImage
            else { return }

            var displayImage = sourceImage

            if color != .white {
                displayImage = displayImage.replaceColor(with: color)
            }

            let texture: SKTexture

            switch type {
            case let .simple(size):
                texture = SKTexture(image: displayImage.resize(to: size.toCGSize()))

            case let .filled(size):
                if size == .zero {
                    displayImage = displayImage.resize(to: skScene.size)
                } else {
                    displayImage = displayImage.resize(to: size.toCGSize())
                }

                switch fillMethod {
                case let .radial360(fillOrigin):
                    let to = fillAmount.clamp01() * 360
                    displayImage = displayImage.fill(
                        fromAngle: 0,
                        toAngle: to,
                        fillOrigin: fillOrigin,
                        clockwise: clockwise
                    )
                default:
                    break
                }
                texture = SKTexture(image: displayImage)
            }
            
            let sprite = SKSpriteNode(texture: texture)
            sprite.anchorPoint = CGPoint(x: 0, y: 0)
            skScene.addChild(sprite)
            spriteNode = sprite
        }

        public func loadImage(fileName: String, type: ImageType, color: Color = .white, bundle: Bundle = Bundle.main) {
            guard let url = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
            else { return }

            do {
                let imageData = try Data(contentsOf: url)
                guard let sourceImage = UIImage(data: imageData)
                else { return }

                self.color = color
                self.type = type
                self.sourceImage = sourceImage
            } catch {}
        }
    }
}
