import Foundation
import SceneKit

/// A camera component that controls how the scene is rendered to the display.
///
/// The `Camera` component is responsible for rendering the 3D scene from a specific viewpoint.
/// It defines the viewing frustum, projection parameters, and culling behavior. A camera can use
/// either perspective or orthographic projection and supports both HDR rendering and selective
/// layer-based rendering through culling masks.
///
/// ## Overview
///
/// Cameras are essential components in any 3D scene, as they determine what the viewer sees.
/// Each camera maintains its own projection settings, clipping planes, and can be configured
/// to follow or look at specific game objects in the scene.
///
/// ## Topics
///
/// ### Creating a Camera
///
/// - ``init()``
/// - ``configure(_:)``
///
/// ### Projection Settings
///
/// - ``fieldOfView``
/// - ``orthographic``
/// - ``orthographicSize``
/// - ``zNear``
/// - ``zFar``
///
/// ### Rendering Configuration
///
/// - ``allowHDR``
/// - ``cullingMask``
///
/// ### Camera Targeting
///
/// - ``target``
/// - ``followTarget(target:distanceRange:)``
/// - ``lookAt(_:duration:)-5s6c9``
/// - ``lookAt(_:duration:)-2ew3y``
///
/// ### Coordinate Conversion
///
/// - ``ScreenToWorldPoint(_:renderer:)``
/// - ``WorldToScreenPoint(_:renderer:)``
/// - ``ScreenPointToRay(_:renderer:)``
///
/// ### Finding Cameras
///
/// - ``main(in:)``
///
/// ### SceneKit Integration
///
/// - ``scnCamera``
///
/// ## Example Usage
///
/// ```swift
/// // Create a perspective camera
/// let camera = gameObject.addComponent(Camera.self)
/// camera.fieldOfView = 75
/// camera.zNear = 0.1
/// camera.zFar = 1000
///
/// // Enable HDR rendering
/// camera.allowHDR = true
///
/// // Set up camera to follow a target
/// if let player = GameObject.find(.tag(.player), in: scene) {
///     camera.followTarget(target: player, distanceRange: (5.0, 10.0))
/// }
///
/// // Convert screen coordinates to world space
/// if let worldPos = camera.ScreenToWorldPoint(
///     Vector3(screenX, screenY, 10),
///     renderer: sceneView
/// ) {
///     print("World position: \(worldPos)")
/// }
/// ```
public final class Camera: Component {
    override var order: ComponentOrder {
        .priority
    }

    private var hFieldOfView: CGFloat = 60

    /// The underlying SceneKit camera object used for rendering.
    ///
    /// This property provides direct access to the `SCNCamera` instance that handles
    /// the actual rendering. Modifying this property updates the culling mask and
    /// recalculates field of view settings.
    public internal(set) var scnCamera = SCNCamera() {
        didSet {
            self.cullingMask = GameObject.Layer.all
            self.calculateFieldOfViews()
        }
    }

    /// The camera's field of view in degrees.
    ///
    /// This property determines the vertical angle of the camera's view frustum when using
    /// perspective projection. A larger field of view creates a wider viewing angle.
    /// This property only applies when ``orthographic`` is `true`.
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    /// - Returns: The field of view angle in degrees, or `0` if using orthographic projection.
    ///
    /// **Default value:** 60 degrees
    public var fieldOfView: CGFloat {
        get {
            guard self.orthographic
            else { return 0 }

            return self.scnCamera.fieldOfView
        }
        set {
            self.hFieldOfView = newValue

            guard self.orthographic
            else { return }

            self.scnCamera.fieldOfView = newValue
            self.scnCamera.projectionDirection = .horizontal
        }
    }

    /// The distance to the near clipping plane.
    ///
    /// This property determines the minimum distance from the camera at which objects are rendered.
    /// Any geometry closer to the camera than this distance will be clipped and not rendered.
    /// The value must be greater than zero.
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** 1.0
    public var zNear: Double {
        get {
            return self.scnCamera.zNear
        }
        set {
            self.scnCamera.zNear = newValue
        }
    }

    /// The distance to the far clipping plane.
    ///
    /// This property determines the maximum distance from the camera at which objects are rendered.
    /// Any geometry farther from the camera than this distance will be clipped and not rendered.
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** 100.0
    public var zFar: Double {
        get {
            return self.scnCamera.zFar
        }
        set {
            self.scnCamera.zFar = newValue
        }
    }

