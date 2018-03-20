
import SceneKit

extension GameObject {

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {

        return getComponents(Collider.self)
            .flatMap { (collider) -> SCNPhysicsShape? in collider.physicsShape }
    }

    private func getCollisionLayer() -> GameObject.Layer? {

        return getComponents(Collider.self)
            .flatMap { (collider) -> GameObject.Layer in collider.collideWithLayer }
            .reduce(Layer(rawValue: 0)) { (prev, layer) -> Layer in
                guard prev.rawValue != 0,
                    prev != layer
                    else { return layer }

                return [prev, layer]
        }
    }

    private func getContactLayer() -> GameObject.Layer? {

        return getComponents(Collider.self)
            .flatMap { (collider) -> GameObject.Layer? in collider.contactWithLayer }
            .reduce(Layer(rawValue: 0)) { (prev, layer) -> Layer in
                guard prev.rawValue != 0,
                    prev != layer
                    else { return layer }

                return [prev, layer]
        }
    }

    internal func updatePhysicsBody() {
        createPhysicsBody()
    }

    internal func createPhysicsBody() {

        var physicsShape: SCNPhysicsShape?
        var useGravity: Bool
        var bodyType: SCNPhysicsBodyType = .kinematic
        var isTrigger = false

        if let physicsShapes = getAllPhysicsShapes() {
            if physicsShapes.count > 1 {
                physicsShape = SCNPhysicsShape(shapes: physicsShapes, transforms: nil)
            } else if let first = physicsShapes.first {
                physicsShape = first
            }
        }

        if let rigidBody = getComponent(Rigidbody.self) {
            useGravity = rigidBody.useGravity
            bodyType = rigidBody.isStatic ? .`static` : rigidBody.isKinematic ? .kinematic : .dynamic
            isTrigger = getContactLayer() != nil
        } else {
            useGravity = false
            bodyType = .dynamic
        }

        let physicsBody: SCNPhysicsBody

        if let physicsShape = physicsShape {
            physicsBody = SCNPhysicsBody(type: bodyType, shape: physicsShape)
        } else {
            switch bodyType {
            case .`static`:
                physicsBody = SCNPhysicsBody.static()
            case .dynamic:
                physicsBody = SCNPhysicsBody.dynamic()
            case .kinematic:
                physicsBody = SCNPhysicsBody.kinematic()
            }
        }

        physicsBody.categoryBitMask = layer.rawValue
        physicsBody.isAffectedByGravity = useGravity
        physicsBody.collisionBitMask = getCollisionLayer()?.rawValue ?? layer.rawValue
        physicsBody.contactTestBitMask = isTrigger ? (getContactLayer()?.rawValue ?? physicsBody.collisionBitMask) : 0

        if let old = node.physicsBody {

            physicsBody.mass = old.mass
            physicsBody.restitution = old.restitution
            physicsBody.friction = old.friction
            physicsBody.rollingFriction = old.rollingFriction
            physicsBody.damping = old.damping
            physicsBody.angularDamping = old.angularDamping
            physicsBody.velocity = old.velocity
            physicsBody.angularVelocity = old.angularVelocity
            physicsBody.velocityFactor = old.velocityFactor
            physicsBody.angularVelocityFactor = old.angularVelocityFactor
            physicsBody.allowsResting = old.allowsResting

        } else if let rigidBody = getComponent(Rigidbody.self) {
            
            rigidBody.get(property: .velocityFactor(.defaultValue)).map { physicsBody.velocityFactor = $0 }
            rigidBody.get(property: .angularVelocityFactor(.defaultValue)).map { physicsBody.angularVelocityFactor = $0 }
        }

        node.physicsBody = physicsBody

        if let vehicle = getComponent(Vehicle.self) {
            vehicle.updateVehicule()
        }
    }
}
