import SpriteKit

public extension UI {
    /// A base class for all UI components that require a Canvas context.
    ///
    /// `UIBehaviour` extends `Behaviour` to provide UI-specific functionality by automatically
    /// finding and connecting to the parent `CanvasObject`. All UI components must inherit from
    /// this class and be placed within a Canvas hierarchy.
    ///
    /// ## Overview
    ///
    /// UIBehaviour performs automatic Canvas detection during the `awake()` lifecycle method,
    /// traversing the GameObject hierarchy to find the parent CanvasObject. If no Canvas is found,
    /// the component will trigger a fatal error as UI components require a Canvas context to function.
    ///
    /// ## Usage
    ///
    /// Create custom UI components by subclassing UIBehaviour:
    ///
    /// ```swift
    /// class CustomButton: UIBehaviour {
    ///     override func awake() {
    ///         super.awake()
    ///         // Access canvasObject and skScene here
    ///         print("Canvas size: \(canvasObject.size)")
    ///     }
    /// }
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Canvas Integration
    ///
    /// - ``canvasObject``
    /// - ``skScene``
    ///
    /// ### Lifecycle Methods
    ///
    /// - ``awake()``
    class UIBehaviour: Behaviour {
        /// The parent CanvasObject that contains this UI component.
        ///
        /// This property is automatically set during the `awake()` lifecycle method
        /// by traversing the GameObject hierarchy. It provides access to Canvas-specific
        /// properties and the underlying SpriteKit scene.
        ///
        /// - Important: This property will be force-unwrapped. Ensure the UI component
        ///   is always placed within a Canvas hierarchy.
        public var canvasObject: CanvasObject!

        /// The SpriteKit scene associated with the parent Canvas.
        ///
        /// Provides direct access to the SKScene for rendering UI elements.
        /// This is a convenience property that forwards to `canvasObject.skScene`.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let sprite = SKSpriteNode(texture: texture)
        /// skScene.addChild(sprite)
        /// ```
        public var skScene: SKScene {
            self.canvasObject.skScene
        }

        /// Called when the component is initialized.
        ///
        /// This method traverses the GameObject hierarchy to find the parent CanvasObject.
        /// If no Canvas is found in the parent chain, it triggers a fatal error.
        ///
        /// - Important: When overriding this method in subclasses, always call `super.awake()`
        ///   first to ensure the Canvas connection is established.
        ///
        /// ## Example
        ///
        /// ```swift
        /// override func awake() {
        ///     super.awake()
        ///     // Your initialization code here
        /// }
        /// ```
        override public func awake() {
            var canvasFound = false
            var parent = gameObject
            while parent != nil {
                if let object = parent as? CanvasObject {
                    self.canvasObject = object
                    canvasFound = true
                    break
                }
                parent = parent?.parent
            }
            guard canvasFound
            else { fatalError("any subclass of UIBehaviour must be inside a Canvas") }
        }
    }
}
