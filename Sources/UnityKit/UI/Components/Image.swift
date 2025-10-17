import SpriteKit

public extension UI {
    /// A UI component for displaying images with various fill methods and effects.
    ///
    /// `Image` is a versatile UI component that can display static images or filled images
    /// with customizable fill patterns, colors, and animations. It supports both simple
    /// image display and advanced fill effects including horizontal, vertical, and radial fills.
    ///
    /// ## Overview
    ///
    /// The Image component uses SpriteKit for rendering and supports dynamic updates when
    /// properties change. Images can be loaded from files, colored, and filled with various
    /// methods to create progress bars, health indicators, or animated UI elements.
    ///
    /// ## Usage
    ///
    /// ### Simple Image Display
    ///
    /// ```swift
    /// let imageObject = GameObject()
    /// imageObject.parent = canvasObject
    /// let image = imageObject.addComponent(Image.self)
    ///
    /// image.configure { img in
    ///     img.loadImage(fileName: "logo", type: .simple(Size(width: 200, height: 100)))
    /// }
    /// ```
    ///
    /// ### Filled Image with Progress Bar Effect
    ///
    /// ```swift
    /// let healthBar = imageObject.addComponent(Image.self)
    /// healthBar.configure { img in
    ///     img.loadImage(fileName: "health_bar", type: .filled(Size(width: 300, height: 50)))
    ///     img.fillMethod = .horizontal(.left)
    ///     img.fillAmount = 0.75 // 75% health
    /// }
    /// ```
    ///
    /// ### Radial Fill for Cooldown Timer
    ///
    /// ```swift
    /// let cooldownIndicator = imageObject.addComponent(Image.self)
    /// cooldownIndicator.configure { img in
    ///     img.loadImage(fileName: "cooldown", type: .filled(Size(width: 100, height: 100)))
    ///     img.fillMethod = .radial360(.top)
    ///     img.clockwise = true
    ///     img.fillAmount = 0.0 // Start empty
    /// }
    ///
    /// // Update over time
    /// cooldownIndicator.fillAmount = elapsedTime / totalCooldown
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Enumerations
    ///
    /// - ``ImageType``
    /// - ``FillMethod``
    /// - ``FillOrigin``
    ///
    /// ### Image Properties
    ///
    /// - ``type``
    /// - ``sourceImage``
    /// - ``color``
    ///
    /// ### Fill Properties
    ///
    /// - ``fillMethod``
    /// - ``fillAmount``
    /// - ``clockwise``
    ///
    /// ### Methods
    ///
    /// - ``configure(_:)``
    /// - ``loadImage(fileName:type:color:bundle:)``
    final class Image: UIBehaviour {
        /// Specifies how the image should be displayed and sized.
        ///
        /// Determines whether the image is displayed as a simple sprite or with
        /// fill capabilities for animated effects.
        ///
        /// ## Topics
        ///
        /// ### Cases
        ///
        /// - `simple(Size)`: Display the image as a simple sprite with the specified size.
        ///   The image will be resized to fit the given dimensions.
        ///
        /// - `filled(Size)`: Display the image with fill capabilities. Supports partial
        ///   filling using ``fillMethod`` and ``fillAmount`` properties. Pass `.zero` for
        ///   size to use the scene's dimensions.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Simple static image
        /// image.type = .simple(Size(width: 100, height: 100))
        ///
        /// // Fillable image for progress bar
        /// image.type = .filled(Size(width: 200, height: 50))
        /// ```
        public enum ImageType {
            case simple(Size)
            case filled(Size)
        }

        /// Defines the direction and pattern for filling an image.
        ///
        /// Specifies how a filled image should progressively reveal or hide its content
        /// based on the ``fillAmount`` property. Each method supports a ``FillOrigin``
        /// that determines the starting point of the fill.
        ///
        /// ## Topics
        ///
        /// ### Cases
        ///
        /// - `horizontal(FillOrigin)`: Fill horizontally from left or right.
        ///   Use `.left` to fill from left to right, or `.right` to fill from right to left.
        ///
        /// - `vertical(FillOrigin)`: Fill vertically from bottom or top.
        ///   Use `.bottom` to fill from bottom to top, or `.top` to fill from top to bottom.
        ///
        /// - `radial90(FillOrigin)`: Fill in a 90-degree arc.
        ///   Creates a quarter-circle fill pattern starting from the specified origin.
        ///
        /// - `radial180(FillOrigin)`: Fill in a 180-degree arc.
        ///   Creates a half-circle fill pattern starting from the specified origin.
        ///
        /// - `radial360(FillOrigin)`: Fill in a complete 360-degree circle.
        ///   Creates a circular fill pattern starting from the specified origin.
        ///   Use ``clockwise`` to control the direction of rotation.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Horizontal progress bar
        /// image.fillMethod = .horizontal(.left)
        /// image.fillAmount = 0.5 // Half filled
        ///
        /// // Circular cooldown indicator
        /// image.fillMethod = .radial360(.top)
        /// image.clockwise = true
        /// image.fillAmount = 0.75 // 75% complete
        /// ```
        public enum FillMethod {
            case horizontal(FillOrigin)
            case vertical(FillOrigin)
            case radial90(FillOrigin)
            case radial180(FillOrigin)
            case radial360(FillOrigin)
        }

