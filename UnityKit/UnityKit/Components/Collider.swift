
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
    internal var physicsBodyType: SCNPhysicsBodyType = .kinematic

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
            let collider = GameObject(SCNNode(geometry: geometry)).setColor(.blue).setOpacity(0.3)
            gameObject?.addChild(collider)
            colliderGameObject = collider
        }
    }

    internal func updatePhysicsShape(_ physicsShape: SCNPhysicsShape) {

        guard let gameObject = gameObject
            else { return }

        self.physicsShape = physicsShape

        var physicsShape = physicsShape

        if let physicsShapes = getAllPhysicsShapes(),
            physicsShapes.count > 1 {

            physicsShape = SCNPhysicsShape(shapes: physicsShapes, transforms: nil)
        }

        let useGravity: Bool

        if let rigidBody = gameObject.getComponent(RigidBody.self) {
            useGravity = rigidBody.useGravity
            physicsBodyType = rigidBody.isKinematic ? .kinematic : .dynamic
        } else {
            useGravity = true
        }

        let physicsBody = SCNPhysicsBody(type: physicsBodyType, shape: physicsShape)
        physicsBody.isAffectedByGravity = useGravity

        gameObject.node.physicsBody = physicsBody
    }
}
