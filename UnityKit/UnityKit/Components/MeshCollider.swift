
import SceneKit

public final class MeshCollider: Collider {

    private var mesh: Mesh?

    public func set(mesh: Mesh?) -> MeshCollider {
        
        self.mesh = mesh
        constructBody()
        gameObject?.updatePhysicsShape()
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
