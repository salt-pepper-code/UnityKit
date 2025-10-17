import SceneKit

/**
 A flat, infinite plane collider for ground surfaces and boundaries.

 `PlaneCollider` creates a flat, two-dimensional collision surface that extends infinitely in two
 directions (X and Z by default). It's ideal for ground planes, floors, walls, or any flat surface
 that objects should collide with.

 ## Overview

 Plane colliders are extremely efficient because they represent an infinite flat surface defined by
 a single plane equation. They automatically calculate their extent from the GameObject's bounding box
 and are oriented horizontally (parallel to the XZ plane) by default. Unlike other colliders, planes
 have no thickness and extend infinitely beyond their visual representation.

 Plane colliders are perfect for large flat surfaces where using a box collider would be overkill,
 such as infinite ground planes or arena boundaries. The collision surface is oriented along the
 top face of the GameObject's bounding box.

 ## Usage

 ```swift
 // Create a plane collider for a ground surface
 let groundPlane = PlaneCollider()

 // Create a plane collider with trigger behavior
 let triggerPlane = PlaneCollider().configure { plane in
     plane.isTrigger = true
 }

 // Configure a plane for a specific surface
 let floorPlane = PlaneCollider().configure { plane in
     plane.isTrigger = false
 }
 ```

 ## When to Use

 - Ground planes and floors
 - Invisible boundaries and walls
 - Water surfaces (as triggers)
 - Ceiling collision
 - Platform surfaces in 2.5D games
 - Arena boundaries

 ## Characteristics

 - **Infinite Extent**: The plane extends infinitely in the X and Z directions
 - **No Thickness**: Objects can only collide from one side (top)
 - **High Performance**: Extremely efficient collision detection
 - **Orientation**: Always aligned with the XZ plane (horizontal)

 - Note: For finite surfaces or surfaces that need collision from both sides, consider using
   a thin `BoxCollider` instead.
 */
public final class PlaneCollider: Collider {

    /// Configures the plane collider using a configuration block.
    ///
    /// This method provides a convenient way to configure collider properties in a single,
    /// organized code block. The configuration block receives the collider instance, allowing
    /// you to set properties like `isTrigger` or other inherited collider settings.
    ///
    /// ```swift
    /// let collider = PlaneCollider().configure { plane in
    ///     plane.isTrigger = false
    /// }
    ///
    /// // Configure as a trigger zone
    /// let triggerZone = PlaneCollider().configure { plane in
    ///     plane.isTrigger = true
    /// }
    /// ```
    ///
    /// - Parameter configurationBlock: A closure that receives the collider for configuration.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func configure(_ configurationBlock: (PlaneCollider) -> Void) -> PlaneCollider {
        configurationBlock(self)
        return self
    }

    override func constructBody() {
        guard let gameObject,
              let name = gameObject.name
        else { return }

        let boundingBox = gameObject.node.boundingBox
        let vertices = [
            Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.min.z), //1 //0
            Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.min.z), //2 //1
            Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.max.z), //5 //2
            Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.max.z),  //6 //3
        ]

        let indices: [Int16] = [
            2, 1, 0,
            3, 2, 0,
        ]

        let normals = [
            Vector3(0, 1, 1),
            Vector3(0, 1, 1),
            Vector3(0, 1, 1),
            Vector3(0, 1, 1),
        ]

        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Vector3>.size)
        let vertexSource = SCNGeometrySource(
            data: vertexData,
            semantic: .vertex,
            vectorCount: vertices.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Vector3>.size
        )

        let normalData = Data(bytes: normals, count: normals.count * MemoryLayout<Vector3>.size)
        let normalSource = SCNGeometrySource(
            data: normalData,
            semantic: .normal,
            vectorCount: normals.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Vector3>.size
        )

        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int16>.size)
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .triangles,
            primitiveCount: indices.count / 3,
            bytesPerIndex: MemoryLayout<Int16>.size
        )

        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        geometry.name = name + "PlaneCollider"

        physicsShape = SCNPhysicsShape(
            geometry: geometry,
            options: [.scale: gameObject.transform.localScale.x]
        )
    }
}
