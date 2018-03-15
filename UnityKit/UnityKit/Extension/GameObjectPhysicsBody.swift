
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

    internal func updatePhysicsShape() {

        var physicsShape: SCNPhysicsShape?
        var useGravity: Bool
        var bodyType: SCNPhysicsBodyType = .kinematic
        let collisionLayer = getCollisionLayer() ?? layer

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
        } else {
            useGravity = false
            bodyType = .dynamic
        }

        if let physicsShape = physicsShape {

            let physicsBody = SCNPhysicsBody(type: bodyType, shape: physicsShape)
            physicsBody.isAffectedByGravity = useGravity
            physicsBody.collisionBitMask = collisionLayer.rawValue
            node.physicsBody = physicsBody

        } else {

            let physicsBody = SCNPhysicsBody(type: bodyType, shape: nil)
            physicsBody.isAffectedByGravity = useGravity
            physicsBody.collisionBitMask = collisionLayer.rawValue
            node.physicsBody = physicsBody
        }
    }
}
