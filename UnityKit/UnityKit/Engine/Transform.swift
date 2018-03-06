import Foundation
import SceneKit

public class Transform: Component {
    
    public required init() {
        super.init()
    }
    
    public init(_ gameObject: GameObject) {
        
        super.init()
        self.gameObject = gameObject
    }
    
    public var lossyScale: Vector3 {
        
        guard let parent = self.gameObject?.parent
            else { return self.localScale }
        
        return parent.transform.lossyScale * self.localScale
    }
    
    public var position: Vector3 {
        
        get {
            guard let node = self.gameObject?.node
                else { return .zero }
            
            if #available(iOS 11.0, *) {
                return node.worldPosition
            }
            
            if let parent = self.gameObject?.parent {
                return parent.transform.position + node.position
            }
            
            return node.position
        }
        set {
            guard let node = self.gameObject?.node, let parent = self.gameObject?.parent else {
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
            guard let node = self.gameObject?.node
                else { return .zero }
            
            return node.position
        }
        set {
            self.gameObject?.node.position = newValue
        }
    }
    
    public var localRotation: Quaternion {
        
        get {
            guard let node = self.gameObject?.node
                else { return Quaternion.zero }
            
            return node.rotation
        }
        set {
            self.gameObject?.node.rotation = newValue
        }
    }
    
    public var localEulerAngles: Vector3 {
        
        get {
            guard let node = self.gameObject?.node
                else { return .zero }
            
            return node.eulerAngles.radiansToDegrees()
        }
        set {
            self.gameObject?.node.eulerAngles = newValue.degreesToRadians()
        }
    }
    
    public var localScale: Vector3 {
        
        get {
            guard let node = self.gameObject?.node
                else { return .zero }
            
            return node.scale
        }
        set {
            self.gameObject?.node.scale = newValue
        }
    }
    
    public func lookAt(_ target: Transform) {
        
        guard target.position != self.position else {
            print ("position vectors are equal. No rotation needed")
            return
        }

        guard #available(iOS 11.0, *) else {
            print("lookAt needs ios 11")
            return
        }

        if let constraints = self.gameObject?.node.constraints, constraints.count > 0 {
            print("remove constraints on node before using lookAt")
            return
        }

        self.gameObject?.node.look(at: target.position)
    }
}
