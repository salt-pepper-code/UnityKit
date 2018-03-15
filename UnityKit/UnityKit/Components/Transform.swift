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

        if #available(iOS 11.0, *) {
            return Vector3(node.simdWorldFront)
        }
        return Vector3(node.worldTransform.m31, node.worldTransform.m32, node.worldTransform.m33)
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
            
            if #available(iOS 11.0, *) {
                return node.worldPosition
            }
            
            if let parent = gameObject?.parent {
                return parent.transform.position + node.position
            }
            
            return node.position
        }
        set {
            guard let node = gameObject?._node, let parent = gameObject?.parent else {
                print("Object need to have a parent before setting a position")
                return
            }
                
            if #available(iOS 11.0, *) {
                node.worldPosition = newValue
            } else {
                node.position = newValue - parent.transform.position
            }
        }
    }
    
    public var localPosition: Vector3 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.position
        }
        set {
            gameObject?.node.position = newValue
        }
    }
    
    public var localRotation: Quaternion {
        
        get {
            guard let node = gameObject?.node
                else { return Quaternion.zero }
            
            return node.rotation
        }
        set {
            gameObject?.node.rotation = newValue
        }
    }
    
    public var localEulerAngles: Vector3 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.eulerAngles.radiansToDegrees()
        }
        set {
            gameObject?.node.eulerAngles = newValue.degreesToRadians()
        }
    }
    
    public var localScale: Vector3 {
        
        get {
            guard let node = gameObject?.node
                else { return .zero }
            
            return node.scale
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
