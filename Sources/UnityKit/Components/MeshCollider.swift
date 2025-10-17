import SceneKit

/**
 A mesh collider for precise collision detection using custom 3D geometry.

 `MeshCollider` creates a collision volume based on the actual geometry of a 3D mesh, providing
 accurate collision detection for complex shapes that cannot be approximated with primitive colliders.
 It's ideal for detailed objects like terrain, complex buildings, vehicles, or any irregular geometry.

 ## Overview

 Mesh colliders use the actual vertex and triangle data of a mesh to perform collision detection.
 They can provide pixel-perfect accuracy but are more computationally expensive than primitive colliders.
 The mesh is converted to a convex hull for physics calculations, which provides a good balance between
 accuracy and performance.

 Unlike primitive colliders, mesh colliders require you to explicitly provide a `Mesh` object that
 defines the collision geometry. This mesh can be the same as the visual mesh or a simplified version
 created specifically for collision detection.

 ## Usage

 ```swift
 // Create a mesh collider with a specific mesh
 let meshCollider = MeshCollider()
     .set(mesh: customMesh)

 // Create a simplified collision mesh for a complex model
 let simplifiedMesh = Mesh(/* simplified geometry */)
 let optimizedCollider = MeshCollider()
     .set(mesh: simplifiedMesh)

 // Configure using the configure block
 let configured = MeshCollider().configure { meshCol in
     meshCol.set(mesh: terrainMesh)
     meshCol.isTrigger = false
 }
 ```

 ## When to Use

 - Terrain and landscape geometry
 - Complex buildings and architecture
 - Vehicles with detailed shapes
 - Irregular obstacles and props
 - Custom collision volumes that don't fit primitive shapes
 - Static geometry that requires precise collision

 ## Performance Considerations

 Mesh colliders are more expensive than primitive colliders. Consider these optimization strategies:

 - Use simplified collision meshes with fewer triangles than the visual mesh
 - Prefer primitive colliders (box, sphere, capsule) when possible
 - Use mesh colliders primarily for static objects rather than moving objects
 - Combine multiple primitive colliders instead of a single complex mesh collider when feasible

 - Note: The mesh is converted to a convex hull, so concave features may not collide exactly as expected.
   For truly concave collision, consider using multiple convex mesh colliders.
 */
public final class MeshCollider: Collider {

    /// The mesh used for collision detection.
    ///
    /// Defines the geometry that will be used to calculate collisions. The mesh should ideally be
    /// a simplified version of the visual mesh with fewer triangles to improve performance. If not set,
    /// no collision geometry will be created.
    ///
    /// - Note: The mesh is converted to a convex hull for physics calculations. Complex concave shapes
    ///   may not collide exactly as expected.
    public private(set) var mesh: Mesh?

    /// Configures the mesh collider using a configuration block.
    ///
    /// This method provides a convenient way to configure the collider properties in a single,
    /// organized code block. The configuration block receives the collider instance, allowing
    /// you to set the mesh and other collider properties.
    ///
    /// ```swift
    /// let collider = MeshCollider().configure { meshCol in
    ///     meshCol.set(mesh: customMesh)
    ///     meshCol.isTrigger = false
    /// }
    /// ```
    ///
    /// - Parameter configurationBlock: A closure that receives the collider for configuration.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func configure(_ configurationBlock: (MeshCollider) -> Void) -> MeshCollider {
        configurationBlock(self)
        return self
    }

    /// Sets the mesh to be used for collision detection.
    ///
    /// Use this method to specify the geometry that defines the collision volume. The mesh can be
    /// the same as the visual mesh for maximum accuracy, or a simplified version for better performance.
    /// For complex objects, creating a dedicated low-polygon collision mesh is recommended.
    ///
    /// ```swift
    /// // Use a simplified collision mesh
    /// let collisionMesh = Mesh(/* low-poly geometry */)
    /// meshCollider.set(mesh: collisionMesh)
    ///
    /// // Use the same mesh as the visual geometry
    /// meshCollider.set(mesh: gameObject.meshRenderer?.mesh)
    /// ```
    ///
    /// - Parameter mesh: The mesh to use for collision detection, or `nil` to clear the collision mesh.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(mesh: Mesh?) -> MeshCollider {
        self.mesh = mesh
        return self
    }

    /// Constructs the physics body from the mesh geometry.
    ///
    /// This method creates the actual physics shape from the provided mesh. It converts the mesh
    /// to a convex hull and applies the GameObject's transform scale. The physics shape is only
    /// created if both a valid GameObject and mesh are present.
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
