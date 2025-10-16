/**
 A class to access the Mesh of the mesh filter.
 */
public final class MeshFilter: Component {
    override var order: ComponentOrder {
        .priority
    }

    /**
     Returns the instantiated Mesh assigned to the mesh filter.
     */
    public var mesh: Mesh?
}