        /// Specifies the starting position for fill operations.
        ///
        /// Defines the origin point from which a fill begins. Used in conjunction
        /// with ``FillMethod`` to control the direction of fill animations.
        ///
        /// ## Topics
        ///
        /// ### Cases
        ///
        /// - `bottom`: Fill starts from the bottom edge.
        /// - `right`: Fill starts from the right edge.
        /// - `top`: Fill starts from the top edge.
        /// - `left`: Fill starts from the left edge.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Fill from left to right
        /// image.fillMethod = .horizontal(.left)
        ///
        /// // Fill from bottom to top
        /// image.fillMethod = .vertical(.bottom)
        ///
        /// // Radial fill starting from top (12 o'clock position)
        /// image.fillMethod = .radial360(.top)
        /// ```
        public enum FillOrigin {
            case bottom
            case right
            case top
            case left
        }

        private var spriteNode: SKSpriteNode?

        /// The display type of the image.
        ///
        /// Determines whether the image is rendered as a simple static sprite or
        /// as a fillable image with progressive reveal capabilities. Changing this
        /// property triggers an immediate update of the displayed image.
        ///
        /// The default value is `.filled(.zero)`, which creates a fillable image
        /// sized to match the scene dimensions.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Static image with fixed size
        /// image.type = .simple(Size(width: 150, height: 150))
        ///
        /// // Dynamic fillable image
        /// image.type = .filled(Size(width: 200, height: 40))
        /// ```
        public var type: ImageType = .filled(.zero) {
            didSet {
                self.updateImage()
            }
        }

        /// The source image to display.
        ///
        /// Provides the base image that will be rendered. When set, the image is
        /// automatically processed according to the current ``type``, ``color``,
        /// and fill properties. Setting this property triggers an immediate update
        /// of the displayed image.
        ///
        /// Use ``loadImage(fileName:type:color:bundle:)`` for convenient file-based
        /// image loading.
        ///
        /// ## Example
        ///
        /// ```swift
        /// if let loadedImage = UIImage(named: "character_portrait") {
        ///     image.sourceImage = loadedImage
        /// }
        /// ```
        public var sourceImage: UIImage? {
            didSet {
                self.updateImage()
            }
        }

        /// The tint color applied to the image.
        ///
        /// Allows you to dynamically change the color of the image without creating
        /// multiple image assets. Non-white colors will replace the white pixels in
        /// the source image. The default value is `.white`, which displays the image
        /// in its original colors.
        ///
        /// Changing this property triggers an immediate update of the displayed image.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Red tint for health bar
        /// image.color = .red
        ///
        /// // Blue tint for mana bar
        /// image.color = .blue
        ///
        /// // Original colors
        /// image.color = .white
        /// ```
        public var color: Color = .white {
            didSet {
                self.updateImage()
            }
        }

        /// The method used to fill the image.
        ///
        /// Specifies the direction and pattern for progressive image filling when
        /// using a filled image type. Only applicable when ``type`` is set to `.filled`.
        /// The default value is `.horizontal(.bottom)`.
        ///
        /// Combine with ``fillAmount`` to create animated progress indicators,
        /// health bars, cooldown timers, and other dynamic UI elements.
        ///
        /// Changing this property triggers an immediate update of the displayed image.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Horizontal fill from left
        /// image.fillMethod = .horizontal(.left)
        ///
        /// // Circular fill from top (clockwise)
        /// image.fillMethod = .radial360(.top)
        /// image.clockwise = true
        /// ```
        public var fillMethod: FillMethod = .horizontal(.bottom) {
            didSet {
                self.updateImage()
            }
        }

