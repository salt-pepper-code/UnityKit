
import SceneKit

public final class MeshCollider: Collider {

    private(set) public var mesh: Mesh?

    @discardableResult public func configure(_ completionBlock: (MeshCollider) -> ()) -> MeshCollider {

        completionBlock(self)
        return self
    }
    
    @discardableResult public func set(mesh: Mesh?) -> MeshCollider {
        
        self.mesh = mesh
        return self
    }

    override func constructBody() {

        guard let gameObject = gameObject,
            let name = gameObject.name
            else { return }

        if let geometry = mesh?.geometry {

            geometry.name = name + "MeshCollider"

            let shape = SCNPhysicsShape(geometry: geometry,
                                        options: [.type: SCNPhysicsShape.ShapeType.convexHull,
                                                  .scale: gameObject.transform.localScale.x])
            physicsShape = shape
        }
    }
}
