import SceneKit

/// Defines the types of primitive 3D geometries that can be created.
///
/// `PrimitiveType` provides a convenient way to create common 3D shapes with customizable dimensions.
/// Each primitive type includes parameters for its specific dimensions and an optional name.
///
/// ## Topics
///
/// ### Primitive Shapes
///
/// - ``sphere(radius:name:)``
/// - ``capsule(capRadius:height:name:)``
/// - ``cylinder(radius:height:name:)``
/// - ``cube(width:height:length:chamferRadius:name:)``
/// - ``plane(width:height:name:)``
/// - ``floor(width:length:name:)``
///
/// ## Example
///
/// ```swift
/// // Create a sphere primitive
/// let sphereType = PrimitiveType.sphere(radius: 1.0, name: "Ball")
/// let sphere = GameObject.createPrimitive(sphereType)
///
/// // Create a floor plane
/// let floorType = PrimitiveType.floor(width: 10.0, length: 10.0)
/// let floor = GameObject.createPrimitive(floorType)
/// ```
public enum PrimitiveType {
    /// A spherical primitive geometry.
    ///
    /// Creates a 3D sphere centered at the origin with the specified radius.
    ///
    /// - Parameters:
    ///   - radius: The radius of the sphere in scene units.
    ///   - name: An optional name for the primitive. Defaults to "Sphere" if not provided.
    case sphere(
        radius: Float,
        name: String? = nil
    )

    /// A capsule primitive geometry.
    ///
    /// Creates a 3D capsule (cylinder with hemispherical caps) oriented along the Y-axis.
    /// The total height includes both caps.
    ///
    /// - Parameters:
    ///   - capRadius: The radius of the capsule's caps and body.
    ///   - height: The total height of the capsule including caps.
    ///   - name: An optional name for the primitive. Defaults to "Capsule" if not provided.
    case capsule(
        capRadius: Float,
        height: Float,
        name: String? = nil
    )

    /// A cylindrical primitive geometry.
    ///
    /// Creates a 3D cylinder oriented along the Y-axis, centered at the origin.
    ///
    /// - Parameters:
    ///   - radius: The radius of the cylinder's circular cross-section.
    ///   - height: The height of the cylinder along the Y-axis.
    ///   - name: An optional name for the primitive. Defaults to "Cylinder" if not provided.
    case cylinder(
        radius: Float,
        height: Float,
        name: String? = nil
    )

    /// A box (cube/cuboid) primitive geometry.
    ///
    /// Creates a 3D rectangular box centered at the origin with optional rounded edges.
    ///
    /// - Parameters:
    ///   - width: The extent of the box along the X-axis.
    ///   - height: The extent of the box along the Y-axis.
    ///   - length: The extent of the box along the Z-axis.
    ///   - chamferRadius: The radius for rounding the box's edges. Use 0 for sharp edges.
    ///   - name: An optional name for the primitive. Defaults to "Cube" if not provided.
    case cube(
        width: Float,
        height: Float,
        length: Float,
        chamferRadius: Float,
        name: String? = nil
    )

    /// A flat rectangular plane primitive geometry.
    ///
    /// Creates a 2D plane in 3D space, oriented in the XY plane and centered at the origin.
    /// The plane is single-sided by default.
    ///
    /// - Parameters:
    ///   - width: The width of the plane along the X-axis.
    ///   - height: The height of the plane along the Y-axis.
    ///   - name: An optional name for the primitive. Defaults to "Plane" if not provided.
    case plane(
        width: Float,
        height: Float,
        name: String? = nil
    )

    /// A horizontal floor plane that extends infinitely.
    ///
    /// Creates a horizontal plane with defined dimensions, typically used for ground surfaces.
    /// Unlike a regular plane, floors are optimized for large horizontal surfaces.
    ///
    /// - Parameters:
    ///   - width: The width of the floor along the X-axis.
    ///   - length: The length of the floor along the Z-axis.
    ///   - name: An optional name for the primitive. Defaults to "Floor" if not provided.
    case floor(
        width: Float,
        length: Float,
        name: String? = nil
    )

