import Foundation
import SceneKit

/**
 A Camera is a device through which the player views the world.
 A world space point is defined in global coordinates (for example, Transform.position).
 */
public final class Camera: Component {
    private var hFieldOfView: CGFloat = 60

    internal(set) public var scnCamera = SCNCamera() {
        didSet {
            cullingMask = GameObject.Layer.all
            calculateFieldOfViews()
        }
    }

    /**
     Determines the receiver's field of view (in degree). Animatable.

     **Defaults to 60°.**
    */
    public var fieldOfView: CGFloat {
        get {
            guard orthographic
                else { return 0 }

            return scnCamera.fieldOfView
        }
        set {
            hFieldOfView = newValue

            guard orthographic
                else { return }

            scnCamera.fieldOfView = newValue
            scnCamera.projectionDirection = .horizontal
        }
    }

    /**
     Determines the receiver's near value. Animatable.

     The near value determines the minimal distance between the camera and a visible surface. If a surface is closer to the camera than this minimal distance, then the surface is clipped. The near value must be different than zero.

     **Defaults to 1.**
     */
    public var zNear: Double {
        get {
            return scnCamera.zNear
        }
        set {
            scnCamera.zNear = newValue
        }
    }

    /**
     Determines the receiver's far value. Animatable.

     The far value determines the maximal distance between the camera and a visible surface. If a surface is further from the camera than this maximal distance, then the surface is clipped.

     **Defaults to 100.**
     */
    public var zFar: Double {
        get {
            return scnCamera.zFar
        }
        set {
            scnCamera.zFar = newValue
        }
    }

    /**
     Determines whether the receiver uses an orthographic projection or not.

     **Defaults to false.**
     */
    public var orthographic: Bool {
        get {
            return scnCamera.usesOrthographicProjection
        }
        set {
            scnCamera.usesOrthographicProjection = newValue
        }
    }

    /**
     Determines the receiver's orthographic scale value. Animatable.

     This setting determines the size of the camera's visible area. This is only enabled when usesOrthographicProjection is set to true.

     **Defaults to 1.**
     */
    public var orthographicSize: Double {
        get {
            return scnCamera.orthographicScale
        }
        set {
            scnCamera.orthographicScale = newValue
        }
    }

    /**
     Determines if the receiver has a high dynamic range.

     **Defaults to false.**
     */
    public var allowHDR: Bool {
        get {
            if #available(iOS 10.0, *) {
                return scnCamera.wantsHDR
            }
            return false
        }
        set {
            if #available(iOS 10.0, *) {
                scnCamera.wantsHDR = newValue
            }
        }
    }

    /**
     This is used to render parts of the scene selectively.

     - important: If the GameObject's layerMask AND the camera's cullingMask is zero then the game object will be invisible from this camera.
     See [Layer](GameObject/Layer.html) for more information.
     */
    public var cullingMask: GameObject.Layer {
        get {
            return GameObject.Layer(rawValue: scnCamera.categoryBitMask)
        }
        set {
            scnCamera.categoryBitMask = newValue.rawValue
            gameObject?.node.categoryBitMask = newValue.rawValue
        }
    }

    /**
     The game object this component is attached to. A component is always attached to a game object.
     */
    public override var gameObject: GameObject? {
        didSet {
            guard let node = gameObject?.node,
                node.camera != scnCamera
                else { return }

            node.camera.map { scnCamera = $0 }
            calculateFieldOfViews()
        }
    }

    /**
     The game object that it's follows.
     */
    private(set) public var target: GameObject?

    /// Create a new instance
    public required init() {
        super.init()
        self.ignoreUpdates = true
        self.cullingMask = GameObject.Layer.all
        calculateFieldOfViews()
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

    public override func awake() {
        guard let node = gameObject?.node,
            node.camera == nil
            else { return }

        node.camera = scnCamera
    }

    internal func calculateFieldOfViews() {
        fieldOfView = hFieldOfView
    }

    /**
     The primary Camera in the Scene. Returns nil if there is no such camera in the Scene. This property uses GameObject.find(.tag(.mainCamera)) internally and doesn't cache the result.
     It is advised to cache the return value of Camera.main if it is used multiple times per frame.
     - parameters:
        - scene: Current scene.

     - returns: The first enabled camera tagged "MainCamera".
    */
    public static func main(in scene: Scene? = Scene.sharedInstance) -> Camera? {
        guard let scene = scene
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

        guard let target = target,
            let gameObject = gameObject
            else { return }

        let targetConstraint = SCNLookAtConstraint(target: target.node)
        targetConstraint.isGimbalLockEnabled = true

        guard let distanceRange = distanceRange else {
            gameObject.node.constraints = [targetConstraint]
            return
        }

        let constraint = distanceConstraint(gameObject: gameObject, target: target, distanceRange: distanceRange)
        gameObject.node.constraints = [targetConstraint, constraint]
    }

    private func distanceConstraint(gameObject: GameObject, target: GameObject, distanceRange: (minimum: Float, maximum: Float)) -> SCNConstraint {
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
        lookAt(gameObject.transform, duration: duration)
    }

    /**
     Look at target transform.
     - parameters:
        - target: Target transform to be followed
        - duration: Duration of animation. If nil it will be instant.
    */
    public func lookAt(_ target: Transform, duration: TimeInterval? = nil) {
        gameObject?.node.constraints = nil
        guard let duration = duration else {
            transform?.lookAt(target)
            return
        }
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transform?.lookAt(target)
        SCNTransaction.commit()
    }
}