        /// The amount of fill, ranging from 0.0 (empty) to 1.0 (full).
        ///
        /// Controls how much of the image is visible when using a filled image type.
        /// The value is automatically clamped between 0.0 and 1.0. The default value
        /// is 1.0 (fully filled).
        ///
        /// Animate this property to create smooth transitions for progress indicators,
        /// health bars, and cooldown timers.
        ///
        /// Changing this property triggers an immediate update of the displayed image.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Empty
        /// image.fillAmount = 0.0
        ///
        /// // Half filled
        /// image.fillAmount = 0.5
        ///
        /// // Full
        /// image.fillAmount = 1.0
        ///
        /// // Animate health decrease
        /// let currentHealth: Float = 65
        /// let maxHealth: Float = 100
        /// image.fillAmount = currentHealth / maxHealth
        /// ```
        public var fillAmount: Float = 1 {
            didSet {
                self.updateImage()
            }
        }

        /// Determines the direction of radial fills.
        ///
        /// When `true`, radial fills proceed in a clockwise direction.
        /// When `false`, radial fills proceed counter-clockwise.
        /// Only affects radial fill methods. The default value is `false`.
        ///
        /// Changing this property triggers an immediate update of the displayed image.
        ///
        /// ## Example
        ///
        /// ```swift
        /// image.fillMethod = .radial360(.top)
        ///
        /// // Clockwise rotation (typical for cooldowns)
        /// image.clockwise = true
        ///
        /// // Counter-clockwise rotation
        /// image.clockwise = false
        /// ```
        public var clockwise: Bool = false {
            didSet {
                self.updateImage()
            }
        }

        /// Configures the Image using a closure.
        ///
        /// Provides a convenient way to configure the Image by passing a closure
        /// that receives the Image instance as a parameter. This enables fluent
        /// configuration patterns and ensures all properties can be set before
        /// the image is displayed.
        ///
        /// - Parameter configurationBlock: A closure that receives the Image instance
        ///   for configuration.
        ///
        /// - Returns: The Image instance for method chaining.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let image = imageObject.addComponent(Image.self)
        ///     .configure { img in
        ///         img.loadImage(fileName: "progress_bar", type: .filled(Size(width: 300, height: 50)))
        ///         img.fillMethod = .horizontal(.left)
        ///         img.color = .green
        ///         img.fillAmount = 0.8
        ///     }
        /// ```
        @discardableResult public func configure(_ configurationBlock: (Image) -> Void) -> Image {
            configurationBlock(self)
            return self
        }

        private func updateImage() {
            canvasObject.resume()
            defer {
                canvasObject.pause()
            }

            self.spriteNode?.removeFromParent()

            guard let sourceImage
            else { return }

            var displayImage = sourceImage

            if self.color != .white {
                displayImage = displayImage.replaceColor(with: self.color)
            }

            let texture: SKTexture

            switch self.type {
            case .simple(let size):
                texture = SKTexture(image: displayImage.resize(to: size.toCGSize()))

            case .filled(let size):
                if size == .zero {
                    displayImage = displayImage.resize(to: skScene.size)
                } else {
                    displayImage = displayImage.resize(to: size.toCGSize())
                }

                switch self.fillMethod {
                case .radial360(let fillOrigin):
                    let to = self.fillAmount.clamp01() * 360
                    displayImage = displayImage.fill(
                        fromAngle: 0,
                        toAngle: to,
                        fillOrigin: fillOrigin,
                        clockwise: self.clockwise
                    )
                default:
                    break
                }
                texture = SKTexture(image: displayImage)
            }

            let sprite = SKSpriteNode(texture: texture)
            sprite.anchorPoint = CGPoint(x: 0, y: 0)
            skScene.addChild(sprite)
            self.spriteNode = sprite
        }

        /// Loads an image from a file and configures the Image component.
        ///
        /// Convenience method that loads an image from the specified file, sets its type
        /// and color, and updates the display. This method searches for the file in the
        /// specified bundle and automatically handles image loading and configuration.
        ///
        /// - Parameters:
        ///   - fileName: The name of the image file (without extension recommended, or with extension).
        ///   - type: The ``ImageType`` to use for displaying the image.
        ///   - color: The tint color to apply to the image. Defaults to `.white` (no tint).
        ///   - bundle: The bundle containing the image file. Defaults to `Bundle.main`.
        ///
        /// The method silently fails if the file cannot be found or loaded. No error is thrown.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Load a simple logo image
        /// image.loadImage(
        ///     fileName: "company_logo",
        ///     type: .simple(Size(width: 200, height: 100))
        /// )
        ///
        /// // Load a fillable health bar with red tint
        /// image.loadImage(
        ///     fileName: "health_bar",
        ///     type: .filled(Size(width: 300, height: 50)),
        ///     color: .red
        /// )
        ///
        /// // Load from a custom bundle
        /// image.loadImage(
        ///     fileName: "custom_icon",
        ///     type: .simple(Size(width: 64, height: 64)),
        ///     bundle: customBundle
        /// )
        /// ```
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
