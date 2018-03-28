
import SpriteKit
import SceneKit

public class CanvasObject: GameObject {

    private(set) public var worldSize: Size
    private(set) public var pixelPerUnit: Float

    internal var skScene: SKScene {
        return node.geometry!.firstMaterial!.diffuse.contents as! SKScene
    }

    @discardableResult public func set(worldSize: Size, pixelPerUnit: Float = 1) -> CanvasObject {

        self.worldSize = worldSize
        self.pixelPerUnit = pixelPerUnit
        self.node = updateGeometry()
        return self
    }

    public required init(worldSize: Size, pixelPerUnit: Float = 100) {

        self.worldSize = worldSize
        self.pixelPerUnit = pixelPerUnit
        super.init(updateGeometry())
        addComponent(external: false, type: UI.Canvas.self, gameObject: self)
    }

    public required init() {
        fatalError("init() has not been implemented, use init(size:)")
    }

    private func updateGeometry() -> SCNNode {

        let geometry = SCNGeometry.createPrimitive(.plane(width: worldSize.width, height: worldSize.height, name: "Plane"))
        let node = SCNNode(geometry: geometry)
        node.name = "Canvas"
        node.castsShadow = false

        let skScene = SKScene(size: (worldSize * pixelPerUnit).toCGSize())
        skScene.backgroundColor = .clear
        geometry.firstMaterial?.lightingModel = .constant
        geometry.firstMaterial?.diffuse.contents = skScene
        geometry.firstMaterial?.isDoubleSided = true

        return node
    }
}
