import Foundation
import SceneKit

public class Renderer: Component {
    
    public var materials = [Material]() {
        
        didSet {
            self.gameObject?.node.geometry?.materials = self.materials.map { (material) -> SCNMaterial in material.scnMaterial }
        }
    }
    
    public var material: Material? {
        
        get {
            return materials.first
        }
        set {
            if let newMaterial = newValue {
                self.materials = [newMaterial]
            }
        }
    }
    
    public var shadowCasting: Bool {
        
        get {
            guard let gameObject = self.gameObject
                else { return false }

            return gameObject.node.castsShadow
        }
        set {
            self.gameObject?.node.castsShadow = newValue
        }
    }
    
    public var sortingOrder: Int {
        
        get {
            guard let gameObject = self.gameObject
                else { return 0 }

            return gameObject.node.renderingOrder
        }
        set {
            self.gameObject?.node.renderingOrder = newValue
        }
    }
    
    open override func awake() {

        if let scnMaterials = self.gameObject?.node.geometry?.materials {
            self.materials = scnMaterials.map { (scnMaterial) -> Material in Material(scnMaterial) }
        }
    }
}
