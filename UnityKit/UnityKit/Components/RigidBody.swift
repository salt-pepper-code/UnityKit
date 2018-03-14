
import SceneKit

public final class RigidBody: Component {

    public var useGravity: Bool = true {

        didSet {
            guard let physicsBody = gameObject?.node.physicsBody else {

                gameObject?.node.physicsBody = SCNPhysicsBody(type: isKinematic ? .kinematic : .dynamic , shape: nil)
                return
            }
            physicsBody.isAffectedByGravity = useGravity
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
