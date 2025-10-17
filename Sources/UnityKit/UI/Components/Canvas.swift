import SpriteKit

public extension UI {
    /// A UI container that manages the rendering context for UI components.
    ///
    /// `Canvas` is the root component for all UI elements in UnityKit. It provides the coordinate
    /// system and rendering context required by UI components through its integration with SpriteKit.
    /// All UI elements must be children of a Canvas to function properly.
    ///
    /// ## Overview
    ///
    /// The Canvas component manages the world-space dimensions and pixel density for UI rendering.
    /// It acts as the bridge between UnityKit's GameObject hierarchy and SpriteKit's scene graph,
    /// enabling 2D UI rendering within the engine.
    ///
    /// ## Usage
    ///
    /// Create a Canvas as the root of your UI hierarchy:
    ///
    /// ```swift
    /// let canvasObject = CanvasObject()
    /// let canvas = canvasObject.addComponent(Canvas.self)
    ///
    /// canvas.configure { canvas in
    ///     // Canvas is now ready for UI components
    /// }
    ///
    /// // Add UI components as children
    /// let imageObject = GameObject()
    /// imageObject.parent = canvasObject
    /// let image = imageObject.addComponent(Image.self)
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Canvas Properties
    ///
    /// - ``worldSize``
    /// - ``pixelPerUnit``
    ///
    /// ### Configuration
    ///
    /// - ``configure(_:)``
    class Canvas: UIBehaviour {
        /// The size of the Canvas in world units.
        ///
        /// Represents the dimensions of the Canvas in the world coordinate system.
        /// This property is automatically managed by the CanvasObject and is read-only
        /// from external code.
        ///
        /// The world size determines the virtual space available for UI layout and
        /// is independent of the actual pixel dimensions of the display.
        public internal(set) var worldSize: Size = .zero

        /// The number of pixels per world unit.
        ///
        /// Controls the resolution and scale of UI elements within the Canvas.
        /// A higher value produces sharper UI elements but requires more memory.
        /// The default value is 10 pixels per unit.
        ///
        /// This property affects how world coordinates map to screen pixels:
        /// - Higher values: More detail, higher memory usage
        /// - Lower values: Less detail, lower memory usage
        ///
        /// ## Example
        ///
        /// ```swift
        /// // For high-resolution displays
        /// canvas.pixelPerUnit = 20
        ///
        /// // For low-resolution or performance-critical scenarios
        /// canvas.pixelPerUnit = 5
        /// ```
        public internal(set) var pixelPerUnit: Float = 10

        /// Configures the Canvas using a closure.
        ///
        /// Provides a convenient way to configure the Canvas by passing a closure
        /// that receives the Canvas instance as a parameter. This enables fluent
        /// configuration patterns.
        ///
        /// - Parameter configurationBlock: A closure that receives the Canvas instance
        ///   for configuration.
        ///
        /// - Returns: The Canvas instance for method chaining.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let canvas = canvasObject.addComponent(Canvas.self)
        ///     .configure { canvas in
        ///         // Canvas configuration can be performed here
        ///         print("Canvas world size: \(canvas.worldSize)")
        ///     }
        /// ```
        @discardableResult public func configure(_ configurationBlock: (Canvas) -> Void) -> Canvas {
            configurationBlock(self)
            return self
        }
    }
}
