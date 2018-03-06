import Foundation
import SceneKit

public class Camera: Behaviour {
    
    private var hFieldOfView: CGFloat = 60
    
    private(set) public var scnCamera: SCNCamera
    
    /*!
     @property fieldOfView
     @abstract Determines the receiver's field of view (in degree). Animatable.
     @discussion defaults to 60°.
     */
    public var fieldOfView: CGFloat {
        
        get {
            if #available(iOS 11.0, *) {
                return self.scnCamera.fieldOfView
            }
            return CGFloat(self.scnCamera.xFov)
        }
        set {
            self.hFieldOfView = newValue
            
            if #available(iOS 11.0, *) {
                
                self.scnCamera.fieldOfView = newValue
                self.scnCamera.projectionDirection = .horizontal
            }

            let screenPlaneDistance = (Screen.width.toDouble() / 2.0) / tan(newValue.toDouble().degreesToRadians / 2.0)

            self.scnCamera.xFov = newValue.toDouble()
            self.scnCamera.yFov = (atan((Screen.height.toDouble() / 2.0) / screenPlaneDistance) * 2.0).radiansToDegrees
        }
    }
    
    /*!
     @property zNear
     @abstract Determines the receiver's near value. Animatable.
     @discussion The near value determines the minimal distance between the camera and a visible surface. If a surface is closer to the camera than this minimal distance, then the surface is clipped. The near value must be different than zero. Defaults to 1.
     */
    public var zNear: Double {
        
        get {
            return self.scnCamera.zNear
        }
        set {
            self.scnCamera.zNear = newValue
        }
    }
    
    /*!
     @property zFar
     @abstract Determines the receiver's far value. Animatable.
     @discussion The far value determines the maximal distance between the camera and a visible surface. If a surface is further from the camera than this maximal distance, then the surface is clipped. Defaults to 100.
     */
    public var zFar: Double {
        
        get {
            return self.scnCamera.zFar
        }
        set {
            self.scnCamera.zFar = newValue
        }
    }
    
    /*!
     @property orthographic
     @abstract Determines whether the receiver uses an orthographic projection or not. Defaults to NO.
     */
    public var orthographic: Bool {
        
        get {
            return self.scnCamera.usesOrthographicProjection
        }
        set {
            self.scnCamera.usesOrthographicProjection = newValue
        }
    }

    
    /*!
     @property orthographicSize
     @abstract Determines the receiver's orthographic scale value. Animatable. Defaults to 1.
     @discussion This setting determines the size of the camera's visible area. This is only enabled when usesOrthographicProjection is set to YES.
     */
    public var orthographicSize: Double {
        
        get {
            return self.scnCamera.orthographicScale
        }
        set {
            self.scnCamera.orthographicScale = newValue
        }
    }
    
    /*!
     @property allowHDR
     @abstract Determines if the receiver has a high dynamic range. Defaults to NO.
     */
    open var allowHDR: Bool {
        
        get {
            if #available(iOS 10.0, *) {
                return self.scnCamera.wantsHDR
            }
            return false
        }
        set {
            if #available(iOS 10.0, *) {
                self.scnCamera.wantsHDR = newValue
            }
        }
    }

    public override var gameObject: GameObject? {

        didSet {
            guard let node = self.gameObject?.node
                else { return }

            if let scnCamera = node.camera {
                self.scnCamera = scnCamera
                return
            }

            let scnCamera = SCNCamera()
            node.camera = scnCamera

            if var rootParent = self.gameObject?.parent {

                while rootParent.parent != nil {
                    rootParent = rootParent.parent!
                }

                self.target = rootParent
            }

            self.scnCamera = scnCamera
            self.calculateFieldOfViews()
        }
    }
    
    private(set) public var target: GameObject?
    
    public required init() {
        
        self.scnCamera = SCNCamera()
        super.init()
        self.calculateFieldOfViews()
    }
    
    public func calculateFieldOfViews() {
        self.fieldOfView = self.hFieldOfView
    }
    
    public static func main(_ inScene: Scene) -> Camera? {
        return GameObject.find(.tag(GameObject.Tags.mainCamera.rawValue), inScene: inScene)?.getComponent(Camera.self)
    }
    
    public class Constraints {
        
        fileprivate(set) public var target: GameObject?
    }
    
    public func followTarget(target: GameObject?, distanceRange: (minimum: Float, maximum: Float)? = nil) {
        
        self.target = target
        
        self.gameObject?.node.constraints = nil
        
        if let target = self.target {
            
            let targetConstraint = SCNLookAtConstraint(target: target.node)
            targetConstraint.isGimbalLockEnabled = true
            
            var constraints = [SCNConstraint]()
            
            constraints.append(targetConstraint)
            
            if let distanceRange = distanceRange, let gameObject = self.gameObject {

                let distanceConstraint = SCNTransformConstraint(inWorldSpace: true) { (node, transform) -> SCNMatrix4 in
                    
                    let distance = Vector3.distance(target.transform.position, gameObject.transform.position)
                    
                    let normalizedDistance: Float
                    
                    switch distance {
                    case ...distanceRange.minimum:
                        normalizedDistance = normalize(distanceRange.minimum, in: 0 ... distance)
                    case distanceRange.maximum...:
                        normalizedDistance = normalize(distanceRange.maximum, in: 0 ... distance)
                    default:
                        return transform
                    }
                    
                    gameObject.transform.position.x = interpolate(from: target.transform.position.x, to: gameObject.transform.position.x, alpha: normalizedDistance)
                    gameObject.transform.position.y = target.transform.position.y
                    gameObject.transform.position.z = interpolate(from: target.transform.position.z, to: gameObject.transform.position.z, alpha: normalizedDistance)
                    
                    return transform
                }
                
                constraints.append(distanceConstraint)
            }
            
            self.gameObject?.node.constraints = constraints
        }
    }
    
    public func lookAt(_ gameObject: GameObject) {
        
        self.lookAt(gameObject.transform)
    }
    
    public func lookAt(_ target: Transform) {
        
        self.followTarget(target: nil)
        self.transform?.lookAt(target)
    }
}