    var name: String {
        switch self {
        case .sphere(_, let n):
            return n ?? "Sphere"

        case .capsule(_, _, let n):
            return n ?? "Capsule"

        case .cylinder(_, _, let n):
            return n ?? "Cylinder"

        case .cube(_, _, _, _, let n):
            return n ?? "Cube"

        case .plane(_, _, let n):
            return n ?? "Plane"

        case .floor(_, _, let n):
            return n ?? "Floor"
        }
    }
}

public extension GameObject {
    /// Creates a new GameObject with a primitive geometry shape.
    ///
    /// This factory method creates a GameObject with one of the predefined primitive geometries.
    /// The created geometry uses Phong lighting by default for realistic shading.
    ///
    /// - Parameters:
    ///   - type: The type of primitive geometry to create.
    ///   - name: An optional custom name for the GameObject. If not provided, uses the primitive's default name.
    ///
    /// - Returns: A new GameObject instance with the specified primitive geometry.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a sphere with default name
    /// let sphere = GameObject.createPrimitive(.sphere(radius: 1.0))
    /// print(sphere.name) // "Sphere"
    ///
    /// // Create a cube with custom name and rounded edges
    /// let box = GameObject.createPrimitive(
    ///     .cube(width: 2.0, height: 1.0, length: 2.0, chamferRadius: 0.1),
    ///     name: "PowerUpBox"
    /// )
    ///
    /// // Create a floor for the scene
    /// let ground = GameObject.createPrimitive(
    ///     .floor(width: 20.0, length: 20.0),
    ///     name: "Ground"
    /// )
    /// ```
    ///
    /// - Note: The geometry is created with Phong lighting model, which provides realistic specular highlights.
    static func createPrimitive(_ type: PrimitiveType, name: String? = nil) -> GameObject {
        let geometry = SCNGeometry.createPrimitive(type)
        geometry.firstMaterial?.lightingModel = .phong

        let gameObject = GameObject(SCNNode(geometry: geometry))

        gameObject.name = name ?? type.name

        return gameObject
    }
}

extension SCNGeometry {
    static func createPrimitive(_ type: PrimitiveType) -> SCNGeometry {
        let geometry: SCNGeometry

        switch type {
        case .sphere(let rad, _):
            geometry = SCNSphere(radius: rad.toCGFloat())

        case .capsule(let rad, let y, _):
            geometry = SCNCapsule(capRadius: rad.toCGFloat(), height: y.toCGFloat())

        case .cylinder(let rad, let y, _):
            geometry = SCNCylinder(radius: rad.toCGFloat(), height: y.toCGFloat())

        case .cube(let x, let y, let z, let rad, _):
            geometry = SCNBox(
                width: x.toCGFloat(),
                height: y.toCGFloat(),
                length: z.toCGFloat(),
                chamferRadius: rad.toCGFloat()
            )

        case .plane(let x, let y, _):
            geometry = SCNPlane(width: x.toCGFloat(), height: y.toCGFloat())

        case .floor(let x, let z, _):
            let floor = SCNFloor()
            floor.width = x.toCGFloat()
            floor.length = z.toCGFloat()
            geometry = floor
        }

        return geometry
    }

    static func vertices(source: SCNGeometrySource) -> [Vector3] {
        guard let value = source.data.withUnsafeBytes({
            $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
        }) else { return [] }

        let rawPointer = UnsafeRawPointer(value)
        let strides = stride(
            from: source.dataOffset,
            to: source.dataOffset + source.dataStride * source.vectorCount,
            by: source.dataStride
        )

        return strides.map { byteOffset -> Vector3 in
            Vector3(rawPointer.load(fromByteOffset: byteOffset, as: SIMD3<Float>.self))
        }
    }
}
