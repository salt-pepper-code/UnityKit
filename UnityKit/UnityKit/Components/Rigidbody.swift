
import Foundation
import SceneKit

public struct RigidbodyConstraints: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = RigidbodyConstraints(rawValue: 1 << 0)
    public static let freezePositionX = RigidbodyConstraints(rawValue: 1 << 1)
    public static let freezePositionY = RigidbodyConstraints(rawValue: 1 << 2)
    public static let freezePositionZ = RigidbodyConstraints(rawValue: 1 << 3)
    public static let freezeRotationX = RigidbodyConstraints(rawValue: 1 << 4)
    public static let freezeRotationY = RigidbodyConstraints(rawValue: 1 << 5)
    public static let freezeRotationZ = RigidbodyConstraints(rawValue: 1 << 6)
    public static let freezePosition: RigidbodyConstraints = [.freezePositionX, .freezePositionY, .freezePositionZ]
    public static let freezeRotation: RigidbodyConstraints = [.freezeRotationX, .freezeRotationY, .freezeRotationZ]
    public static let freezeAll: RigidbodyConstraints = [.freezePosition, .freezeRotation]
}

public final class Rigidbody: Component, Instantiable {

    public func instantiate(gameObject: GameObject) -> Rigidbody {

        let clone = type(of: self).init()
        clone.isKinematic = isKinematic
        clone.useGravity = useGravity
        clone.gameObject = gameObject
        clone.constraints = constraints
        return clone
    }

    public override func awake() {
        gameObject?.updatePhysicsShape()
    }

    public var constraints: RigidbodyConstraints = .none {
        didSet {
            guard let gameObject = gameObject
                else { return }

            func freezeAxe(_ value: Float) -> Float {
                if value < -.pi/2 { return -.pi }
                else if value > .pi/2 { return .pi }
                else { return 0 }
            }

            if constraints.contains(.freezePositionX) ||
                constraints.contains(.freezePositionY) ||
                constraints.contains(.freezePositionZ) {

                var factor = Vector3.one
                if constraints.contains(.freezePositionX) {
                    factor.x = 0
                }
                if self.constraints.contains(.freezePositionY) {
                    factor.y = 0
                }
                if self.constraints.contains(.freezePositionZ) {
                    factor.z = 0
                }
                velocityFactor = factor

                let positionFreeze = gameObject.transform.position

                let positionConstraint = SCNTransformConstraint.positionConstraint(inWorldSpace: true) { (node, position) -> SCNVector3 in

                    var position = position
                    if self.constraints.contains(.freezePositionX) {
                        position.x = positionFreeze.x
                    }
                    if self.constraints.contains(.freezePositionY) {
                        position.y = positionFreeze.y
                    }
                    if self.constraints.contains(.freezePositionZ) {
                        position.z = positionFreeze.z
                    }
                    return position
                }

                gameObject.node.constraints = [positionConstraint]
            }

            if constraints.contains(.freezeRotationX) ||
                constraints.contains(.freezeRotationY) ||
                constraints.contains(.freezeRotationZ) {

                var factor = Vector3.one
                if constraints.contains(.freezeRotationX) {
                    factor.x = 0
                }
                if self.constraints.contains(.freezeRotationY) {
                    factor.y = 0
                }
                if self.constraints.contains(.freezeRotationZ) {
                    factor.z = 0
                }
                angularVelocityFactor = factor
            }
        }
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
            gameObject?.node.physicsBody?.isAffectedByGravity = useGravity
        }
    }

    public var isKinematic: Bool = true {
        didSet {
            gameObject?.updatePhysicsShape()
        }
    }

    public var velocity: Vector3 {

        get {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return .zero }

            return physicsBody.velocity
        }
        set {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return }

            return physicsBody.velocity = newValue
        }
    }

    public var angularVelocity: Vector4 {

        get {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return .zero }

            return physicsBody.angularVelocity
        }
        set {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return }

            return physicsBody.angularVelocity = newValue
        }
    }

    public var damping: Float {

        get {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return 0 }

            return physicsBody.damping.toFloat()
        }
        set {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return }

            return physicsBody.damping = newValue.toCGFloat()
        }
    }

    public var angularDamping: Float {

        get {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return 0 }

            return physicsBody.angularDamping.toFloat()
        }
        set {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return }

            return physicsBody.angularDamping = newValue.toCGFloat()
        }
    }

    public var velocityFactor: Vector3 {

        get {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return .zero }

            return physicsBody.velocityFactor
        }
        set {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return }

            return physicsBody.velocityFactor = newValue
        }
    }

    public var angularVelocityFactor: Vector3 {

        get {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return .zero }

            return physicsBody.angularVelocityFactor
        }
        set {
            guard let physicsBody = gameObject?.node.physicsBody
                else { return }

            return physicsBody.angularVelocityFactor = newValue
        }
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

        guard let transform = gameObject?.transform
            else { return }

        transform.position = position
    }

    public func moveRotation(_ to: Vector3) {

        guard let transform = gameObject?.transform
            else { return }

        transform.localEulerAngles = to
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
