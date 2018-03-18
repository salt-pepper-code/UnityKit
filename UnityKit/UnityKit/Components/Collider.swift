
import SceneKit

public class Collider: Component, Instantiable {

    open func instantiate(gameObject: GameObject) -> Self {
        let clone = type(of: self).init()
        clone.collideWithLayer = collideWithLayer
        return clone
    }

    internal var physicsShape: SCNPhysicsShape?

    public var collideWithLayer: GameObject.Layer = .`default` {
        didSet {
            gameObject?.node.physicsBody?.collisionBitMask = collideWithLayer.rawValue
            gameObject?.node.physicsBody?.contactTestBitMask = collideWithLayer.rawValue
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
        gameObject?.updatePhysicsShape()
    }

    public override func onDestroy() {

    }

    internal func constructBody() {
        fatalError("Can't use Collider as a component, please use subclasses")
    }
}
