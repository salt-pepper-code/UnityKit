
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
        clone.isStatic = isStatic
        clone.isKinematic = isKinematic
        clone.useGravity = useGravity
        clone.gameObject = gameObject
        clone.constraints = constraints
        return clone
    }

    public override func awake() {
        gameObject?.updatePhysicsBody()
    }

    public var constraints: RigidbodyConstraints = .none {
        didSet {
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
                set(property: .velocityFactor(factor))
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
                set(property: .angularVelocityFactor(factor))
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

    public var isStatic: Bool = false {
        didSet {
            if isStatic != oldValue {
                gameObject?.updatePhysicsBody()
            }
        }
    }

    public var isKinematic: Bool = true {
        didSet {
            if isKinematic != oldValue {
                gameObject?.updatePhysicsBody()
            }
        }
    }

    public enum Properties {
        case mass(Float)
        case restitution(Float)
        case friction(Float)
        case rollingFriction(Float)
        case damping(Float)
        case angularDamping(Float)
        case velocity(Vector3)
        case angularVelocity(Vector4)
        case velocityFactor(Vector3)
        case angularVelocityFactor(Vector3)
        case allowsResting(Bool)
    }

    public func set(property: Properties) {

        guard let physicsBody = gameObject?.node.physicsBody
            else { return }

        switch property {
        case let .mass(value):
            physicsBody.mass = value.toCGFloat()
        case let .restitution(value):
            physicsBody.restitution = value.toCGFloat()
        case let .friction(value):
            physicsBody.friction = value.toCGFloat()
        case let .rollingFriction(value):
            physicsBody.rollingFriction = value.toCGFloat()
        case let .damping(value):
            physicsBody.damping = value.toCGFloat()
        case let .angularDamping(value):
            physicsBody.angularDamping = value.toCGFloat()
        case let .velocity(value):
            physicsBody.velocity = value
        case let .angularVelocity(value):
            physicsBody.angularVelocity = value
        case let .velocityFactor(value):
            physicsBody.velocityFactor = value
        case let .angularVelocityFactor(value):
            physicsBody.angularVelocityFactor = value
        case let .allowsResting(value):
            physicsBody.allowsResting = value
        }
    }

    public func get<T>(property: Properties) -> T? where T: Getteable {

        guard let physicsBody = gameObject?.node.physicsBody
            else { return nil }

        switch property {
        case .mass where T.self == Float.self:
            return physicsBody.mass.toFloat() as? T
        case .restitution where T.self == Float.self:
            return physicsBody.restitution.toFloat() as? T
        case .friction where T.self == Float.self:
            return physicsBody.friction.toFloat() as? T
        case .rollingFriction where T.self == Float.self:
            return physicsBody.rollingFriction.toFloat() as? T
        case .damping where T.self == Float.self:
            return physicsBody.damping.toFloat() as? T
        case .angularDamping where T.self == Float.self:
            return physicsBody.angularDamping.toFloat() as? T
        case .velocity where T.self == Vector3.self:
            return physicsBody.velocity as? T
        case .angularVelocity where T.self == Vector4.self:
            return physicsBody.angularVelocity as? T
        case .velocityFactor where T.self == Vector3.self:
            return physicsBody.velocityFactor as? T
        case .angularVelocityFactor where T.self == Vector3.self:
            return physicsBody.angularVelocityFactor as? T
        case .allowsResting where T.self == Bool.self:
            return physicsBody.allowsResting as? T
        default:
            return nil
        }
    }

    @discardableResult public func execute(_ completionBlock: (Rigidbody) -> ()) -> Rigidbody {
        completionBlock(self)
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
