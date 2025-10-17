import SceneKit
import SpriteKit

/// A specialized GameObject that renders a 2D SpriteKit scene onto a 3D plane in the SceneKit world.
///
/// ``CanvasObject`` bridges 2D and 3D rendering by allowing you to display SpriteKit content
/// as a texture on a 3D plane. This enables you to create UI elements, 2D graphics, or particle
/// effects that exist within your 3D scene.
///
/// ## Overview
///
/// CanvasObject creates a plane geometry with an SKScene as its texture, allowing you to:
/// - Display 2D UI elements in 3D space
/// - Create HUD displays that exist as objects in the scene
/// - Mix SpriteKit animations with SceneKit 3D content
/// - Build interactive 2D interfaces that can be positioned and rotated in 3D
///
/// The canvas uses a pixel-per-unit system to control the resolution and size of the 2D content.
///
/// ## Example Usage
///
/// ```swift
/// // Create a canvas with specific world dimensions
/// let canvas = CanvasObject(worldSize: Size(width: 10, height: 5), pixelPerUnit: 100)
/// canvas.transform.position = Vector3(0, 5, -10)
/// scene.add(canvas)
///
/// // Access the underlying SpriteKit scene to add 2D content
/// let label = SKLabelNode(text: "Hello 3D World!")
/// label.position = CGPoint(x: 500, y: 250)
/// canvas.skScene.addChild(label)
///
/// // Get the pixel dimensions
/// let pixelSize = canvas.pixelSize()
/// print("Canvas is \(pixelSize.width)x\(pixelSize.height) pixels")
/// ```
///
/// ## Topics
///
/// ### Creating a Canvas
///
/// - ``init(worldSize:pixelPerUnit:)``
///
/// ### Configuring the Canvas
///
/// - ``set(worldSize:pixelPerUnit:)``
/// - ``pixelSize()``
///
/// ### Accessing SpriteKit Content
///
/// - ``skScene``
public class CanvasObject: GameObject {
    /// The underlying SpriteKit scene that contains the 2D content.
    ///
    /// Use this property to add, remove, or manipulate SpriteKit nodes on the canvas.
    /// The scene is rendered as a texture on the 3D plane geometry.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let canvas = CanvasObject(worldSize: Size(width: 5, height: 5))
    ///
    /// // Add a sprite to the canvas
    /// let sprite = SKSpriteNode(imageNamed: "icon")
    /// sprite.position = CGPoint(x: 125, y: 125)
    /// canvas.skScene.addChild(sprite)
    ///
    /// // Access scene properties
    /// canvas.skScene.backgroundColor = .blue
    /// ```
    var skScene: SKScene {
        guard let scene = node.geometry?.firstMaterial?.diffuse.contents as? SKScene else {
            fatalError("Should have a scene")
        }
        return scene
    }

    private var skView: SKView?

    /// Reconfigures the canvas with new dimensions and resolution.
    ///
    /// Use this method to change the canvas size or pixel density after creation. The canvas
    /// geometry will be regenerated with the new parameters.
    ///
    /// - Parameters:
    ///   - worldSize: The dimensions of the canvas in world units (SceneKit coordinates)
    ///   - pixelPerUnit: The number of pixels per world unit, controlling canvas resolution. Default is 1.
    /// - Returns: The canvas object for method chaining
    ///
    /// ## Example
    ///
    /// ```swift
    /// let canvas = CanvasObject(worldSize: Size(width: 5, height: 5))
    ///
    /// // Later, resize the canvas to be larger with higher resolution
    /// canvas.set(worldSize: Size(width: 10, height: 10), pixelPerUnit: 100)
    ///
    /// // Chain with other operations
    /// canvas.set(worldSize: Size(width: 8, height: 6))
    ///       .transform.position = Vector3(0, 0, -5)
    /// ```
    @discardableResult public func set(worldSize: Size, pixelPerUnit: Float = 1) -> CanvasObject {
        getComponent(UI.Canvas.self)?
            .configure {
                $0.worldSize = worldSize
                $0.pixelPerUnit = pixelPerUnit
            }
        let result = CanvasObject.makeCanvas(worldSize: worldSize, pixelPerUnit: pixelPerUnit)
        node = result.0
        self.skView = result.1
        self.pause()
        return self
    }

