
import SceneKit

public class MeshCollider: Collider {

    private var geometry: SCNGeometry?

    public func set(geometry: SCNGeometry) -> MeshCollider {
        
        self.geometry = geometry
        constructBody()
        return self
    }

    override func constructBody() {

        guard let gameObject = gameObject,
            let name = gameObject.name
            else { return }

        if let geometry = geometry {

            geometry.name = name + "PlaneCollider"

            updatePhysicsShape(SCNPhysicsShape(geometry: geometry))
            createVisibleCollider(geometry)

        } else {

            updatePhysicsShape()
        }
    }
}
