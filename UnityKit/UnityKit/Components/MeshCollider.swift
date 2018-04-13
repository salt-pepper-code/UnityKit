import SceneKit

public final class MeshCollider: Collider {
    private(set) public var mesh: Mesh?

    public required init() {
        super.init()
        self.ignoreUpdates = true
    }

    /// <#Description#>
    ///
    /// - Parameter completionBlock: <#completionBlock description#>
    /// - Returns: <#return value description#>
    @discardableResult public func configure(_ completionBlock: (MeshCollider) -> Void) -> MeshCollider {

        completionBlock(self)
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
