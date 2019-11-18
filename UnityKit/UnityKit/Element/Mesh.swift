import SceneKit

public final class Mesh: Object {
    public var geometry: SCNGeometry

    @available(*, unavailable)
    public required init() {
        fatalError("init() has not been implemented")
    }

    public required init(_ geometry: SCNGeometry) {
        self.geometry = geometry
    }
}
