import SpriteKit

public extension UI {
    /// A UI component for displaying numeric values as a visual slider.
    ///
    /// `Slider` provides a visual representation of a numeric value within a defined range
    /// by controlling the fill amount of an associated ``Image`` component. It automatically
    /// maps values between minimum and maximum bounds to a normalized fill percentage.
    ///
    /// ## Overview
    ///
    /// The Slider component is commonly used for progress bars, health indicators, stamina bars,
    /// loading indicators, and other UI elements that need to display a numeric value visually.
    /// It works by connecting to an Image component and updating its `fillAmount` property
    /// based on the slider's current value.
    ///
    /// ## Usage
    ///
    /// ### Basic Slider Setup
    ///
    /// ```swift
    /// // Create the background image
    /// let backgroundObject = GameObject()
    /// backgroundObject.parent = canvasObject
    /// let background = backgroundObject.addComponent(Image.self)
    /// background.loadImage(fileName: "slider_background", type: .simple(Size(width: 300, height: 50)))
    ///
    /// // Create the fill image
    /// let fillObject = GameObject()
    /// fillObject.parent = canvasObject
    /// let fillImage = fillObject.addComponent(Image.self)
    /// fillImage.loadImage(fileName: "slider_fill", type: .filled(Size(width: 300, height: 50)))
    /// fillImage.fillMethod = .horizontal(.left)
    ///
    /// // Create the slider
    /// let sliderObject = GameObject()
    /// sliderObject.parent = canvasObject
    /// let slider = sliderObject.addComponent(Slider.self)
    /// slider.configure { slider in
    ///     slider.fillImage = fillImage
    ///     slider.minValue = 0
    ///     slider.maxValue = 100
    ///     slider.value = 75 // 75% filled
    /// }
    /// ```
    ///
    /// ### Health Bar Example
    ///
    /// ```swift
    /// // Setup health bar
    /// slider.fillImage = healthBarImage
    /// slider.minValue = 0
    /// slider.maxValue = 100
    /// slider.value = currentHealth
    ///
    /// // Update when health changes
    /// func takeDamage(_ amount: Float) {
    ///     currentHealth -= amount
    ///     slider.value = currentHealth // Automatically updates visual
    /// }
    /// ```
    ///
    /// ### Loading Progress Example
    ///
    /// ```swift
    /// // Setup loading bar
    /// loadingSlider.fillImage = loadingBarImage
    /// loadingSlider.minValue = 0
    /// loadingSlider.maxValue = 1
    ///
    /// // Update during loading
    /// func updateLoadingProgress(_ progress: Float) {
    ///     loadingSlider.value = progress // 0.0 to 1.0
    /// }
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Slider Properties
    ///
    /// - ``fillImage``
    /// - ``minValue``
    /// - ``maxValue``
    /// - ``value``
    ///
    /// ### Configuration
    ///
    /// - ``configure(_:)``
    class Slider: UIBehaviour {
        /// The Image component used to display the slider's fill.
        ///
        /// This Image should be configured with a fill type and fill method to visualize
        /// the slider's value. The Slider automatically updates this image's `fillAmount`
        /// property based on the current value relative to the min and max values.
        ///
        /// Typically set to an Image configured with `.filled()` type and a horizontal
        /// or vertical fill method.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let fillImage = fillObject.addComponent(Image.self)
        /// fillImage.loadImage(fileName: "bar_fill", type: .filled(Size(width: 300, height: 50)))
        /// fillImage.fillMethod = .horizontal(.left)
        ///
        /// slider.fillImage = fillImage
        /// ```
        public var fillImage: Image?

        /// The minimum value of the slider's range.
        ///
        /// Defines the lower bound of the slider's value range. When ``value`` equals
        /// this minimum, the fill image will be empty (fillAmount = 0.0).
        /// The default value is 0.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Standard 0-100 range
        /// slider.minValue = 0
        /// slider.maxValue = 100
        ///
        /// // Custom range (e.g., for temperature)
        /// slider.minValue = -50
        /// slider.maxValue = 50
        /// ```
        public var minValue: Float = 0

        /// The maximum value of the slider's range.
        ///
        /// Defines the upper bound of the slider's value range. When ``value`` equals
        /// this maximum, the fill image will be completely filled (fillAmount = 1.0).
        /// The default value is 1.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Percentage range
        /// slider.minValue = 0
        /// slider.maxValue = 100
        ///
        /// // Normalized range
        /// slider.minValue = 0
        /// slider.maxValue = 1
        /// ```
        public var maxValue: Float = 1

        /// The current value of the slider.
        ///
        /// Represents the slider's current position within the range defined by
        /// ``minValue`` and ``maxValue``. When set, the value is automatically clamped
        /// to stay within the valid range, and the associated ``fillImage`` is updated
        /// to reflect the new value visually.
        ///
        /// The default value is 0.
        ///
        /// The fill amount is calculated as:
        /// `(value - minValue) / (maxValue - minValue)`
        ///
        /// ## Example
        ///
        /// ```swift
        /// slider.minValue = 0
        /// slider.maxValue = 100
        ///
        /// slider.value = 50   // 50% filled
        /// slider.value = 75   // 75% filled
        /// slider.value = 120  // Clamped to 100, fully filled
        /// slider.value = -10  // Clamped to 0, empty
        /// ```
        public var value: Float = 0 {
            didSet {
                self.value.clamp(self.minValue...self.maxValue)
                self.updateValue()
            }
        }

        /// Configures the Slider using a closure.
        ///
        /// Provides a convenient way to configure the Slider by passing a closure
        /// that receives the Slider instance as a parameter. This enables fluent
        /// configuration patterns and ensures all properties can be set together.
        ///
        /// - Parameter configurationBlock: A closure that receives the Slider instance
        ///   for configuration.
        ///
        /// - Returns: The Slider instance for method chaining.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let slider = sliderObject.addComponent(Slider.self)
        ///     .configure { slider in
        ///         slider.fillImage = healthBarFill
        ///         slider.minValue = 0
        ///         slider.maxValue = 100
        ///         slider.value = 80
        ///     }
        /// ```
        @discardableResult public func configure(_ configurationBlock: (Slider) -> Void) -> Slider {
            configurationBlock(self)
            return self
        }

        private func updateValue() {
            self.fillImage?.fillAmount = ((self.value - self.minValue) / (self.maxValue - self.minValue))
        }
    }
}
