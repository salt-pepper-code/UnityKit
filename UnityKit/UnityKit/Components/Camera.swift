import Foundation
import SceneKit

public final class Camera: Component {
    private var hFieldOfView: CGFloat = 60

    internal(set) public var scnCamera = SCNCamera() {
        didSet {
            cullingMask = GameObject.Layer.all
            calculateFieldOfViews()
        }
    }

    /*!
     @property fieldOfView
     @abstract Determines the receiver's field of view (in degree). Animatable.
     @discussion defaults to 60°.
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

    /*!
     @property zNear
     @abstract Determines the receiver's near value. Animatable.
     @discussion The near value determines the minimal distance between the camera and a visible surface. If a surface is closer to the camera than this minimal distance, then the surface is clipped. The near value must be different than zero. Defaults to 1.
     */
    public var zNear: Double {
        get {
            return scnCamera.zNear
        }
        set {
            scnCamera.zNear = newValue
        }
    }

    /*!
     @property zFar
     @abstract Determines the receiver's far value. Animatable.
     @discussion The far value determines the maximal distance between the camera and a visible surface. If a surface is further from the camera than this maximal distance, then the surface is clipped. Defaults to 100.
     */
    public var zFar: Double {
        get {
            return scnCamera.zFar
        }
        set {
            scnCamera.zFar = newValue
        }
    }

    /*!
     @property orthographic
     @abstract Determines whether the receiver uses an orthographic projection or not. Defaults to NO.
     */
    public var orthographic: Bool {
        get {
            return scnCamera.usesOrthographicProjection
        }
        set {
            scnCamera.usesOrthographicProjection = newValue
        }
    }

    /*!
     @property orthographicSize
     @abstract Determines the receiver's orthographic scale value. Animatable. Defaults to 1.
     @discussion This setting determines the size of the camera's visible area. This is only enabled when usesOrthographicProjection is set to YES.
     */
    public var orthographicSize: Double {
        get {
            return scnCamera.orthographicScale
        }
        set {
            scnCamera.orthographicScale = newValue
        }
    }

    /*!
     @property allowHDR
     @abstract Determines if the receiver has a high dynamic range. Defaults to NO.
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

    /*!
     @property cullingMask
     @abstract This is used to render parts of the scene selectively.
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

    public override var gameObject: GameObject? {
        didSet {
            guard let node = gameObject?.node,
                node.camera != scnCamera
                else { return }

            node.camera.map { scnCamera = $0 }
            calculateFieldOfViews()
        }
    }

    private(set) public var target: GameObject?

    public required init() {
        super.init()
        self.ignoreUpdates = true
        self.cullingMask = GameObject.Layer.all
        calculateFieldOfViews()
    }

    @discardableResult public func configure(_ completionBlock: (Camera) -> Void) -> Camera {
        completionBlock(self)
        return self
    }

    public override func awake() {
        guard let node = gameObject?.node,
            node.camera == nil
            else { return }

        node.camera = scnCamera
    }

    public func calculateFieldOfViews() {
        fieldOfView = hFieldOfView
    }

    public static func main(in scene: Scene? = Scene.sharedInstance) -> Camera? {
        guard let scene = scene
            else { return nil }

        return GameObject.find(.tag(.mainCamera), in: scene)?.getComponent(Camera.self)
    }

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

    public func lookAt(_ gameObject: GameObject, duration: TimeInterval = 1) {
        lookAt(gameObject.transform, duration: duration)
    }

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
