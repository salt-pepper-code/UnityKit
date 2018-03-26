import Foundation
import SceneKit

public final class Renderer: Component {
    
    public var materials = [Material]() {
        
        didSet {
            gameObject?.node.geometry?.materials = materials.map { (material) -> SCNMaterial in material.scnMaterial }
        }
    }
    
    public var material: Material? {
        
        get {
            return materials.first
        }
        set {
            if let newMaterial = newValue {
                materials = [newMaterial]
            }
        }
    }
    
    public var shadowCasting: Bool {
        
        get {
            guard let gameObject = gameObject
                else { return false }

            return gameObject.node.castsShadow
        }
        set {
            gameObject?.node.castsShadow = newValue
        }
    }
    
    public var sortingOrder: Int {
        
        get {
            guard let gameObject = gameObject
                else { return 0 }

            return gameObject.node.renderingOrder
        }
        set {
            gameObject?.node.renderingOrder = newValue
        }
    }

    @discardableResult public func configure(_ completionBlock: (Renderer) -> ()) -> Renderer {

        completionBlock(self)
        return self
    }

    open override func awake() {

        if let scnMaterials = gameObject?.node.geometry?.materials {
            materials = scnMaterials.map { (scnMaterial) -> Material in Material(scnMaterial) }
        }
    }
}
