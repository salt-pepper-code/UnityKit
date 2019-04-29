
import SpriteKit
import SceneKit

public class CanvasObject: GameObject {

    internal var skScene: SKScene {
        return node.geometry!.firstMaterial!.diffuse.contents as! SKScene
    }

    private var skView: SKView?

    @discardableResult public func set(worldSize: Size, pixelPerUnit: Float = 1) -> CanvasObject {

        getComponent(UI.Canvas.self)?
            .configure {
                $0.worldSize = worldSize
                $0.pixelPerUnit = pixelPerUnit
        }
        let result = CanvasObject.makeCanvas(worldSize: worldSize, pixelPerUnit: pixelPerUnit)
        node = result.0
        skView = result.1
        pause()
        return self
    }

    public required init(worldSize: Size, pixelPerUnit: Float = 50) {
        let result = CanvasObject.makeCanvas(worldSize: worldSize, pixelPerUnit: pixelPerUnit)
        super.init(result.0)
        skView = result.1
        pause()
        addComponent(external: false, type: UI.Canvas.self, gameObject: self)
            .configure {
                $0.worldSize = worldSize
                $0.pixelPerUnit = pixelPerUnit
        }
    }

    public func pixelSize() -> Size {
        return skScene.size.toSize()
    }

    public required init() {
        fatalError("init() has not been implemented, use init(size:)")
    }

    internal func pause() {
        skView?.isPaused = true
    }

    internal func resume() {
        skView?.isPaused = false
    }

    private static func makeCanvas(worldSize: Size, pixelPerUnit: Float) -> (SCNNode, SKView) {

        let geometry = SCNGeometry.createPrimitive(.plane(width: worldSize.width, height: worldSize.height, name: "Plane"))
        let node = SCNNode(geometry: geometry)
        node.name = "Canvas"
        node.castsShadow = false

        let view = SKView(frame: CGRect(origin: .zero, size: (worldSize * pixelPerUnit).toCGSize()))
        let skScene = SKScene(size: (worldSize * pixelPerUnit).toCGSize())
        view.presentScene(skScene)
        view.scene?.backgroundColor = .clear

        geometry.firstMaterial?.lightingModel = .constant
        geometry.firstMaterial?.diffuse.contents = view.scene
        geometry.firstMaterial?.isDoubleSided = true

        return (node, view)
    }
}
