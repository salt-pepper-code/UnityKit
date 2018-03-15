
import SceneKit

public final class RigidBody: Component {

    public var useGravity: Bool = true {

        didSet {
            updatePhysicsBody()
        }
    }

    public var isKinematic: Bool = true {

        didSet {
            guard let gameObject = gameObject
                else { return }

            let colliders = gameObject.getComponents(Collider.self)

            guard colliders.count > 0 else {

                gameObject.node.physicsBody = nil
                updatePhysicsBody()
                return
            }

            gameObject.getComponents(Collider.self).forEach { collider in
                collider.updatePhysicsShape()
            }
        }
    }

    private func updatePhysicsBody() {

        guard let physicsBody = gameObject?.node.physicsBody else {
            gameObject?.node.physicsBody = SCNPhysicsBody(type: isKinematic ? .kinematic : .dynamic , shape: nil)
            return
        }

        physicsBody.isAffectedByGravity = useGravity
    }

    public func set(isKinematic: Bool) -> RigidBody {

        self.isKinematic = isKinematic
        return self
    }

    public func set(useGravity: Bool) -> RigidBody {

        self.useGravity = useGravity
        return self
    }

    public func addForce(_ direction: Vector3) {

        guard let physicsBody = gameObject?.node.physicsBody else {
            return
        }

        physicsBody.applyForce(direction, asImpulse: true)
    }

    public func addTorque(_ torque: Vector4) {

        guard let physicsBody = gameObject?.node.physicsBody else {
            return
        }

        physicsBody.applyTorque(torque, asImpulse: true)
    }

    public func clearAllForces() {

        guard let physicsBody = gameObject?.node.physicsBody else {
            return
        }

        physicsBody.clearAllForces()
    }
}
