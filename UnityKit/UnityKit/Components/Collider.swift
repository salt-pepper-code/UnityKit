
import SceneKit

public class Collider: Component, Instantiable {

    open func instantiate(gameObject: GameObject) -> Self {
        return type(of: self).init()
    }

    internal var physicsShape: SCNPhysicsShape?

    public var collideWithLayer: GameObject.Layer = .`default` {
        didSet {
            gameObject?.node.physicsBody?.collisionBitMask = collideWithLayer.rawValue
        }
    }

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {

        guard let gameObject = gameObject
            else { return nil }

        return gameObject.getComponents(Collider.self)
            .flatMap { (collider) -> SCNPhysicsShape? in collider.physicsShape }
    }

    public override func awake() {
        constructBody()
    }

    public override func onDestroy() {
        physicsShape = nil
        gameObject?.updatePhysicsShape()
    }

    internal func constructBody() {
        fatalError("Can't use Collider, please use subclasses")
    }
}
