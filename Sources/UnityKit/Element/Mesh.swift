import SceneKit

/// A component that defines the shape of a 3D object for rendering and physics calculations.
///
/// The `Mesh` class wraps a `SCNGeometry` object and provides a Unity-like interface for managing
/// 3D geometry data. Meshes contain the vertices, triangles, normals, and other geometric information
/// that define the shape of a 3D object.
///
/// ## Overview
///
/// Meshes are fundamental building blocks for 3D graphics. They define the visual structure of
/// objects in your scene by specifying vertex positions and how those vertices connect to form
/// triangles. UnityKit's `Mesh` class provides a simplified interface to SceneKit's geometry system.
///
/// ## Topics
///
/// ### Creating a Mesh
///
/// - ``init(_:)``
///
/// ### Accessing Geometry
///
/// - ``geometry``
///
/// ## Example Usage
///
/// ```swift
/// // Create a box mesh
/// let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
/// let boxMesh = Mesh(boxGeometry)
///
/// // Create a sphere mesh
/// let sphereGeometry = SCNSphere(radius: 0.5)
/// let sphereMesh = Mesh(sphereGeometry)
///
/// // Assign to a GameObject
/// gameObject.mesh = boxMesh
/// ```
public final class Mesh: Object {
    /// The underlying SceneKit geometry that defines the shape.
    ///
    /// This property provides direct access to the `SCNGeometry` instance, allowing you to
    /// modify geometry properties such as materials, subdivision levels, and edge creasing.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let mesh = Mesh(SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    /// mesh.geometry.subdivisionLevel = 2
    /// mesh.geometry.edgeCreasing = 0.5
    /// ```
    public var geometry: SCNGeometry

    @available(*, unavailable)
    public required init() {
        fatalError("init() has not been implemented")
    }

    /// Creates a new mesh with the specified geometry.
    ///
    /// This initializer wraps a `SCNGeometry` object in a UnityKit `Mesh`. The geometry defines
    /// the shape, vertex data, normals, and texture coordinates for the mesh.
    ///
    /// - Parameter geometry: The SceneKit geometry that defines the mesh's shape and structure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a cylinder mesh
    /// let cylinderGeometry = SCNCylinder(radius: 0.5, height: 2.0)
    /// let mesh = Mesh(cylinderGeometry)
    ///
    /// // Create a custom geometry from vertices and indices
    /// let vertices: [SCNVector3] = [
    ///     SCNVector3(0, 0, 0),
    ///     SCNVector3(1, 0, 0),
    ///     SCNVector3(0.5, 1, 0)
    /// ]
    /// let vertexSource = SCNGeometrySource(vertices: vertices)
    /// let indices: [Int32] = [0, 1, 2]
    /// let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    /// let customGeometry = SCNGeometry(sources: [vertexSource], elements: [element])
    /// let customMesh = Mesh(customGeometry)
    /// ```
    public required init(_ geometry: SCNGeometry) {
        self.geometry = geometry
    }
}
