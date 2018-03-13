
import SceneKit

extension Array {
    public mutating func appendContentsOf(newElements: [Element]) {
        newElements.forEach {
            self.append($0)
        }
    }
}

public class Collider: Component {

    private var colliderGameObject: GameObject?
    public var displayCollider: Bool = false {
        didSet {
            constructBody()
        }
    }
    private var physicsShape: SCNPhysicsShape?

    internal static func getAllColliders(in gameObject: GameObject) -> [Collider] {

        var colliders = [Collider]()
        colliders.appendContentsOf(newElements: gameObject.getComponents(BoxCollider.self))
        colliders.appendContentsOf(newElements: gameObject.getComponents(PlaneCollider.self))
        return colliders
    }

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {

        guard let gameObject = gameObject
            else { return nil }

        return Collider.getAllColliders(in: gameObject)
            .flatMap { (collider) -> SCNPhysicsShape? in collider.physicsShape }
    }

    public override func awake() {
        constructBody()
    }

    internal func constructBody() {
        fatalError("constructBody has not been implemented")
    }

    internal func createVisibleCollider(_ geometry: SCNGeometry) {

        colliderGameObject?.destroy()
        colliderGameObject = nil

        if displayCollider {
            let node = SCNNode(geometry: geometry)
            node.name = geometry.name
            let collider = GameObject(node).setColor(.blue).setOpacity(0.3)
            gameObject?.parent?.addChild(collider)
            colliderGameObject = collider
        }
    }

    internal func updatePhysicsShape(_ shape: SCNPhysicsShape? = nil) {

        guard let gameObject = gameObject
            else { return }

        if let shape = shape {
            self.physicsShape = shape
        }

        guard let shape = self.physicsShape
            else { return }

        var physicsShape = shape

        if let physicsShapes = getAllPhysicsShapes(),
            physicsShapes.count > 1 {

            physicsShape = SCNPhysicsShape(shapes: physicsShapes, transforms: nil)
        }

        let useGravity: Bool
        let bodyType: SCNPhysicsBodyType
        if let rigidBody = gameObject.getComponent(RigidBody.self) {
            useGravity = rigidBody.useGravity
            bodyType = rigidBody.isKinematic ? .kinematic : .dynamic
        } else {
            useGravity = true
            bodyType = .kinematic
        }

        let physicsBody = SCNPhysicsBody(type: bodyType, shape: physicsShape)
        physicsBody.isAffectedByGravity = useGravity

        gameObject.node.physicsBody = physicsBody
    }
}
