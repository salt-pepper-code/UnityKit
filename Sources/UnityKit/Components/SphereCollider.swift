import SceneKit

/**
 A sphere-shaped primitive collider for circular collision detection.

 `SphereCollider` creates a spherical collision volume defined by a radius and optional center offset.
 It's ideal for objects with circular or spherical shapes such as balls, projectiles, planets,
 or any rounded geometry.

 ## Overview

 Sphere colliders are highly efficient for collision detection due to their mathematical simplicity.
 Distance checks between spheres only require comparing the distance between centers against the sum
 of their radii. The collider automatically calculates its radius from the attached GameObject's
 bounding box, but you can override this with a custom value.

 ## Usage

 ```swift
 // Create a sphere collider with default radius (from bounding box)
 let defaultSphere = SphereCollider()

 // Create a sphere collider with custom radius
 let customSphere = SphereCollider()
     .set(radius: 1.5)

 // Create a sphere collider with custom radius and offset center
 let offsetSphere = SphereCollider()
     .set(radius: 2.0)
     .set(center: Vector3(x: 0.0, y: 0.5, z: 0.0))

 // Configure using the configure block
 let configured = SphereCollider().configure { sphere in
     sphere.set(radius: 1.0)
     sphere.set(center: Vector3(y: 1.0))
 }
 ```

 ## When to Use

 - Balls and spherical objects
 - Projectiles like bullets or grenades
 - Planets and celestial bodies
 - Simple character collision (approximate)
 - Explosion radius detection (as trigger)
 - Pickup items and collectibles

 - Note: Sphere colliders are the most efficient primitive collider for collision detection.
 */
public final class SphereCollider: Collider {

    /// The radius of the sphere collider.
    ///
    /// Defines the size of the spherical collision volume. If not set, the collider calculates
    /// the radius as half of the maximum dimension from the GameObject's bounding box.
    ///
    /// - Note: The radius is measured in local space units before any transform scaling is applied.
    public private(set) var radius: Float?

    /// The center offset of the sphere collider in local space.
    ///
    /// Allows you to position the collider's center relative to the GameObject's origin.
    /// This is useful when the collision volume needs to be offset from the visual geometry,
    /// such as placing a collision sphere at the top of a character model.
    public private(set) var center: Vector3?

    /// Sets the radius of the sphere collider.
    ///
    /// Use this method to define a custom radius for the collision sphere. The radius determines
    /// how far the spherical collision volume extends from its center point.
    ///
    /// ```swift
    /// // Set a small radius for a marble
    /// sphereCollider.set(radius: 0.5)
    ///
    /// // Set a large radius for a planet
    /// sphereCollider.set(radius: 100.0)
    /// ```
    ///
    /// - Parameter radius: The desired radius of the sphere collider, or `nil` to use the default
    ///   calculated from the bounding box.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(radius: Float?) -> SphereCollider {
        self.radius = radius
        return self
    }

    /// Sets the center offset of the sphere collider.
    ///
    /// Use this method to position the collider's center relative to the GameObject's origin.
    /// This is particularly useful for creating collision volumes that need to be positioned
    /// differently from the visual center of the object.
    ///
    /// ```swift
    /// // Center the sphere 1 unit above the origin
    /// sphereCollider.set(center: Vector3(x: 0.0, y: 1.0, z: 0.0))
    ///
    /// // Offset the sphere slightly forward
    /// sphereCollider.set(center: Vector3(x: 0.0, y: 0.0, z: 0.5))
    /// ```
    ///
    /// - Parameter center: The desired center offset, or `nil` to use the default center.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(center: Vector3?) -> SphereCollider {
        self.center = center
        return self
    }

    /// Configures the sphere collider using a configuration block.
    ///
    /// This method provides a convenient way to configure multiple properties of the collider
    /// in a single, organized code block. The configuration block receives the collider instance,
    /// allowing you to call multiple setter methods.
    ///
    /// ```swift
    /// let collider = SphereCollider().configure { sphere in
    ///     sphere.set(radius: 1.5)
    ///     sphere.set(center: Vector3(y: 0.5))
    ///     sphere.isTrigger = true
    /// }
    /// ```
    ///
    /// - Parameter configurationBlock: A closure that receives the collider for configuration.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func configure(_ configurationBlock: (SphereCollider) -> Void) -> SphereCollider {
        configurationBlock(self)
        return self
    }

    override func constructBody() {
        guard let gameObject,
              let name = gameObject.name
        else { return }

        // Calculate radius from bounding box if not specified
        let boundingBox = gameObject.node.boundingBox
        let boundingSize = Vector3(
            boundingBox.max.x - boundingBox.min.x,
            boundingBox.max.y - boundingBox.min.y,
            boundingBox.max.z - boundingBox.min.z
        )
        let calculatedRadius = self.radius ?? max(boundingSize.x, boundingSize.y, boundingSize.z) / 2.0

        // Create sphere geometry
        let sphere = SCNSphere(radius: CGFloat(calculatedRadius))
        sphere.name = name + "SphereCollider"

        // Create physics shape with sphere geometry
        var options: [SCNPhysicsShape.Option: Any] = [
            .type: SCNPhysicsShape.ShapeType.boundingBox,
            .scale: gameObject.transform.localScale.x,
        ]

        // Apply center offset if specified
        if let center {
            let centerOffset = SCNVector3(center.x, center.y, center.z)
            options[.collisionMargin] = centerOffset
        }

        physicsShape = SCNPhysicsShape(
            geometry: sphere,
            options: options
        )
    }
}