    /// A Boolean value that determines whether the camera uses orthographic projection.
    ///
    /// When `true`, the camera uses orthographic projection where objects maintain their size
    /// regardless of distance from the camera. When `false`, the camera uses perspective
    /// projection where distant objects appear smaller.
    ///
    /// **Default value:** `false` (perspective projection)
    public var orthographic: Bool {
        get {
            return self.scnCamera.usesOrthographicProjection
        }
        set {
            self.scnCamera.usesOrthographicProjection = newValue
        }
    }

    /// The orthographic projection scale value.
    ///
    /// This property determines the size of the camera's visible area when using orthographic
    /// projection. Higher values show a larger area of the scene. This property only has an
    /// effect when ``orthographic`` is set to `true`.
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** 1.0
    public var orthographicSize: Double {
        get {
            return self.scnCamera.orthographicScale
        }
        set {
            self.scnCamera.orthographicScale = newValue
        }
    }

    /// A Boolean value that determines whether the camera renders with high dynamic range (HDR).
    ///
    /// When enabled, the camera can render scenes with a wider range of luminance values,
    /// providing more realistic lighting and better color precision. This is particularly
    /// useful for scenes with bright lights and dark shadows.
    ///
    /// **Default value:** `false`
    public var allowHDR: Bool {
        get {
            return self.scnCamera.wantsHDR
        }
        set {
            self.scnCamera.wantsHDR = newValue
        }
    }

    /// The layer mask used for selective rendering of game objects.
    ///
    /// This property controls which game objects are visible to the camera based on their layer.
    /// Only objects whose layer matches the culling mask will be rendered by this camera.
    ///
    /// - Important: A game object will be invisible to this camera if the bitwise AND of the
    ///   object's layer mask and the camera's culling mask equals zero.
    ///
    /// See ``GameObject/Layer`` for more information about layers.
    public var cullingMask: GameObject.Layer {
        get {
            return GameObject.Layer(rawValue: self.scnCamera.categoryBitMask)
        }
        set {
            self.scnCamera.categoryBitMask = newValue.rawValue
            self.gameObject?.node.categoryBitMask = newValue.rawValue
        }
    }

    /// The game object this component is attached to.
    ///
    /// A component is always attached to a game object. When set, this property synchronizes
    /// the camera with the game object's SceneKit node and recalculates field of view settings.
    override public var gameObject: GameObject? {
        didSet {
            guard let node = gameObject?.node,
                  node.camera != scnCamera
            else { return }

            node.camera.map { self.scnCamera = $0 }
            self.calculateFieldOfViews()
        }
    }

    /// The game object that this camera is currently following.
    ///
    /// This property is set automatically when ``followTarget(target:distanceRange:)`` is called.
    /// It maintains a reference to the target game object for constraint-based following.
    public private(set) var target: GameObject?

    /// Creates a new camera component.
    ///
    /// The camera is initialized with default settings including a culling mask set to all layers
    /// and field of view calculations applied.
    public required init() {
        super.init()
        self.cullingMask = GameObject.Layer.all
        self.calculateFieldOfViews()
    }

    /// Configures the camera using a closure.
    ///
    /// This method provides a convenient way to configure multiple camera properties
    /// in a single call using a configuration closure.
    ///
    /// - Parameter configurationBlock: A closure that receives the camera instance for configuration.
    /// - Returns: The camera instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let camera = gameObject.addComponent(Camera.self).configure { camera in
    ///     camera.fieldOfView = 75
    ///     camera.zNear = 0.1
    ///     camera.zFar = 1000
    ///     camera.allowHDR = true
    /// }
    /// ```
    @discardableResult public func configure(_ configurationBlock: (Camera) -> Void) -> Camera {
        configurationBlock(self)
        return self
    }

    override public func awake() {
        guard let node = gameObject?.node,
              node.camera == nil
        else { return }

        node.camera = self.scnCamera
    }

    func calculateFieldOfViews() {
        self.fieldOfView = self.hFieldOfView
    }

