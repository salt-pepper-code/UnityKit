import SceneKit

/// A tuple representing an axis-aligned bounding box in 3D space.
///
/// The bounding box is defined by its minimum and maximum corner points, creating
/// a rectangular volume aligned with the coordinate axes.
///
/// ## Example
///
/// ```swift
/// let box: BoundingBox = (
///     min: Vector3(-1, -1, -1),
///     max: Vector3(1, 1, 1)
/// )
/// let size = Volume.boundingSize(box)  // (2, 2, 2)
/// ```
public typealias BoundingBox = (min: Vector3, max: Vector3)

/// A tuple representing a bounding sphere in 3D space.
///
/// The bounding sphere is defined by its center point and radius, creating
/// a spherical volume that can enclose a 3D object.
///
/// ## Example
///
/// ```swift
/// let sphere: BoundingSphere = (
///     center: Vector3(0, 0, 0),
///     radius: 5.0
/// )
/// ```
public typealias BoundingSphere = (center: Vector3, radius: Float)

/// Utility class for calculating and manipulating bounding volumes in 3D space.
///
/// ``Volume`` provides static methods for working with bounding boxes, including
/// calculating size, center, and transforming bounding volumes. These utilities
/// are essential for collision detection, spatial queries, and object placement.
///
/// ## Overview
///
/// Bounding volumes are simplified geometric shapes that enclose more complex objects.
/// They are used for:
/// - Collision detection and physics calculations
/// - Culling and visibility determination
/// - Spatial partitioning and scene management
/// - Object placement and alignment
///
/// ## Example Usage
///
/// ```swift
/// // Calculate bounding box properties
/// let box: BoundingBox = (min: Vector3(-2, 0, -2), max: Vector3(2, 4, 2))
/// let size = Volume.boundingSize(box)      // (4, 4, 4)
/// let center = Volume.boundingCenter(box)  // (0, 2, 0)
///
/// // Move the bounding box to a new center
/// let moved = Volume.moveCenter(box, center: Vector3Nullable(x: 5, y: nil, z: nil))
/// // Result: min: (3, 0, -2), max: (7, 4, 2)
///
/// // Combine bounding boxes
/// let box1: BoundingBox = (min: Vector3(0, 0, 0), max: Vector3(1, 1, 1))
/// let box2: BoundingBox = (min: Vector3(2, 0, 0), max: Vector3(3, 2, 1))
/// let combined = box1 + box2  // Encompasses both boxes
/// ```
///
/// ## Topics
///
/// ### Calculating Bounding Properties
///
/// - ``boundingSize(_:)``
/// - ``boundingCenter(_:)``
///
/// ### Transforming Bounding Boxes
///
/// - ``moveCenter(_:center:)``
///
/// ### Bounding Box Operators
///
/// - ``+(_:_:)-7j3m4``
/// - ``+=(_:_:)``
/// - ``*(_:_:)-3kd8f``
/// - ``*(_:_:)-9hk2l``
public class Volume {
    /// Calculates the dimensions of a bounding box.
    ///
    /// Returns the width, height, and depth of the bounding box by computing
    /// the absolute difference between maximum and minimum points on each axis.
    ///
    /// - Parameter boundingBox: The bounding box to measure
    /// - Returns: A Vector3 containing the width (x), height (y), and depth (z) of the box
    ///
    /// ## Example
    ///
    /// ```swift
    /// let box: BoundingBox = (
    ///     min: Vector3(1, 2, 3),
    ///     max: Vector3(5, 8, 7)
    /// )
    /// let size = Volume.boundingSize(box)
    /// // Result: Vector3(4, 6, 4)
    /// //   width: 5 - 1 = 4
    /// //   height: 8 - 2 = 6
    /// //   depth: 7 - 3 = 4
    /// ```
    public static func boundingSize(_ boundingBox: BoundingBox) -> Vector3 {
        Vector3(
            abs(boundingBox.max.x - boundingBox.min.x),
            abs(boundingBox.max.y - boundingBox.min.y),
            abs(boundingBox.max.z - boundingBox.min.z)
        )
    }

