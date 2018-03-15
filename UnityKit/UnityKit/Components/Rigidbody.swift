
import SceneKit

public final class Rigidbody: Component, Instantiable {

    public func instantiate() -> Self {
        return type(of: self).init()
    }

    public var position: Vector3 {

        guard let transform = transform
            else { return .zero }

        return transform.position
    }

    public var rotation: Quaternion {

        guard let transform = transform
            else { return .zero }

        return transform.localRotation
    }

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

    @discardableResult public func set(isKinematic: Bool) -> Rigidbody {

        self.isKinematic = isKinematic
        return self
    }

    @discardableResult public func set(useGravity: Bool) -> Rigidbody {

        self.useGravity = useGravity
        return self
    }

    public func movePosition(_ position: Vector3) {

        guard let node = gameObject?.node
            else { return }

        node.position = position
    }

    public func moveRotation(_ rotation: Vector4) {

        guard let node = gameObject?.node
            else { return }

        node.rotation = rotation
    }

    public func addForce(_ direction: Vector3) {

        guard let physicsBody = gameObject?.node.physicsBody
            else { return }

        physicsBody.applyForce(direction, asImpulse: true)
    }

    public func addTorque(_ torque: Vector4, asImpulse: Bool) {

        guard let physicsBody = gameObject?.node.physicsBody
            else { return }

        physicsBody.applyTorque(torque, asImpulse: asImpulse)
    }

    public func clearAllForces() {

        guard let physicsBody = gameObject?.node.physicsBody
            else { return }

        physicsBody.clearAllForces()
    }
}
