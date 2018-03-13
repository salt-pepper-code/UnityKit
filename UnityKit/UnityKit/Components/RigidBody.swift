
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

    public var isKinematic: Bool {

        get {
            guard let gameObject = gameObject
                else { return false }

            let kinematic: Bool? = Collider.getAllColliders(in: gameObject).reduce(nil) { (previous, collider) -> Bool? in

                let physicsBodyType = collider.physicsBodyType

                guard let previous = previous
                    else { return physicsBodyType == .kinematic }

                return previous && physicsBodyType == .kinematic
            }

            return kinematic ?? false
        }
        set {
            guard let gameObject = gameObject
                else { return }

            Collider.getAllColliders(in: gameObject).forEach { collider in
                collider.physicsBodyType = newValue ? .kinematic : .dynamic
            }
        }
    }
}
