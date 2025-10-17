/// A component that holds a reference to a mesh for rendering.
///
/// `MeshFilter` stores the mesh geometry that will be rendered by a `MeshRenderer` component.
/// It acts as a container for mesh data, separating mesh storage from the rendering logic.
/// This component is typically used in conjunction with `MeshRenderer` to display 3D models.
///
/// The mesh filter is a priority component that is initialized early in the component lifecycle
/// to ensure mesh data is available before rendering begins.
///
/// ## Topics
///
/// ### Managing the Mesh
/// - ``mesh``
///
/// ## Example
///
/// ```swift
/// // Create a GameObject with a mesh filter
/// let cube = GameObject(name: "Cube")
///
/// // Add a mesh filter and assign a mesh
/// if let meshFilter = cube.addComponent(MeshFilter.self) {
///     meshFilter.mesh = Mesh.createCube()
/// }
///
/// // Access the mesh later
/// if let mesh = cube.getComponent(MeshFilter.self)?.mesh {
///     print("Mesh has \(mesh.vertices.count) vertices")
/// }
/// ```
///
/// - Note: The mesh property can be changed at runtime to swap the displayed geometry.
/// - Important: This is a priority component that initializes before most other components.
public final class MeshFilter: Component {
    override var order: ComponentOrder {
        .priority
    }

    /// The mesh assigned to this mesh filter.
    ///
    /// This property holds the mesh geometry that will be rendered. You can assign different
    /// mesh objects to change the visual appearance of the GameObject. Set to `nil` to remove
    /// the mesh.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Assign a mesh
    /// meshFilter.mesh = Mesh.createSphere()
    ///
    /// // Change the mesh at runtime
    /// meshFilter.mesh = Mesh.createCube()
    ///
    /// // Remove the mesh
    /// meshFilter.mesh = nil
    /// ```
    ///
    /// - Note: The mesh is not automatically rendered. A `MeshRenderer` component is typically
    ///   required to display the mesh.
    public var mesh: Mesh?
}
