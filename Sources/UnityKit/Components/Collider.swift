import SceneKit

public typealias Collision = SCNPhysicsContact

/**
 A base class of all colliders.
 */
public class Collider: Component, Instantiable {
    override var order: ComponentOrder {
        .collider
    }

    /**
     Clones the object original and returns the clone.
     */
    open func instantiate(gameObject: GameObject) -> Self {
        let clone = type(of: self).init()
        clone.collideWithLayer = self.collideWithLayer
        clone.contactWithLayer = self.contactWithLayer
        return clone
    }

    var physicsShape: SCNPhysicsShape?

    /**
     Layers that this gameObject will collide with.
     */
    public var collideWithLayer: GameObject.Layer? {
        didSet {
            gameObject?.updateBitMask()
        }
    }

    /**
     Tell if it will trigger on contact.
     */
    public var isTrigger: Bool = false {
        didSet {
            if self.isTrigger, self.contactWithLayer == nil {
                self.contactWithLayer = self.collideWithLayer
            }
            gameObject?.updateBitMask()
        }
    }

    /**
     Layers that this gameObject will contact with.
     */
    public var contactWithLayer: GameObject.Layer? {
        didSet {
            self.isTrigger = self.contactWithLayer != nil
        }
    }

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {
        guard let gameObject
        else { return nil }

        return gameObject.getComponents(Collider.self)
            .compactMap { collider -> SCNPhysicsShape? in collider.physicsShape }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: Collision) {
        guard self.isTrigger,
              let gameObject,
              contact.nodeA.name == gameObject.name || contact.nodeB.name == gameObject.name
        else { return }

        for component in gameObject.components {
            guard let monoBehaviour = component as? MonoBehaviour
            else { continue }

            monoBehaviour.onCollisionEnter(contact)
            monoBehaviour.onTriggerEnter(self)
        }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: Collision) {
        guard self.isTrigger,
              let gameObject,
              contact.nodeA.name == gameObject.name || contact.nodeB.name == gameObject.name
        else { return }

        for component in gameObject.components {
            guard let monoBehaviour = component as? MonoBehaviour
            else { continue }

            monoBehaviour.onCollisionExit(contact)
            monoBehaviour.onTriggerExit(self)
        }
    }

    override public func start() {
        self.constructBody()
        gameObject?.updatePhysicsBody()
    }

    override public func onDestroy() {}

    func constructBody() {
        fatalError("Can't use Collider as a component, please use subclasses")
    }
}
