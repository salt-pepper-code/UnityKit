import Foundation
import SceneKit

/**
 A Camera is a device through which the player views the world.
 A world space point is defined in global coordinates (for example, Transform.position).
 */
public final class Camera: Component {
    override var order: ComponentOrder {
        .priority
    }

    private var hFieldOfView: CGFloat = 60

    public internal(set) var scnCamera = SCNCamera() {
        didSet {
            self.cullingMask = GameObject.Layer.all
            self.calculateFieldOfViews()
        }
    }

    /**
      Determines the receiver's field of view (in degree). Animatable.

      **Defaults to 60°.**
     */
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

    /**
     Determines the receiver's near value. Animatable.

     The near value determines the minimal distance between the camera and a visible surface. If a surface is closer to the camera than this minimal distance, then the surface is clipped. The near value must be different than zero.

     **Defaults to 1.**
     */
    public var zNear: Double {
        get {
            return self.scnCamera.zNear
        }
        set {
            self.scnCamera.zNear = newValue
        }
    }

    /**
     Determines the receiver's far value. Animatable.

     The far value determines the maximal distance between the camera and a visible surface. If a surface is further from the camera than this maximal distance, then the surface is clipped.

     **Defaults to 100.**
     */
    public var zFar: Double {
        get {
            return self.scnCamera.zFar
        }
        set {
            self.scnCamera.zFar = newValue
        }
    }

    /**
     Determines whether the receiver uses an orthographic projection or not.

     **Defaults to false.**
     */
    public var orthographic: Bool {
        get {
            return self.scnCamera.usesOrthographicProjection
        }
        set {
            self.scnCamera.usesOrthographicProjection = newValue
        }
    }

    /**
     Determines the receiver's orthographic scale value. Animatable.

     This setting determines the size of the camera's visible area. This is only enabled when usesOrthographicProjection is set to true.

     **Defaults to 1.**
     */
    public var orthographicSize: Double {
        get {
            return self.scnCamera.orthographicScale
        }
        set {
            self.scnCamera.orthographicScale = newValue
        }
    }

    /**
     Determines if the receiver has a high dynamic range.

     **Defaults to false.**
     */
    public var allowHDR: Bool {
        get {
            return self.scnCamera.wantsHDR
        }
        set {
            self.scnCamera.wantsHDR = newValue
        }
    }

    /**
     This is used to render parts of the scene selectively.

     - important: If the GameObject's layerMask AND the camera's cullingMask is zero then the game object will be invisible from this camera.
     See [Layer](GameObject/Layer.html) for more information.
     */
    public var cullingMask: GameObject.Layer {
        get {
            return GameObject.Layer(rawValue: self.scnCamera.categoryBitMask)
        }
        set {
            self.scnCamera.categoryBitMask = newValue.rawValue
            self.gameObject?.node.categoryBitMask = newValue.rawValue
        }
    }

    /**
     The game object this component is attached to. A component is always attached to a game object.
     */
    override public var gameObject: GameObject? {
        didSet {
            guard let node = gameObject?.node,
                  node.camera != scnCamera
            else { return }

            node.camera.map { self.scnCamera = $0 }
            self.calculateFieldOfViews()
        }
    }

    /**
     The game object that it's follows.
     */
    public private(set) var target: GameObject?

    /// Create a new instance
    public required init() {
        super.init()
        self.cullingMask = GameObject.Layer.all
        self.calculateFieldOfViews()
    }

    /**
      Configurable block that passes and returns itself.

      - parameters:
         - configurationBlock: block that passes itself.

      - returns: itself
     */
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

    /**
      The primary Camera in the Scene. Returns nil if there is no such camera in the Scene. This property uses GameObject.find(.tag(.mainCamera)) internally and doesn't cache the result.
      It is advised to cache the return value of Camera.main if it is used multiple times per frame.
      - parameters:
         - scene: Current scene.

      - returns: The first enabled camera tagged "MainCamera".
     */
    public static func main(in scene: Scene? = Scene.shared) -> Camera? {
        guard let scene
        else { return nil }

        return GameObject.find(.tag(.mainCamera), in: scene)?.getComponent(Camera.self)
    }

    /**
      Follow a target gameObject.
      - parameters:
         - target: Target gameObject to be followed
         - distanceRange: minimum distance and maximum distance. If nil will keep current distance as constraints.
     */
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

    /**
      Look at target gameObject.
      - parameters:
         - target: Target gameObject to be followed
         - duration: Duration of animation. If nil it will be instant.
     */
    public func lookAt(_ gameObject: GameObject, duration: TimeInterval? = nil) {
        self.lookAt(gameObject.transform, duration: duration)
    }

    /**
      Look at target transform.
      - parameters:
         - target: Target transform to be followed
         - duration: Duration of animation. If nil it will be instant.
     */
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

    /**
     * Converts a screen space point to a world space point
     * - Parameters:
     *   - screenPoint: The screen position (x, y) with z representing depth
     *   - renderer: The SCNSceneRenderer (typically an SCNView) rendering this camera's scene
     * - Returns: The world space position
     *
     * Note: The z component of screenPoint represents depth from camera.
     * Use z=0 for near plane, z=1 for far plane, or a specific world z coordinate.
     */
    public func ScreenToWorldPoint(_ screenPoint: Vector3, renderer: SCNSceneRenderer) -> Vector3? {
        // Convert screen point to SCNVector3
        let scnScreenPoint = SCNVector3(screenPoint.x, screenPoint.y, screenPoint.z)

        // Unproject from screen space to world space
        let worldPoint = renderer.unprojectPoint(scnScreenPoint)

        return Vector3(worldPoint.x, worldPoint.y, worldPoint.z)
    }

    /**
     * Converts a world space point to screen space
     * - Parameters:
     *   - worldPoint: The world space position
     *   - renderer: The SCNSceneRenderer (typically an SCNView) rendering this camera's scene
     * - Returns: The screen space position (x, y, z) where z is the depth
     */
    public func WorldToScreenPoint(_ worldPoint: Vector3, renderer: SCNSceneRenderer) -> Vector3? {
        guard let _ = gameObject?.node else { return nil }

        // Convert world point to SCNVector3
        let scnWorldPoint = SCNVector3(worldPoint.x, worldPoint.y, worldPoint.z)

        // Project from world space to screen space
        let screenPoint = renderer.projectPoint(scnWorldPoint)

        return Vector3(screenPoint.x, screenPoint.y, screenPoint.z)
    }

    /**
     * Converts a screen space point to a ray in world space
     * - Parameters:
     *   - screenPoint: The screen position (x, y)
     *   - renderer: The SCNSceneRenderer (typically an SCNView) rendering this camera's scene
     * - Returns: A tuple of (origin, direction) for the ray
     *
     * Useful for mouse picking and raycasting from screen coordinates
     */
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