    /// Returns the primary camera in the scene.
    ///
    /// This method searches for the first enabled camera tagged with "MainCamera" in the specified scene.
    /// The result is not cached, so it's recommended to store the return value if you need to access
    /// the main camera multiple times per frame.
    ///
    /// - Parameter scene: The scene to search in. Defaults to ``Scene/shared``.
    /// - Returns: The first enabled camera tagged "MainCamera", or `nil` if no such camera exists.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Get the main camera
    /// if let mainCamera = Camera.main(in: scene) {
    ///     mainCamera.fieldOfView = 90
    /// }
    ///
    /// // Cache for multiple accesses
    /// guard let mainCamera = Camera.main(in: scene) else { return }
    /// // Use mainCamera multiple times...
    /// ```
    public static func main(in scene: Scene? = Scene.shared) -> Camera? {
        guard let scene
        else { return nil }

        return GameObject.find(.tag(.mainCamera), in: scene)?.getComponent(Camera.self)
    }

    /// Configures the camera to follow a target game object.
    ///
    /// This method sets up SceneKit constraints to make the camera continuously look at and
    /// optionally maintain a specific distance range from the target game object.
    ///
    /// - Parameters:
    ///   - target: The game object to follow. Pass `nil` to clear the current target.
    ///   - distanceRange: An optional tuple specifying the minimum and maximum distance from the target.
    ///     If `nil`, the camera maintains its current distance.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Follow a player character with distance constraints
    /// if let player = GameObject.find(.tag(.player), in: scene) {
    ///     camera.followTarget(target: player, distanceRange: (5.0, 15.0))
    /// }
    ///
    /// // Follow without distance constraints
    /// camera.followTarget(target: targetObject)
    /// ```
    public func followTarget(target: GameObject?, distanceRange: (minimum: Float, maximum: Float)? = nil) {
        self.target = target

        guard let target,
              let gameObject
        else { return }

        let targetConstraint = SCNLookAtConstraint(target: target.node)
        targetConstraint.isGimbalLockEnabled = true

        guard let distanceRange else {
            gameObject.node.constraints = [targetConstraint]
            return
        }

        let constraint = self.distanceConstraint(gameObject: gameObject, target: target, distanceRange: distanceRange)
        gameObject.node.constraints = [targetConstraint, constraint]
    }

    private func distanceConstraint(
        gameObject: GameObject,
        target: GameObject,
        distanceRange: (minimum: Float, maximum: Float)
    ) -> SCNConstraint {
        let distanceConstraint = SCNDistanceConstraint(target: target.node)
        distanceConstraint.minimumDistance = CGFloat(distanceRange.minimum)
        distanceConstraint.maximumDistance = CGFloat(distanceRange.maximum)
        return distanceConstraint
    }

    /// Rotates the camera to look at a target game object.
    ///
    /// This method orients the camera to face the specified game object. The rotation can be
    /// applied instantly or animated over a specified duration.
    ///
    /// - Parameters:
    ///   - gameObject: The game object to look at.
    ///   - duration: The animation duration in seconds. If `nil`, the rotation is applied instantly.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Instantly look at target
    /// camera.lookAt(targetObject)
    ///
    /// // Smoothly look at target over 2 seconds
    /// camera.lookAt(targetObject, duration: 2.0)
    /// ```
    public func lookAt(_ gameObject: GameObject, duration: TimeInterval? = nil) {
        self.lookAt(gameObject.transform, duration: duration)
    }

    /// Rotates the camera to look at a target transform.
    ///
    /// This method orients the camera to face the specified transform's position. The rotation
    /// can be applied instantly or animated over a specified duration.
    ///
    /// - Parameters:
    ///   - target: The transform to look at.
    ///   - duration: The animation duration in seconds. If `nil`, the rotation is applied instantly.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Instantly look at a position
    /// camera.lookAt(targetTransform)
    ///
    /// // Smoothly pan to look at position over 1.5 seconds
    /// camera.lookAt(targetTransform, duration: 1.5)
    /// ```
    public func lookAt(_ target: Transform, duration: TimeInterval? = nil) {
        self.gameObject?.node.constraints = nil
        guard let duration else {
            transform?.lookAt(target)
            return
        }
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transform?.lookAt(target)
        SCNTransaction.commit()
    }

    // MARK: - Screen/World Coordinate Conversion