    /// Calculates the center point of a bounding box.
    ///
    /// Returns the geometric center of the bounding box, which is the midpoint
    /// between the minimum and maximum corners.
    ///
    /// - Parameter boundingBox: The bounding box to find the center of
    /// - Returns: A Vector3 representing the center point of the box
    ///
    /// ## Example
    ///
    /// ```swift
    /// let box: BoundingBox = (
    ///     min: Vector3(-2, 0, -2),
    ///     max: Vector3(2, 4, 2)
    /// )
    /// let center = Volume.boundingCenter(box)
    /// // Result: Vector3(0, 2, 0)
    ///
    /// // Use to position an object at the center of a group
    /// let groupBounds = gameObject.boundingBox(relativeTo: scene.rootGameObject)
    /// if let bounds = groupBounds {
    ///     marker.transform.position = Volume.boundingCenter(bounds)
    /// }
    /// ```
    public static func boundingCenter(_ boundingBox: BoundingBox) -> Vector3 {
        let volumeSize = Volume.boundingSize(boundingBox)
        return Vector3(
            boundingBox.min.x + volumeSize.x / 2,
            boundingBox.min.y + volumeSize.y / 2,
            boundingBox.min.z + volumeSize.z / 2
        )
    }

    /// Moves a bounding box to a new center position.
    ///
    /// Translates the bounding box so that its center aligns with the specified position.
    /// You can selectively move only certain axes by providing `nil` for axes that should
    /// remain unchanged.
    ///
    /// - Parameters:
    ///   - boundingBox: The bounding box to move
    ///   - center: The new center position. Use nil for any axis to keep it unchanged.
    /// - Returns: A new bounding box with the updated position
    ///
    /// ## Example
    ///
    /// ```swift
    /// let box: BoundingBox = (min: Vector3(-1, 0, -1), max: Vector3(1, 2, 1))
    /// // Current center: (0, 1, 0)
    ///
    /// // Move to a new position
    /// let moved = Volume.moveCenter(box, center: Vector3Nullable(x: 5, y: 3, z: -2))
    /// // New box: min: (4, 2, -3), max: (6, 4, -1)
    ///
    /// // Move only on the X axis, keeping Y and Z centered at the same place
    /// let movedX = Volume.moveCenter(box, center: Vector3Nullable(x: 10, y: nil, z: nil))
    /// // New box: min: (9, 0, -1), max: (11, 2, 1)
    ///
    /// // Use case: Align objects at a specific height
    /// if let bounds = gameObject.boundingBox(relativeTo: scene.rootGameObject) {
    ///     let grounded = Volume.moveCenter(bounds, center: Vector3Nullable(x: nil, y: 0, z: nil))
    /// }
    /// ```
    public static func moveCenter(_ boundingBox: BoundingBox, center: Vector3Nullable) -> BoundingBox {
        let volumeSize = Volume.boundingSize(boundingBox)
        var volumeCenter = Volume.boundingCenter(boundingBox)
        if let x = center.x { volumeCenter.x = x }
        if let y = center.y { volumeCenter.y = y }
        if let z = center.z { volumeCenter.z = z }
        return (
            min: Vector3(
                volumeCenter.x - (volumeSize.x / 2),
                volumeCenter.y - (volumeSize.y / 2),
                volumeCenter.z - (volumeSize.z / 2)
            ),
            max: Vector3(
                volumeCenter.x + (volumeSize.x / 2),
                volumeCenter.y + (volumeSize.y / 2),
                volumeCenter.z + (volumeSize.z / 2)
            )
        )
    }
}

