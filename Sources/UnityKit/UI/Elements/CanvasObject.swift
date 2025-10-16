import SceneKit
import SpriteKit

public class CanvasObject: GameObject {
    var skScene: SKScene {
        guard let scene = node.geometry?.firstMaterial?.diffuse.contents as? SKScene else {
            fatalError("Should have a scene")
        }
        return scene
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
        self.skView = result.1
        self.pause()
        return self
    }

    public required init(worldSize: Size, pixelPerUnit: Float = 50) {
        let result = CanvasObject.makeCanvas(worldSize: worldSize, pixelPerUnit: pixelPerUnit)
        super.init(result.0)
        self.skView = result.1
        self.pause()
        addComponent(external: false, type: UI.Canvas.self, gameObject: self)
            .configure {
                $0.worldSize = worldSize
                $0.pixelPerUnit = pixelPerUnit
            }
    }

    public func pixelSize() -> Size {
        return self.skScene.size.toSize()
    }

    public required init() {
        fatalError("init() has not been implemented, use init(size:)")
    }

    func pause() {
        self.skView?.isPaused = true
    }

    func resume() {
        self.skView?.isPaused = false
    }

    private static func makeCanvas(worldSize: Size, pixelPerUnit: Float) -> (SCNNode, SKView) {
        let geometry = SCNGeometry.createPrimitive(.plane(width: worldSize.width, height: worldSize.height))
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
