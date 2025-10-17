import SceneKit

/**
 A box-shaped primitive collider for rectangular collision detection.

 `BoxCollider` creates a rectangular collision volume that can be customized with specific dimensions
 and center offsets. It's ideal for objects with box-like shapes such as crates, buildings, walls,
 or any rectangular geometry.

 ## Overview

 Box colliders are one of the most commonly used primitive colliders due to their computational efficiency
 and ability to approximate many real-world objects. The collider automatically calculates its bounds from
 the attached GameObject's geometry, but you can override the size and center position as needed.

 ## Usage

 ```swift
 // Create a box collider with default size (GameObject's bounding box)
 let defaultBox = BoxCollider()

 // Create a box collider with custom size
 let customBox = BoxCollider()
     .set(size: Vector3Nullable(x: 2.0, y: 1.0, z: 2.0))

 // Create a box collider with custom size and offset center
 let offsetBox = BoxCollider()
     .set(size: Vector3Nullable(x: 3.0, y: 2.0, z: 1.5))
     .set(center: Vector3Nullable(x: 0.0, y: 0.5, z: 0.0))

 // Configure using the configure block
 let configured = BoxCollider().configure { box in
     box.set(size: Vector3Nullable(x: 1.0, y: 1.0, z: 1.0))
     box.set(center: Vector3Nullable(y: 0.5))
 }
 ```

 ## When to Use

 - Buildings, crates, and boxes
 - Walls and rectangular obstacles
 - Furniture and rectangular props
 - Simple character collision volumes
 - Ground planes with thickness

 - Note: Box colliders are more efficient than mesh colliders for simple rectangular shapes.
 */
public final class BoxCollider: Collider {

    /// The size of the box collider in local space.
    ///
    /// Defines the dimensions of the box along each axis. If not set, the collider uses the
    /// GameObject's bounding box dimensions. Each component (x, y, z) can be set individually
    /// or left as `nil` to use the default value from the bounding box.
    ///
    /// - Note: The size is measured in local space units before any transform scaling is applied.
    public private(set) var size: Vector3Nullable?

    /// The center offset of the box collider in local space.
    ///
    /// Allows you to position the collider's center relative to the GameObject's origin.
    /// This is useful when the collision volume needs to be offset from the visual geometry.
    /// Each component (x, y, z) can be set individually or left as `nil` to use the default
    /// center from the bounding box.
    public private(set) var center: Vector3Nullable?

    /// Sets the size of the box collider.
    ///
    /// Use this method to define custom dimensions for the collision box. You can specify
    /// all three dimensions or only the ones you want to override from the default bounding box.
    ///
    /// ```swift
    /// // Set all dimensions
    /// boxCollider.set(size: Vector3Nullable(x: 2.0, y: 1.5, z: 3.0))
    ///
    /// // Set only the height, keeping default width and depth
    /// boxCollider.set(size: Vector3Nullable(y: 2.0))
    /// ```
    ///
    /// - Parameter size: The desired size of the box collider, or `nil` to use default dimensions.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(size: Vector3Nullable?) -> BoxCollider {
        self.size = size
        return self
    }

    /// Sets the center offset of the box collider.
    ///
    /// Use this method to position the collider's center relative to the GameObject's origin.
    /// This is particularly useful for adjusting collision volumes to match visual geometry
    /// or creating offset collision boundaries.
    ///
    /// ```swift
    /// // Center the box 1 unit above the origin
    /// boxCollider.set(center: Vector3Nullable(y: 1.0))
    ///
    /// // Offset in multiple directions
    /// boxCollider.set(center: Vector3Nullable(x: 0.5, y: 1.0, z: -0.5))
    /// ```
    ///
    /// - Parameter center: The desired center offset, or `nil` to use the default center.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func set(center: Vector3Nullable?) -> BoxCollider {
        self.center = center
        return self
    }

    /// Configures the box collider using a configuration block.
    ///
    /// This method provides a convenient way to configure multiple properties of the collider
    /// in a single, organized code block. The configuration block receives the collider instance,
    /// allowing you to call multiple setter methods.
    ///
    /// ```swift
    /// let collider = BoxCollider().configure { box in
    ///     box.set(size: Vector3Nullable(x: 2.0, y: 1.0, z: 2.0))
    ///     box.set(center: Vector3Nullable(y: 0.5))
    ///     box.isTrigger = true
    /// }
    /// ```
    ///
    /// - Parameter configurationBlock: A closure that receives the collider for configuration.
    /// - Returns: The collider instance for method chaining.
    @discardableResult public func configure(_ configurationBlock: (BoxCollider) -> Void) -> BoxCollider {
        configurationBlock(self)
        return self
    }

    override func constructBody() {
        guard let gameObject,
              let name = gameObject.name
        else { return }

        var boundingBox = gameObject.node.boundingBox
        let boundingCenter = Volume.boundingCenter(boundingBox)

        if let x = size?.x {
            boundingBox.min.x = boundingCenter.x - (x / 2)
            boundingBox.max.x = boundingCenter.x + (x / 2)
        }
        if let y = size?.y {
            boundingBox.min.y = boundingCenter.y - (y / 2)
            boundingBox.max.y = boundingCenter.y + (y / 2)
        }
        if let z = size?.z {
            boundingBox.min.z = boundingCenter.z - (z / 2)
            boundingBox.max.z = boundingCenter.z + (z / 2)
        }

        if let center {
            boundingBox = Volume.moveCenter(boundingBox, center: center)
        }

        let vertices = [
            Vector3(boundingBox.min.x, boundingBox.min.y, boundingBox.min.z),
            Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.min.z),
            Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.min.z),
            Vector3(boundingBox.max.x, boundingBox.min.y, boundingBox.min.z),
            Vector3(boundingBox.max.x, boundingBox.min.y, boundingBox.max.z),
            Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.max.z),
            Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.max.z),
            Vector3(boundingBox.min.x, boundingBox.min.y, boundingBox.max.z),
        ]

        let indices: [Int16] = [
            0, 1, 2,
            0, 2, 3,
            3, 2, 5,
            3, 5, 4,
            5, 2, 1,
            5, 1, 6,
            3, 4, 7,
            3, 7, 0,
            0, 7, 6,
            0, 6, 1,
            4, 5, 6,
            4, 6, 7,
        ]

        let normals = [
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
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
        geometry.name = name + "BoxCollider"

        physicsShape = SCNPhysicsShape(
            geometry: geometry,
            options: [
                .type: SCNPhysicsShape.ShapeType.boundingBox,
                .scale: gameObject.transform.localScale.x,
            ]
        )
    }
}