    /// Converts a screen space point to a world space point.
    ///
    /// This method transforms a 2D screen coordinate into a 3D world coordinate using the
    /// camera's projection settings. The z component of the screen point determines the depth
    /// at which the world point is calculated.
    ///
    /// - Parameters:
    ///   - screenPoint: The screen position with x and y in screen coordinates. The z component
    ///     represents depth (0 for near plane, 1 for far plane).
    ///   - renderer: The scene renderer (typically `SCNView`) that is rendering this camera's scene.
    /// - Returns: The corresponding world space position, or `nil` if the conversion fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Convert a screen tap to a world position at depth 10
    /// let screenPoint = Vector3(tapLocation.x, tapLocation.y, 10)
    /// if let worldPos = camera.ScreenToWorldPoint(screenPoint, renderer: sceneView) {
    ///     print("World position: \(worldPos)")
    /// }
    /// ```
    public func ScreenToWorldPoint(_ screenPoint: Vector3, renderer: SCNSceneRenderer) -> Vector3? {
        // Convert screen point to SCNVector3
        let scnScreenPoint = SCNVector3(screenPoint.x, screenPoint.y, screenPoint.z)

        // Unproject from screen space to world space
        let worldPoint = renderer.unprojectPoint(scnScreenPoint)

        return Vector3(worldPoint.x, worldPoint.y, worldPoint.z)
    }

    /// Converts a world space point to screen space.
    ///
    /// This method transforms a 3D world coordinate into a 2D screen coordinate using the
    /// camera's projection settings. The resulting z component represents the depth of the point.
    ///
    /// - Parameters:
    ///   - worldPoint: The world space position to convert.
    ///   - renderer: The scene renderer (typically `SCNView`) that is rendering this camera's scene.
    /// - Returns: The screen space position where x and y are screen coordinates and z is the depth,
    ///   or `nil` if the camera has no associated game object.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Convert a game object's world position to screen coordinates
    /// if let screenPos = camera.WorldToScreenPoint(
    ///     targetObject.transform.position,
    ///     renderer: sceneView
    /// ) {
    ///     print("Screen position: (\(screenPos.x), \(screenPos.y))")
    /// }
    /// ```
    public func WorldToScreenPoint(_ worldPoint: Vector3, renderer: SCNSceneRenderer) -> Vector3? {
        guard let _ = gameObject?.node else { return nil }

        // Convert world point to SCNVector3
        let scnWorldPoint = SCNVector3(worldPoint.x, worldPoint.y, worldPoint.z)

        // Project from world space to screen space
        let screenPoint = renderer.projectPoint(scnWorldPoint)

        return Vector3(screenPoint.x, screenPoint.y, screenPoint.z)
    }

    /// Converts a screen space point to a ray in world space.
    ///
    /// This method generates a ray starting from the camera's near plane and extending through
    /// the specified screen coordinate into world space. This is useful for raycasting operations
    /// such as mouse picking or touch-based object selection.
    ///
    /// - Parameters:
    ///   - screenPoint: The screen position as a 2D coordinate.
    ///   - renderer: The scene renderer (typically `SCNView`) that is rendering this camera's scene.
    /// - Returns: A tuple containing the ray's origin point and normalized direction vector in world space,
    ///   or `nil` if the conversion fails.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Cast a ray from a touch point to detect objects
    /// let touchPoint = Vector2(tapLocation.x, tapLocation.y)
    /// if let ray = camera.ScreenPointToRay(touchPoint, renderer: sceneView) {
    ///     // Use ray.origin and ray.direction for hit testing
    ///     let hitResults = scene.raycast(origin: ray.origin, direction: ray.direction)
    ///     if let firstHit = hitResults.first {
    ///         print("Hit object at: \(firstHit.worldCoordinates)")
    ///     }
    /// }
    /// ```
    public func ScreenPointToRay(
        _ screenPoint: Vector2,
        renderer: SCNSceneRenderer
    ) -> (origin: Vector3, direction: Vector3)? {
        // Get points at near and far plane
        guard let nearPoint = ScreenToWorldPoint(Vector3(screenPoint.x, screenPoint.y, 0), renderer: renderer),
              let farPoint = ScreenToWorldPoint(Vector3(screenPoint.x, screenPoint.y, 1), renderer: renderer)
        else { return nil }

        let direction = (farPoint - nearPoint).normalized()

        return (origin: nearPoint, direction: direction)
    }
}
