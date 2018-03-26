import Foundation
import SceneKit

public final class Transform: Component {
    
    public required init() {
        super.init()
    }
    
    public init(_ gameObject: GameObject) {
        
        super.init()
        self.gameObject = gameObject
    }

    public var forward: Vector3 {

        guard let node = gameObject?.node
            else { return .zero }

        return Vector3(node.simdWorldFront)
    }

    public var back: Vector3 {
        return forward.negated()
    }

    public var up: Vector3 {

        guard let node = gameObject?.node
            else { return .zero }

        return Vector3(node.simdWorldUp)
    }

    public var bottom: Vector3 {
        return up.negated()
    }

    public var right: Vector3 {

        guard let node = gameObject?.node
            else { return .zero }

        return Vector3(node.simdWorldRight)
    }

    public var left: Vector3 {
        return right.negated()
    }

    public var lossyScale: Vector3 {
        
        guard let parent = gameObject?.parent
            else { return localScale }
        
        return parent.transform.lossyScale * localScale
    }
    
    public var position: Vector3 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.physicsBody != nil ? node.presentation.worldPosition : node.worldPosition
        }
        set {
            guard let node = gameObject?.node
                else { return }

            node.worldPosition = newValue
        }
    }

    public var orientation: Quaternion {

        get {
            guard let node = gameObject?.node
                else { return .zero }

            return node.physicsBody != nil ? node.presentation.worldOrientation : node.worldOrientation
        }
        set {
            gameObject?.node.worldOrientation = newValue
        }
    }

    public var localOrientation: Quaternion {

        get {
            guard let node = gameObject?.node
                else { return .zero }

            return node.physicsBody != nil ? node.presentation.orientation : node.orientation
        }
        set {
            gameObject?.node.orientation = newValue
        }
    }

    public var localPosition: Vector3 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.physicsBody != nil ? node.presentation.position : node.position
        }
        set {
            gameObject?.node.position = newValue
        }
    }
    
    public var localRotation: Vector4 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.physicsBody != nil ? node.presentation.rotation : node.rotation
        }
        set {
            gameObject?.node.rotation = newValue
        }
    }
    
    public var localEulerAngles: Vector3 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.physicsBody != nil ? node.presentation.eulerAngles.radiansToDegrees() : node.eulerAngles.radiansToDegrees()
        }
        set {
            gameObject?.node.eulerAngles = newValue.degreesToRadians()
        }
    }
    
    public var localScale: Vector3 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.physicsBody != nil ? node.presentation.scale : node.scale
        }
        set {
            gameObject?.node.scale = newValue
        }
    }

    @available(iOS 11.0, *)
    public func lookAt(_ target: Transform) {

        if let constraints = gameObject?.node.constraints, constraints.count > 0 {
            print("remove constraints on node before using lookAt")
            return
        }

        gameObject?.node.look(at: target.position)
    }
}
