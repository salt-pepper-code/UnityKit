import SceneKit

/**
 A capsule-shaped primitive collider for cylindrical collision detection with rounded ends.

 `CapsuleCollider` creates a pill-shaped collision volume defined by a radius and height, with
 hemispherical caps on both ends. It's ideal for upright objects like characters, pillars, trees,
 or any geometry that approximates a cylinder with rounded ends.

 ## Overview

 Capsule colliders are commonly used for character controllers because they allow smooth movement
 over steps and obstacles. The capsule is oriented along the Y-axis by default, with hemispherical
 caps at the top and bottom. The height represents the total height including both caps.

 The collider automatically calculates its dimensions from the attached GameObject's bounding box,
 where the radius is derived from the maximum of the X and Z dimensions, and the height from the
 Y dimension.

 ## Usage

 ```swift
 // Create a capsule collider with default dimensions (from bounding box)
 let defaultCapsule = CapsuleCollider()

 // Create a capsule collider for a character (radius 0.5, height 2.0)
 let characterCapsule = CapsuleCollider()
     .set(radius: 0.5)
     .set(height: 2.0)

 // Create a capsule collider with custom dimensions and offset center
 let offsetCapsule = CapsuleCollider()
     .set(radius: 0.3)
     .set(height: 1.8)
     .set(center: Vector3(x: 0.0, y: 0.9, z: 0.0))

 // Configure using the configure block
 let configured = CapsuleCollider().configure { capsule in
     capsule.set(radius: 0.4)
     capsule.set(height: 1.5)
     capsule.set(center: Vector3(y: 0.75))
 }
 ```

 ## When to Use

 - Humanoid character controllers
 - Tree trunks and pillars
 - Cylindrical containers or barrels
 - Projectiles like missiles or rockets
 - Vertical obstacles like poles
 - Standing NPCs and enemies

 - Note: The capsule is always oriented along the Y-axis (vertical). For horizontal capsules,
   consider rotating the GameObject or using a different collider type.
 */
public final class CapsuleCollider: Collider {

    /// The radius of the capsule collider.
    ///
    /// Defines the width of the cylindrical body and the radius of the hemispherical caps.
    /// If not set, the collider calculates the radius as half of the maximum of the X and Z
    /// dimensions from the GameObject's bounding box.
    ///
    /// - Note: The radius is measured in local space units before any transform scaling is applied.
    public private(set) var radius: Float?

    /// The total height of the capsule collider including both hemispherical caps.
    ///
    /// Defines the vertical extent of the collision volume from the bottom cap to the top cap.
    /// If not set, the collider uses the Y dimension of the GameObject's bounding box.
    ///
    /// - Note: The height must be at least twice the radius to form a valid capsule. The height
    ///   is measured in local space units before any transform scaling is applied.
    public private(set) var height: Float?

    /// The center offset of the capsule collider in local space.
    ///
    /// Allows you to position the collider's center relative to the GameObject's origin.
    /// This is particularly useful for character controllers where you might want to offset
    /// the capsule to align with the character's visual center or adjust ground clearance.
    public private(set) var center: Vector3?

    /// Sets the radius of the capsule collider.
    ///
    /// Use this method to define the width of the cylindrical collision volume and its rounded caps.
    /// The radius should be appropriate for the character or object's girth.
    ///
    /// ```swift
    /// // Set radius for a thin character
    /// capsuleCollider.set(radius: 0.3)
    ///
    /// // Set radius for a larger character
    /// capsuleCollider.set(radius: 0.6)
    /// ```
    ///
    /// - Parameter radius: The desired radius of the capsule collider, or `nil` to use the default
    ///   calculated from the bounding box.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(radius: Float?) -> CapsuleCollider {
        self.radius = radius
        return self
    }

    /// Sets the height of the capsule collider.
    ///
    /// Use this method to define the total vertical extent of the collision volume, including
    /// both hemispherical caps. For character controllers, this typically matches the character's
    /// standing height.
    ///
    /// ```swift
    /// // Set height for a short character (1.5 units tall)
    /// capsuleCollider.set(height: 1.5)
    ///
    /// // Set height for a tall character (2.2 units tall)
    /// capsuleCollider.set(height: 2.2)
    /// ```
    ///
    /// - Parameter height: The desired total height of the capsule collider, or `nil` to use
    ///   the default calculated from the bounding box.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(height: Float?) -> CapsuleCollider {
        self.height = height
        return self
    }

    /// Sets the center offset of the capsule collider.
    ///
    /// Use this method to position the collider's center relative to the GameObject's origin.
    /// For character controllers, you typically offset the capsule upward by half its height
    /// so the bottom of the capsule aligns with the ground.
    ///
    /// ```swift
    /// // Center a 2.0 unit tall capsule so its bottom is at y=0
    /// capsuleCollider.set(center: Vector3(x: 0.0, y: 1.0, z: 0.0))
    ///
    /// // Offset the capsule slightly forward and up
    /// capsuleCollider.set(center: Vector3(x: 0.0, y: 0.9, z: 0.2))
    /// ```
    ///
    /// - Parameter center: The desired center offset, or `nil` to use the default center.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(center: Vector3?) -> CapsuleCollider {
        self.center = center
        return self
    }

    /// Configures the capsule collider using a configuration block.
    ///
    /// This method provides a convenient way to configure multiple properties of the collider
    /// in a single, organized code block. The configuration block receives the collider instance,
    /// allowing you to call multiple setter methods.
    ///
    /// ```swift
    /// let collider = CapsuleCollider().configure { capsule in
    ///     capsule.set(radius: 0.5)
    ///     capsule.set(height: 2.0)
    ///     capsule.set(center: Vector3(y: 1.0))
    ///     capsule.isTrigger = false
    /// }
    /// ```
    ///
    /// - Parameter configurationBlock: A closure that receives the collider for configuration.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func configure(_ configurationBlock: (CapsuleCollider) -> Void) -> CapsuleCollider {
        configurationBlock(self)
        return self
    }

    override func constructBody() {
        guard let gameObject,
              let name = gameObject.name
        else { return }

        let boundingBox = gameObject.node.boundingBox
        let boundingSize = Vector3(
            boundingBox.max.x - boundingBox.min.x,
            boundingBox.max.y - boundingBox.min.y,
            boundingBox.max.z - boundingBox.min.z
        )

        let calculatedRadius = self.radius ?? max(boundingSize.x, boundingSize.z) / 2.0
        let calculatedHeight = self.height ?? boundingSize.y

        let capsule = SCNCapsule(capRadius: CGFloat(calculatedRadius), height: CGFloat(calculatedHeight))
        capsule.name = name + "CapsuleCollider"

        var options: [SCNPhysicsShape.Option: Any] = [
            .type: SCNPhysicsShape.ShapeType.convexHull,
            .scale: gameObject.transform.localScale.x,
        ]

        if let center {
            let centerOffset = SCNVector3(center.x, center.y, center.z)
            options[.collisionMargin] = centerOffset
        }

        physicsShape = SCNPhysicsShape(
            geometry: capsule,
            options: options
        )
    }
}