    /// Creates a new canvas object with specified dimensions and resolution.
    ///
    /// The canvas is created as a 3D plane with a SpriteKit scene rendered on it. The relationship
    /// between world size and pixel size is controlled by the `pixelPerUnit` parameter.
    ///
    /// - Parameters:
    ///   - worldSize: The dimensions of the canvas in world units (SceneKit coordinates)
    ///   - pixelPerUnit: The number of pixels per world unit, controlling canvas resolution. Default is 50.
    ///
    /// ## Calculating Dimensions
    ///
    /// The pixel size of the canvas is calculated as:
    /// ```
    /// pixelWidth = worldSize.width * pixelPerUnit
    /// pixelHeight = worldSize.height * pixelPerUnit
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a 10x10 world unit canvas with 100 pixels per unit
    /// // Resulting pixel size: 1000x1000
    /// let canvas = CanvasObject(worldSize: Size(width: 10, height: 10), pixelPerUnit: 100)
    ///
    /// // Create a lower resolution canvas
    /// let lowResCanvas = CanvasObject(worldSize: Size(width: 5, height: 5), pixelPerUnit: 32)
    ///
    /// // Add 2D content
    /// let label = SKLabelNode(text: "Hello!")
    /// canvas.skScene.addChild(label)
    /// ```
    public required init(worldSize: Size, pixelPerUnit: Float = 50) {
        let result = CanvasObject.makeCanvas(worldSize: worldSize, pixelPerUnit: pixelPerUnit)
        super.init(result.0)
        self.skView = result.1
        self.pause()
        addComponent(external: false, type: UI.Canvas.self, gameObject: self)
            .configure {
                $0.worldSize = worldSize
                $0.pixelPerUnit = pixelPerUnit
            }
    }

    /// Returns the pixel dimensions of the canvas.
    ///
    /// Use this method to get the actual pixel resolution of the SpriteKit scene.
    /// This is useful when positioning SpriteKit nodes or determining coordinate bounds.
    ///
    /// - Returns: The size in pixels (width and height) of the underlying SKScene
    ///
    /// ## Example
    ///
    /// ```swift
    /// let canvas = CanvasObject(worldSize: Size(width: 5, height: 5), pixelPerUnit: 100)
    ///
    /// let size = canvas.pixelSize()
    /// print("Canvas resolution: \(size.width)x\(size.height)")
    /// // Prints: "Canvas resolution: 500x500"
    ///
    /// // Position a sprite at the center
    /// let sprite = SKSpriteNode(imageNamed: "logo")
    /// sprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
    /// canvas.skScene.addChild(sprite)
    /// ```
    public func pixelSize() -> Size {
        return self.skScene.size.toSize()
    }

    public required init() {
        fatalError("init() has not been implemented, use init(size:)")
    }

    func pause() {
        self.skView?.isPaused = true
    }

    func resume() {
        self.skView?.isPaused = false
    }

    private static func makeCanvas(worldSize: Size, pixelPerUnit: Float) -> (SCNNode, SKView) {
        let geometry = SCNGeometry.createPrimitive(.plane(width: worldSize.width, height: worldSize.height))
        let node = SCNNode(geometry: geometry)
        node.name = "Canvas"
        node.castsShadow = false

        let view = SKView(frame: CGRect(origin: .zero, size: (worldSize * pixelPerUnit).toCGSize()))
        let skScene = SKScene(size: (worldSize * pixelPerUnit).toCGSize())
        view.presentScene(skScene)
        view.scene?.backgroundColor = .clear

        geometry.firstMaterial?.lightingModel = .constant
        geometry.firstMaterial?.diffuse.contents = view.scene
        geometry.firstMaterial?.isDoubleSided = true

        return (node, view)
    }
}
