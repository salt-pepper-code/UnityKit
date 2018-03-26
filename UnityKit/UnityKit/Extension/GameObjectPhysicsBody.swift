
import SceneKit

extension GameObject {

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {

        return getComponents(Collider.self)
            .flatMap { (collider) -> SCNPhysicsShape? in collider.physicsShape }
    }

    private func getCollisionLayer() -> GameObject.Layer? {

        let layers = getComponents(Collider.self)
            .flatMap { (collider) -> GameObject.Layer? in collider.collideWithLayer }

        let result = layers.reduce(Layer(rawValue: 0)) { (prev, layer) -> Layer in
            guard prev != layer
                else { return layer }

            let new: Layer = [prev, layer]
            return new
        }

        return result.rawValue == 0 ? nil : result
    }

    private func getContactLayer() -> GameObject.Layer? {

        let layers = getComponents(Collider.self)
            .flatMap { (collider) -> GameObject.Layer? in collider.contactWithLayer }

        let result = layers.reduce(Layer(rawValue: 0)) { (prev, layer) -> Layer in
            guard prev != layer
                else { return layer }

            let new: Layer = [prev, layer]
            return new
        }

        return result.rawValue == 0 ? nil : result
    }

    internal func updateBitMask() {

        guard let physicsBody = node.physicsBody
            else { return }

        physicsBody.collisionBitMask = getCollisionLayer()?.rawValue ?? layer.rawValue
        physicsBody.contactTestBitMask = getContactLayer()?.rawValue ?? 0
    }

    internal func updatePhysicsBody() {

        var physicsShape: SCNPhysicsShape?
        var useGravity: Bool
        var bodyType: SCNPhysicsBodyType = .kinematic

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
        } else {
            useGravity = false
            bodyType = .dynamic
        }

        let physicsBody = SCNPhysicsBody(type: bodyType, shape: physicsShape)

        physicsBody.categoryBitMask = layer.rawValue
        physicsBody.isAffectedByGravity = useGravity

        updateBitMask()

        let rigidBody = getComponent(Rigidbody.self)

        rigidBody?.get(property: .mass).map { physicsBody.mass = $0 }
        rigidBody?.get(property: .restitution).map { physicsBody.restitution = $0 }
        rigidBody?.get(property: .friction).map { physicsBody.friction = $0 }
        rigidBody?.get(property: .rollingFriction).map { physicsBody.rollingFriction = $0 }
        rigidBody?.get(property: .damping).map { physicsBody.damping = $0 }
        rigidBody?.get(property: .angularDamping).map { physicsBody.angularDamping = $0 }
        rigidBody?.get(property: .velocity).map { physicsBody.velocity = $0 }
        rigidBody?.get(property: .angularVelocity).map { physicsBody.angularVelocity = $0 }
        rigidBody?.get(property: .velocityFactor).map { physicsBody.velocityFactor = $0 }
        rigidBody?.get(property: .angularVelocityFactor).map { physicsBody.angularVelocityFactor = $0 }
        rigidBody?.get(property: .allowsResting).map { physicsBody.allowsResting = $0 }

        node.physicsBody = nil
        node.physicsBody = physicsBody
    }
}
