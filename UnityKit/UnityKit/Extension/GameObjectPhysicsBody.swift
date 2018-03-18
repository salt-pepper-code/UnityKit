
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
            .flatMap { (collider) -> GameObject.Layer? in collider.triggerWithLayer }
            .reduce(Layer(rawValue: 0)) { (prev, layer) -> Layer in
                guard prev.rawValue != 0,
                    prev != layer
                    else { return layer }

                return [prev, layer]
        }
    }

    internal func updatePhysicsBody() {

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
            bodyType = rigidBody.isKinematic ? .kinematic : .dynamic
            isTrigger = getContactLayer() != nil
        } else {
            useGravity = false
            bodyType = .dynamic
        }

        let physicsBody: SCNPhysicsBody

        if let physicsShape = physicsShape {
            physicsBody = SCNPhysicsBody(type: bodyType, shape: physicsShape)
        } else {
            physicsBody = SCNPhysicsBody(type: bodyType, shape: nil)
        }

        if let rigidBody = getComponent(Rigidbody.self) {
            physicsBody.velocityFactor = rigidBody.velocityFactor
            physicsBody.angularVelocityFactor = rigidBody.angularVelocityFactor
        }

        physicsBody.categoryBitMask = layer.rawValue
        physicsBody.isAffectedByGravity = useGravity
        physicsBody.collisionBitMask = getCollisionLayer()?.rawValue ?? layer.rawValue
        physicsBody.contactTestBitMask = isTrigger ? (getContactLayer()?.rawValue ?? physicsBody.collisionBitMask) : 0
        node.physicsBody = physicsBody
    }
}
