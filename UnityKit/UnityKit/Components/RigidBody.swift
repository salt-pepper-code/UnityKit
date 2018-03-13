
import SceneKit

public final class RigidBody: Component {

    public var useGravity: Bool {

        get {
            guard let gameObject = gameObject,
                let physicsBody = gameObject.node.physicsBody
                else { return true }

            return physicsBody.isAffectedByGravity
        }
        set {
            gameObject?.node.physicsBody?.isAffectedByGravity = newValue
        }
    }

    public var isKinematic: Bool = true {

        didSet {
            guard let gameObject = gameObject
                else { return }

            Collider.getAllColliders(in: gameObject).forEach { collider in
                collider.updatePhysicsShape()
            }
        }
    }

    public func set(isKinematic: Bool) -> RigidBody {
        self.isKinematic = isKinematic
        return self
    }

    public func set(useGravity: Bool) -> RigidBody {
        self.useGravity = useGravity
        return self
    }
}
