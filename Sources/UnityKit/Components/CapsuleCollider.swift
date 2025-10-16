import SceneKit

/**
 A capsule-shaped primitive collider.
 */
public final class CapsuleCollider: Collider {
    private(set) public var radius: Float?
    private(set) public var height: Float?
    private(set) public var center: Vector3?

    @discardableResult public func set(radius: Float?) -> CapsuleCollider {
        self.radius = radius
        return self
    }

    @discardableResult public func set(height: Float?) -> CapsuleCollider {
        self.height = height
        return self
    }

    @discardableResult public func set(center: Vector3?) -> CapsuleCollider {
        self.center = center
        return self
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
     - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (CapsuleCollider) -> Void) -> CapsuleCollider {
        configurationBlock(self)
        return self
    }

    override func constructBody() {
        guard let gameObject = gameObject,
              let name = gameObject.name
        else { return }

        // Calculate dimensions from bounding box if not specified
        let boundingBox = gameObject.node.boundingBox
        let boundingSize = Vector3(
            boundingBox.max.x - boundingBox.min.x,
            boundingBox.max.y - boundingBox.min.y,
            boundingBox.max.z - boundingBox.min.z
        )

        let calculatedRadius = radius ?? max(boundingSize.x, boundingSize.z) / 2.0
        let calculatedHeight = height ?? boundingSize.y

        // Create capsule geometry (oriented along Y axis by default)
        let capsule = SCNCapsule(capRadius: CGFloat(calculatedRadius), height: CGFloat(calculatedHeight))
        capsule.name = name + "CapsuleCollider"

        // Create physics shape with capsule geometry
        var options: [SCNPhysicsShape.Option: Any] = [
            .type: SCNPhysicsShape.ShapeType.convexHull,
            .scale: gameObject.transform.localScale.x
        ]

        // Apply center offset if specified
        if let center = center {
            let centerOffset = SCNVector3(center.x, center.y, center.z)
            options[.collisionMargin] = centerOffset
        }

        physicsShape = SCNPhysicsShape(
            geometry: capsule,
            options: options
        )
    }
}
