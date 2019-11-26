/**
A class to access the Mesh of the mesh filter.
*/
public final class MeshFilter: Component {
    override internal var order: ComponentOrder {
        return .priority
    }
    /**
    Returns the instantiated Mesh assigned to the mesh filter.
    */
    public var mesh: Mesh?

    /// Create a new instance
    public required init() {
        super.init()
        self.ignoreUpdates = true
    }
}
