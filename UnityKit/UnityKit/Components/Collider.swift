
import SceneKit

public class Collider: Component, Instantiable {

    open func instantiate(gameObject: GameObject) -> Self {
        return type(of: self).init()
    }

    private var physicsShape: SCNPhysicsShape?
    public var collideWithLayer: GameObject.Layer = .all {
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
        updatePhysicsShape()
    }

    internal func constructBody() {
        fatalError("Can't use Collider, please use subclasses")
    }

    internal final func updatePhysicsShape(_ shape: SCNPhysicsShape? = nil) {

        guard let gameObject = gameObject
            else { return }

        if let shape = shape {
            self.physicsShape = shape
        }

        var physicsShape = self.physicsShape

        if let physicsShapes = getAllPhysicsShapes(),
            physicsShapes.count > 1 {

            physicsShape = SCNPhysicsShape(shapes: physicsShapes, transforms: nil)
        }

        let useGravity: Bool
        let bodyType: SCNPhysicsBodyType

        if let rigidBody = gameObject.getComponent(Rigidbody.self) {
            useGravity = rigidBody.useGravity
            bodyType = rigidBody.isKinematic ? .kinematic : .dynamic
        } else {
            useGravity = true
            bodyType = .kinematic
        }

        if let physicsShape = physicsShape {

            let physicsBody = SCNPhysicsBody(type: bodyType, shape: physicsShape)
            physicsBody.isAffectedByGravity = useGravity
            physicsBody.collisionBitMask = collideWithLayer.rawValue

            gameObject.node.physicsBody = physicsBody

        } else {

            gameObject.node.physicsBody = SCNPhysicsBody(type: bodyType, shape: nil)
        }
    }
}
