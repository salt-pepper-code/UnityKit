import SceneKit

/**
 A mesh collider allows you to do collision detection between meshes and primitives.
 */
public final class MeshCollider: Collider {
    public private(set) var mesh: Mesh?

    /**
     Configurable block that passes and returns itself.

     - parameters:
     - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (MeshCollider) -> Void) -> MeshCollider {
        configurationBlock(self)
        return self
    }

    /// <#Description#>
    ///
    /// - Parameter mesh: <#mesh description#>
    /// - Returns: <#return value description#>
    @discardableResult public func set(mesh: Mesh?) -> MeshCollider {
        self.mesh = mesh
        return self
    }

    /// <#Description#>
    override func constructBody() {
        guard let gameObject,
              let name = gameObject.name
        else { return }

        if let geometry = mesh?.geometry {
            geometry.name = name + "MeshCollider"

            let shape = SCNPhysicsShape(
                geometry: geometry,
                options: [
                    .type: SCNPhysicsShape.ShapeType.convexHull,
                    .scale: gameObject.transform.localScale.x,
                ]
            )
            physicsShape = shape
        }
    }
}
