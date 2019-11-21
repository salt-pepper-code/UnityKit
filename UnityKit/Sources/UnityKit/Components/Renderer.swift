import Foundation
import SceneKit

/**
General functionality for all renderers.
*/
public final class Renderer: Component {
    /**
    Returns all the instantiated materials of this object.
    */
    public var materials = [Material]() {
        didSet {
            gameObject?.node.geometry?.materials = materials.map { material -> SCNMaterial in material.scnMaterial }
        }
    }

    /**
    Returns the first instantiated Material assigned to the renderer.
    */
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

    /**
    Does this object cast shadows?
    */
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

    /**
    Renderer's order within a sorting layer.
    */
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

    /// Create a new instance
    public required init() {
        super.init()
        self.ignoreUpdates = true
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
        - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (Renderer) -> Void) -> Renderer {
        configurationBlock(self)
        return self
    }

    public override func awake() {
    }
}
