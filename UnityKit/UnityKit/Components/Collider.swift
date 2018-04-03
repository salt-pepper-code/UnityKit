
import SceneKit

public typealias Collision = SCNPhysicsContact

public class Collider: Component, Instantiable {

    open func instantiate(gameObject: GameObject) -> Self {
        let clone = type(of: self).init()
        clone.collideWithLayer = collideWithLayer
        clone.contactWithLayer = contactWithLayer
        return clone
    }

    internal var physicsShape: SCNPhysicsShape?

    public var collideWithLayer: GameObject.Layer? {
        didSet {
            gameObject?.updateBitMask()
        }
    }

    public var isTrigger: Bool = false {
        didSet {
            if isTrigger, contactWithLayer == nil {
                contactWithLayer = collideWithLayer
            }
            gameObject?.updateBitMask()
        }
    }

    public var contactWithLayer: GameObject.Layer? {
        didSet {
            isTrigger = contactWithLayer != nil
        }
    }

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {

        guard let gameObject = gameObject
            else { return nil }

        return gameObject.getComponents(Collider.self)
            .flatMap { (collider) -> SCNPhysicsShape? in collider.physicsShape }
    }

    internal func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: Collision) {

        guard isTrigger,
            let gameObject = gameObject,
            contact.nodeA.name == gameObject.name || contact.nodeB.name == gameObject.name
            else { return }

        for component in gameObject.components {
            
            guard let monoBehaviour = component as? MonoBehaviour
                else { continue }

            monoBehaviour.onCollisionEnter(contact)
            monoBehaviour.onTriggerEnter(self)
        }
    }

    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: Collision) {

        guard isTrigger,
            let gameObject = gameObject,
            contact.nodeA.name == gameObject.name || contact.nodeB.name == gameObject.name
            else { return }

        for component in gameObject.components {

            guard let monoBehaviour = component as? MonoBehaviour
                else { continue }

            monoBehaviour.onCollisionExit(contact)
            monoBehaviour.onTriggerExit(self)
        }
    }

    public override func start() {
        
        constructBody()
        gameObject?.updatePhysicsBody()
    }

    public override func onDestroy() {

    }

    internal func constructBody() {
        fatalError("Can't use Collider as a component, please use subclasses")
    }
}