/// Combines two optional bounding boxes into one that encompasses both.
///
/// Creates a new bounding box that contains both input boxes by taking the minimum
/// of all minimum coordinates and the maximum of all maximum coordinates. If one box
/// is nil, returns the other box.
///
/// - Parameters:
///   - left: The first bounding box, or nil
///   - right: The second bounding box, or nil
/// - Returns: A bounding box encompassing both inputs, or nil if both are nil
///
/// ## Example
///
/// ```swift
/// let box1: BoundingBox = (min: Vector3(0, 0, 0), max: Vector3(1, 1, 1))
/// let box2: BoundingBox = (min: Vector3(2, -1, 0), max: Vector3(3, 2, 1))
///
/// let combined = box1 + box2
/// // Result: (min: Vector3(0, -1, 0), max: Vector3(3, 2, 1))
///
/// // Handle nil cases
/// let partial: BoundingBox? = nil
/// let result = partial + box1  // Returns box1
///
/// // Combine multiple boxes
/// var totalBounds: BoundingBox? = nil
/// for child in gameObject.children {
///     totalBounds = totalBounds + child.boundingBox(relativeTo: gameObject)
/// }
/// ```
public func + (left: BoundingBox?, right: BoundingBox?) -> BoundingBox? {
    guard let left else {
        return right
    }
    guard let right else {
        return left
    }
    var add = left
    add.min.x = min(left.min.x, right.min.x)
    add.min.y = min(left.min.y, right.min.y)
    add.min.z = min(left.min.z, right.min.z)
    add.max.x = max(left.max.x, right.max.x)
    add.max.y = max(left.max.y, right.max.y)
    add.max.z = max(left.max.z, right.max.z)
    return add
}

/// Combines a bounding box with another, updating the left operand in place.
///
/// This is a compound assignment operator that combines two bounding boxes and stores
/// the result in the left operand. Equivalent to `left = left + right`.
///
/// - Parameters:
///   - left: The bounding box to update (passed as inout)
///   - right: The bounding box to combine with, or nil
///
/// ## Example
///
/// ```swift
/// var bounds: BoundingBox? = (min: Vector3(0, 0, 0), max: Vector3(1, 1, 1))
/// let additionalBox: BoundingBox = (min: Vector3(2, 0, 0), max: Vector3(3, 2, 1))
///
/// bounds += additionalBox
/// // bounds is now: (min: Vector3(0, 0, 0), max: Vector3(3, 2, 1))
/// ```
public func += (left: inout BoundingBox?, right: BoundingBox?) {
    left = left + right
}

/// Scales a bounding box by a vector, scaling each axis independently.
///
/// Multiplies both the minimum and maximum corners of the bounding box by the vector,
/// allowing non-uniform scaling along different axes.
///
/// - Parameters:
///   - left: The bounding box to scale
///   - right: The scaling vector
/// - Returns: A new scaled bounding box
///
/// ## Example
///
/// ```swift
/// let box: BoundingBox = (min: Vector3(-1, -1, -1), max: Vector3(1, 1, 1))
/// let scaled = box * Vector3(2, 1, 3)
/// // Result: (min: Vector3(-2, -1, -3), max: Vector3(2, 1, 3))
/// ```
public func * (left: BoundingBox, right: Vector3) -> BoundingBox {
    (min: left.min * right, max: left.max * right)
}

/// Scales a bounding box uniformly by a scalar value.
///
/// Multiplies both the minimum and maximum corners of the bounding box by the scalar,
/// scaling the box uniformly along all axes.
///
/// - Parameters:
///   - left: The bounding box to scale
///   - right: The scaling factor
/// - Returns: A new scaled bounding box
///
/// ## Example
///
/// ```swift
/// let box: BoundingBox = (min: Vector3(-1, -1, -1), max: Vector3(1, 1, 1))
/// let doubled = box * 2.0
/// // Result: (min: Vector3(-2, -2, -2), max: Vector3(2, 2, 2))
///
/// let halved = box * 0.5
/// // Result: (min: Vector3(-0.5, -0.5, -0.5), max: Vector3(0.5, 0.5, 0.5))
/// ```
public func * (left: BoundingBox, right: Float) -> BoundingBox {
    (min: left.min * right, max: left.max * right)
}

