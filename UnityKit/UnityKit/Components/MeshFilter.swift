public final class MeshFilter: Component {
    public var mesh: Mesh?

    public required init() {
        super.init()
        self.ignoreUpdates = true
    }
}
