import Foundation
import SceneKit

/// A component that controls the rendering of a game object's geometry.
///
/// The `Renderer` component manages material assignment, shadow casting, and rendering order
/// for game objects with visible geometry. It provides the interface between game objects and
/// the rendering system, controlling how objects appear in the scene.
///
/// ## Overview
///
/// Every visible game object in UnityKit requires a `Renderer` component to be displayed.
/// The renderer manages one or more materials that define the object's appearance, controls
/// whether the object casts shadows, and determines the rendering order for proper layering.
///
/// ## Topics
///
/// ### Creating a Renderer
///
/// - ``init()``
/// - ``configure(_:)``
///
/// ### Material Management
///
/// - ``materials``
/// - ``material``
///
/// ### Rendering Properties
///
/// - ``shadowCasting``
/// - ``sortingOrder``
///
/// ## Example Usage
///
/// ```swift
/// // Add a renderer with a single material
/// let renderer = gameObject.addComponent(Renderer.self)
/// renderer.material = Material().configure { mat in
///     mat.diffuse.contents = NSColor.red
///     mat.metalness.contents = 0.8
/// }
/// renderer.shadowCasting = true
///
/// // Create a multi-material renderer
/// let multiMatRenderer = gameObject.addComponent(Renderer.self)
/// multiMatRenderer.materials = [
///     Material().configure { $0.diffuse.contents = NSColor.blue },
///     Material().configure { $0.diffuse.contents = NSColor.green }
/// ]
///
/// // Set rendering order
/// renderer.sortingOrder = 100  // Render after objects with lower values
/// ```
public final class Renderer: Component {
    override var order: ComponentOrder {
        .renderer
    }

    /// The array of materials used by this renderer.
    ///
    /// This property controls all materials applied to the game object's geometry. When a geometry
    /// has multiple elements (such as a multi-submesh model), each material corresponds to one element.
    /// Changing this property immediately updates the visual appearance of the rendered object.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Assign multiple materials to different parts of the geometry
    /// renderer.materials = [
    ///     Material().configure { $0.diffuse.contents = NSColor.red },
    ///     Material().configure { $0.diffuse.contents = NSColor.blue },
    ///     Material().configure { $0.diffuse.contents = NSColor.green }
    /// ]
    /// ```
    public var materials = [Material]() {
        didSet {
            gameObject?.node.geometry?.materials = self.materials
                .map { material -> SCNMaterial in material.scnMaterial }
        }
    }

    /// The primary material used by this renderer.
    ///
    /// This property provides convenient access to the first material in the ``materials`` array.
    /// Setting this property replaces all existing materials with a single material.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Assign a single material
    /// renderer.material = Material().configure { mat in
    ///     mat.diffuse.contents = NSColor.blue
    ///     mat.roughness.contents = 0.4
    /// }
    /// ```
    public var material: Material? {
        get {
            return self.materials.first
        }
        set {
            if let newMaterial = newValue {
                self.materials = [newMaterial]
            }
        }
    }

    /// A Boolean value that determines whether this object casts shadows.
    ///
    /// When `true`, the object will cast shadows from lights that have shadow casting enabled.
    /// Setting this to `false` improves performance for objects that don't need to cast shadows.
    ///
    /// **Default value:** Depends on the game object's configuration
    public var shadowCasting: Bool {
        get {
            guard let gameObject
            else { return false }

            return gameObject.node.castsShadow
        }
        set {
            gameObject?.node.castsShadow = newValue
        }
    }

    /// The rendering order within the sorting layer.
    ///
    /// Objects with lower values are rendered first. This is useful for controlling the draw order
    /// of transparent objects or ensuring specific rendering sequences.
    ///
    /// **Default value:** 0
    public var sortingOrder: Int {
        get {
            guard let gameObject
            else { return 0 }

            return gameObject.node.renderingOrder
        }
        set {
            gameObject?.node.renderingOrder = newValue
        }
    }

    /// Configures the renderer using a closure.
    ///
    /// This method provides a convenient way to configure multiple renderer properties
    /// in a single call using a configuration closure.
    ///
    /// - Parameter configurationBlock: A closure that receives the renderer instance for configuration.
    /// - Returns: The renderer instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let renderer = gameObject.addComponent(Renderer.self).configure { renderer in
    ///     renderer.material = Material()
    ///     renderer.shadowCasting = true
    ///     renderer.sortingOrder = 50
    /// }
    /// ```
    @discardableResult public func configure(_ configurationBlock: (Renderer) -> Void) -> Renderer {
        configurationBlock(self)
        return self
    }

    override public func awake() {}
}