public extension GameObject {
    /// Calculates an approximate bounding box from the object's bounding sphere.
    ///
    /// Creates an axis-aligned bounding box that inscribes the object's bounding sphere.
    /// This is faster but less accurate than calculating the exact vertex-based bounding box.
    ///
    /// - Parameter gameObject: The reference GameObject to calculate bounds relative to. If nil, uses local space.
    /// - Returns: An optional BoundingBox, or nil if the object has no geometry
    ///
    /// ## Example
    ///
    /// ```swift
    /// let sphere = GameObject.createPrimitive(.sphere(radius: 2))
    /// if let bounds = sphere.boundingBoxFromBoundingSphere() {
    ///     let size = Volume.boundingSize(bounds)
    ///     print("Approximate size: \(size)")
    /// }
    ///
    /// // Calculate bounds relative to parent
    /// let child = GameObject()
    /// parent.addChild(child)
    /// let relativeBounds = child.boundingBoxFromBoundingSphere(relativeTo: parent)
    /// ```
    func boundingBoxFromBoundingSphere(relativeTo gameObject: GameObject? = nil) -> BoundingBox? {
        node.boundingBoxFromBoundingSphere(relativeTo: gameObject?.node)
    }

    /// Calculates the precise bounding box of the GameObject.
    ///
    /// Computes an axis-aligned bounding box based on the actual vertex positions
    /// of the geometry. This is more accurate than ``boundingBoxFromBoundingSphere(relativeTo:)``
    /// but may be slower for complex meshes. Includes all child objects in the calculation.
    ///
    /// - Parameter gameObject: The reference GameObject to calculate bounds relative to
    /// - Returns: An optional BoundingBox, or nil if the object has no geometry
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Calculate bounds of an object relative to its parent
    /// let parent = GameObject()
    /// let child = GameObject.createPrimitive(.cube(size: 2))
    /// parent.addChild(child)
    /// child.transform.position = Vector3(5, 0, 0)
    ///
    /// if let bounds = child.boundingBox(relativeTo: parent) {
    ///     let center = Volume.boundingCenter(bounds)
    ///     print("Child center in parent space: \(center)")
    /// }
    ///
    /// // Get bounds of entire hierarchy
    /// if let totalBounds = parent.boundingBox(relativeTo: scene.rootGameObject) {
    ///     let size = Volume.boundingSize(totalBounds)
    ///     print("Total size including all children: \(size)")
    /// }
    /// ```
    func boundingBox(relativeTo gameObject: GameObject) -> BoundingBox? {
        node.boundingBox(relativeTo: gameObject.node)
    }
}

extension SCNNode {
    func boundingBoxFromBoundingSphere(relativeTo node: SCNNode? = nil) -> BoundingBox? {
        guard let _ = geometry
        else { return nil }

        let node = node ?? self

        let boundingSphere = self.boundingSphere
        let relativeCenter = convertPosition(boundingSphere.center, to: node)

        return (min: relativeCenter - boundingSphere.radius, max: relativeCenter + boundingSphere.radius)
    }

    func boundingBox(relativeTo node: SCNNode) -> BoundingBox? {
        var boundingBox = childNodes
            .reduce(nil) { $0 + $1.boundingBox(relativeTo: node) }

        guard let geometry,
              let source = geometry.sources(for: SCNGeometrySource.Semantic.vertex).first
        else { return boundingBox }

        let vertices = SCNGeometry.vertices(source: source).map { convertPosition($0, to: node) }
        guard let first = vertices.first
        else { return boundingBox }

        boundingBox += vertices.reduce(
            into: (min: first, max: first))
        { boundingBox, vertex in
            boundingBox.min.x = min(boundingBox.min.x, vertex.x)
            boundingBox.min.y = min(boundingBox.min.y, vertex.y)
            boundingBox.min.z = min(boundingBox.min.z, vertex.z)
            boundingBox.max.x = max(boundingBox.max.x, vertex.x)
            boundingBox.max.y = max(boundingBox.max.y, vertex.y)
            boundingBox.max.z = max(boundingBox.max.z, vertex.z)
        }

        return boundingBox
    }
}
