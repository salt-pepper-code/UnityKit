import SceneKit

public final class Mesh: Object {
    public var geometry: SCNGeometry

    @available(*, unavailable)
    public required init() {
        fatalError("init() has not been implemented")
    }

    /// Create a new instance
    ///
    /// - Parameter geometry: A geometry to be managed
    public required init(_ geometry: SCNGeometry) {
        self.geometry = geometry
    }
}
