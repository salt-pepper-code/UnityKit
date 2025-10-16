import SceneKit

/**
 A sphere-shaped primitive collider.
 */
public final class SphereCollider: Collider {
    private(set) public var radius: Float?
    private(set) public var center: Vector3?

    @discardableResult public func set(radius: Float?) -> SphereCollider {
        self.radius = radius
        return self
    }

    @discardableResult public func set(center: Vector3?) -> SphereCollider {
        self.center = center
        return self
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
     - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (SphereCollider) -> Void) -> SphereCollider {
        configurationBlock(self)
        return self
    }

    override func constructBody() {
        guard let gameObject = gameObject,
              let name = gameObject.name
        else { return }

        // Calculate radius from bounding box if not specified
        let boundingBox = gameObject.node.boundingBox
        let boundingSize = Vector3(
            boundingBox.max.x - boundingBox.min.x,
            boundingBox.max.y - boundingBox.min.y,
            boundingBox.max.z - boundingBox.min.z
        )
        let calculatedRadius = radius ?? max(boundingSize.x, boundingSize.y, boundingSize.z) / 2.0

        // Create sphere geometry
        let sphere = SCNSphere(radius: CGFloat(calculatedRadius))
        sphere.name = name + "SphereCollider"

        // Create physics shape with sphere geometry
        var options: [SCNPhysicsShape.Option: Any] = [
            .type: SCNPhysicsShape.ShapeType.boundingBox,
            .scale: gameObject.transform.localScale.x
        ]

        // Apply center offset if specified
        if let center = center {
            let centerOffset = SCNVector3(center.x, center.y, center.z)
            options[.collisionMargin] = centerOffset
        }

        physicsShape = SCNPhysicsShape(
            geometry: sphere,
            options: options
        )
    }
}
