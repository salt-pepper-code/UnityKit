
import SceneKit

public class Collider: Component, Instantiable {

    open func instantiate(gameObject: GameObject) -> Self {
        let clone = type(of: self).init()
        clone.collideWithLayer = collideWithLayer
        clone.triggerWithLayer = triggerWithLayer
        return clone
    }

    internal var physicsShape: SCNPhysicsShape?

    public var collideWithLayer: GameObject.Layer = .`default` {
        didSet {
            gameObject?.updatePhysicsBody()
        }
    }

    public var isTrigger: Bool = false {
        didSet {
            gameObject?.updatePhysicsBody()
        }
    }

    public var triggerWithLayer: GameObject.Layer? {
        didSet {
            isTrigger = triggerWithLayer != nil
        }
    }

    public func execute(_ completionBlock: (Collider) -> ()) {
        completionBlock(self)
    }

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {

        guard let gameObject = gameObject
            else { return nil }

        return gameObject.getComponents(Collider.self)
            .flatMap { (collider) -> SCNPhysicsShape? in collider.physicsShape }
    }

    public override func awake() {
        gameObject?.node.physicsBody?.contactTestBitMask = 0
        constructBody()
        gameObject?.updatePhysicsBody()
    }

    public override func onDestroy() {

    }

    internal func constructBody() {
        fatalError("Can't use Collider as a component, please use subclasses")
    }
}
