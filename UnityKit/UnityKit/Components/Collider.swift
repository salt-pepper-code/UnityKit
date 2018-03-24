
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

    @discardableResult public func execute(_ completionBlock: (Collider) -> ()) -> Collider {

        completionBlock(self)
        return self
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
            monoBehaviour.OnTriggerEnter(self)
        }
    }

    internal func testCollisions() -> Bool {

        guard let gameObject = gameObject,
            let physicsBody = gameObject.node.physicsBody,
            let scnScene = gameObject.scene?.scnScene
            else { return false }

        let physicsWorld = scnScene.physicsWorld

        physicsWorld.updateCollisionPairs()
        let contacts = physicsWorld.contactTest(with: physicsBody, options: [SCNPhysicsWorld.TestOption.searchMode: SCNPhysicsWorld.TestSearchMode.all])

        if contacts.count > 0 {
            print(contacts)
        }
        return false
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
            monoBehaviour.OnTriggerExit(self)
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
