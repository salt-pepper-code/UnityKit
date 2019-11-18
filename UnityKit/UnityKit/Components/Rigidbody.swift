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

    public var constraints: RigidbodyConstraints = .none {
        didSet {
            func freezeAxe(_ value: Float) -> Float {
                if value < -.pi/2 { return -.pi } else if value > .pi/2 { return .pi } else { return 0 }
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
        return transform?.position ?? .zero
    }

    public var localPosition: Vector3 {
        return transform?.localPosition ?? .zero
    }

    public var localRotation: Quaternion {
        return transform?.localRotation ?? .zero
    }

    public var useGravity: Bool = true {
        didSet {
            gameObject?.node.physicsBody?.isAffectedByGravity = useGravity
        }
    }

    public var isStatic: Bool = false {
        didSet {
            if isStatic {
                gameObject?.node.movabilityHint = .fixed
            } else {
                gameObject?.node.movabilityHint = .movable
            }
        }
    }

    public var isKinematic: Bool = true

    public enum Properties {
        public enum Setter {
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

        public enum Getter: Int {
            case mass
            case restitution
            case friction
            case rollingFriction
            case damping
            case angularDamping
            case velocity
            case angularVelocity
            case velocityFactor
            case angularVelocityFactor
            case allowsResting
        }
    }

    internal var properties = [Properties.Getter: Any]()

    public required init() {
        super.init()
        self.ignoreUpdates = true
    }

    public func set(property: Properties.Setter) {
        let physicsBody = gameObject?.node.physicsBody

        switch property {
        case let .mass(value):
            properties[.mass] = value.toCGFloat()
            physicsBody?.mass = value.toCGFloat()
        case let .restitution(value):
            properties[.restitution] = value.toCGFloat()
            physicsBody?.restitution = value.toCGFloat()
        case let .friction(value):
            properties[.friction] = value.toCGFloat()
            physicsBody?.friction = value.toCGFloat()
        case let .rollingFriction(value):
            properties[.rollingFriction] = value.toCGFloat()
            physicsBody?.rollingFriction = value.toCGFloat()
        case let .damping(value):
            properties[.damping] = value.toCGFloat()
            physicsBody?.damping = value.toCGFloat()
        case let .angularDamping(value):
            properties[.angularDamping] = value.toCGFloat()
            physicsBody?.angularDamping = value.toCGFloat()
        case let .velocity(value):
            properties[.velocity] = value
            physicsBody?.velocity = value
        case let .angularVelocity(value):
            properties[.angularVelocity] = value
            physicsBody?.angularVelocity = value
        case let .velocityFactor(value):
            properties[.velocityFactor] = value
            physicsBody?.velocityFactor = value
        case let .angularVelocityFactor(value):
            properties[.angularVelocityFactor] = value
            physicsBody?.angularVelocityFactor = value
        case let .allowsResting(value):
            properties[.allowsResting] = value
            physicsBody?.allowsResting = value
        }
    }

    public func get<T>(property: Properties.Getter) -> T? where T: Getteable {
        let physicsBody = gameObject?.node.physicsBody

        switch property {
        case .mass:
            return properties[.mass] as? T ?? physicsBody?.mass.toFloat() as? T
        case .restitution:
            return properties[.restitution] as? T ?? physicsBody?.restitution.toFloat() as? T
        case .friction:
            return properties[.friction] as? T ?? physicsBody?.friction.toFloat() as? T
        case .rollingFriction:
            return properties[.rollingFriction] as? T ?? physicsBody?.rollingFriction.toFloat() as? T
        case .damping:
            return properties[.damping] as? T ?? physicsBody?.damping.toFloat() as? T
        case .angularDamping:
            return properties[.angularDamping] as? T ?? physicsBody?.angularDamping.toFloat() as? T
        case .velocity:
            return properties[.velocity] as? T ?? physicsBody?.velocity as? T
        case .angularVelocity:
            return properties[.angularVelocity] as? T ?? physicsBody?.angularVelocity as? T
        case .velocityFactor:
            return properties[.velocityFactor] as? T ?? physicsBody?.velocityFactor as? T
        case .angularVelocityFactor:
            return properties[.angularVelocityFactor] as? T ?? physicsBody?.angularVelocityFactor as? T
        case .allowsResting:
            return properties[.allowsResting] as? T ?? physicsBody?.allowsResting as? T
        }
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
        - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (Rigidbody) -> Void) -> Rigidbody {
        configurationBlock(self)
        return self
    }

    public override func onDestroy() {
        gameObject?.node.physicsBody = nil
    }

    public override func start() {
        if let _ = getComponent(Collider.self) {
            return
        }
        gameObject?.updatePhysicsBody()
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

    public func addExplosionForce(explosionForce: Float, explosionPosition: Vector3, explosionRadius: Float, replacePosition: Vector3Nullable? = nil) {
        guard let gameObject = gameObject,
            let transform = gameObject.transform,
            let physicsBody = gameObject.node.physicsBody
            else { return }

        var from = explosionPosition
        var to = transform.position

        replacePosition?.x.map { from.x = $0; to.x = $0 }
        replacePosition?.y.map { from.y = $0; to.y = $0 }
        replacePosition?.z.map { from.z = $0; to.z = $0 }

        let heading = to - from
        let distance = heading.magnitude()
        var direction = (heading / distance).normalized()

        direction *= explosionForce / distance

        physicsBody.applyForce(direction, asImpulse: true)
    }

    public func clearAllForces() {
        guard let physicsBody = gameObject?.node.physicsBody
            else { return }

        physicsBody.clearAllForces()
    }
}
