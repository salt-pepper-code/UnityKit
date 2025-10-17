import Foundation
import SceneKit

/// Controls which degrees of freedom are allowed for the simulation of a Rigidbody.
///
/// Use these constraints to freeze position or rotation along specific axes, preventing
/// the physics engine from moving the rigidbody in those directions. This is useful for
/// creating 2D movement in a 3D space, preventing rotation, or locking specific axes.
///
/// ## Example
/// ```swift
/// // Create a 2D character that can only move on X and Y axes
/// rigidbody.constraints = [.freezePositionZ, .freezeRotationX, .freezeRotationY]
///
/// // Prevent all rotation but allow full movement
/// rigidbody.constraints = .freezeRotation
/// ```
public struct RigidbodyConstraints: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// No constraints applied - full freedom of movement and rotation.
    public static let none = RigidbodyConstraints(rawValue: 1 << 0)

    /// Freeze movement along the X axis.
    public static let freezePositionX = RigidbodyConstraints(rawValue: 1 << 1)

    /// Freeze movement along the Y axis.
    public static let freezePositionY = RigidbodyConstraints(rawValue: 1 << 2)

    /// Freeze movement along the Z axis.
    public static let freezePositionZ = RigidbodyConstraints(rawValue: 1 << 3)

    /// Freeze rotation around the X axis.
    public static let freezeRotationX = RigidbodyConstraints(rawValue: 1 << 4)

    /// Freeze rotation around the Y axis.
    public static let freezeRotationY = RigidbodyConstraints(rawValue: 1 << 5)

    /// Freeze rotation around the Z axis.
    public static let freezeRotationZ = RigidbodyConstraints(rawValue: 1 << 6)

    /// Freeze all positional movement (combination of X, Y, and Z position constraints).
    public static let freezePosition: RigidbodyConstraints = [.freezePositionX, .freezePositionY, .freezePositionZ]

    /// Freeze all rotation (combination of X, Y, and Z rotation constraints).
    public static let freezeRotation: RigidbodyConstraints = [.freezeRotationX, .freezeRotationY, .freezeRotationZ]

    /// Freeze all movement and rotation completely.
    public static let freezeAll: RigidbodyConstraints = [.freezePosition, .freezeRotation]
}

/// Control of an object's position and rotation through physics simulation.
///
/// Adding a ``Rigidbody`` component to a GameObject puts its motion under the control of
/// the physics engine. Even without additional code, a Rigidbody object will be affected by
/// gravity and will react to collisions when the appropriate ``Collider`` component is present.
///
/// ## Overview
///
/// The Rigidbody component provides a scripting API that lets you apply forces, torques,
/// and control object motion in a physically realistic way. For example, a car's behavior
/// can be specified in terms of forces applied by the wheels, and the physics engine
/// handles acceleration, deceleration, and collision response automatically.
///
/// ## Physics Behavior Types
///
/// - **Dynamic** (`isKinematic = false`): Fully simulated by physics, affected by forces and collisions
/// - **Kinematic** (`isKinematic = true`): Not affected by forces, but can affect dynamic objects
/// - **Static** (`isStatic = true`): Completely immovable, optimized for non-moving objects
///
/// ## Best Practices
///
/// ### Timing
/// Apply forces and modify physics properties in `fixedUpdate()` rather than `update()`.
/// Physics updates occur at fixed time steps that don't coincide with frame updates, and
/// `fixedUpdate()` is called immediately before each physics update.
///
/// ### Scale Considerations
/// The default gravity settings assume one world unit equals one meter. Keep your objects
/// at realistic scales (e.g., a car should be about 4 units = 4 meters). Incorrect scaling
/// can make physics appear to run in "slow motion" because large-scale objects fall more slowly.
///
/// ## Topics
///
/// ### Physics Simulation Control
///
/// - ``useGravity``
/// - ``isKinematic``
/// - ``isStatic``
/// - ``constraints``
///
/// ### Physical Properties
///
/// - ``mass``
/// - ``friction``
/// - ``restitution``
/// - ``damping``
/// - ``angularDamping``
///
/// ### Velocity and Movement
///
/// - ``velocity``
/// - ``angularVelocity``
/// - ``movePosition(_:)``
/// - ``moveRotation(_:)``
///
/// ### Applying Forces
///
/// - ``addForce(_:)``
/// - ``addTorque(_:asImpulse:)``
/// - ``addExplosionForce(explosionForce:explosionPosition:explosionRadius:replacePosition:)``
/// - ``clearAllForces()``
///
/// ## Example: Simple Physics Object
/// ```swift
/// let ball = GameObject(name: "Ball")
/// let rigidbody = ball.addComponent(Rigidbody.self)
/// rigidbody.useGravity = true
/// rigidbody.mass = 1.0
/// rigidbody.restitution = 0.8 // Bouncy ball
/// ```
///
/// ## Example: Applying Forces
/// ```swift
/// class PlayerController: MonoBehaviour {
///     var moveForce: Float = 10.0
///     var rigidbody: Rigidbody?
///
///     override func start() {
///         rigidbody = getComponent(Rigidbody.self)
///     }
///
///     override func fixedUpdate() {
///         let input = getInput() // Your input system
///         let force = Vector3(input.x * moveForce, 0, input.y * moveForce)
///         rigidbody?.addForce(force)
///     }
/// }
/// ```
///
/// ## Example: Kinematic Character Controller
/// ```swift
/// let character = GameObject(name: "Character")
/// let rigidbody = character.addComponent(Rigidbody.self)
/// rigidbody.isKinematic = true // Not affected by forces
/// rigidbody.useGravity = false
/// rigidbody.constraints = .freezeRotation // Prevent tipping over
///
/// // Move using direct position changes
/// rigidbody.movePosition(newPosition)
/// ```
public final class Rigidbody: Component, Instantiable {
    override var order: ComponentOrder {
        return .rigidbody
    }

    /// Creates a copy of this Rigidbody for instantiation.
    ///
    /// This method is called internally when cloning GameObjects with Rigidbody components.
    /// It copies all physics properties to the new instance.
    ///
    /// - Parameter gameObject: The GameObject that will own the cloned Rigidbody.
    /// - Returns: A new Rigidbody instance with copied properties.
    public func instantiate(gameObject: GameObject) -> Rigidbody {
        let clone = type(of: self).init()
        clone.isStatic = self.isStatic
        clone.isKinematic = self.isKinematic
        clone.useGravity = self.useGravity
        clone.gameObject = gameObject
        clone.constraints = self.constraints
        return clone
    }

    /// Constraints on the rigidbody's movement and rotation.
    ///
    /// Use constraints to restrict which axes the physics simulation can modify.
    /// This is useful for creating 2D physics in 3D space, preventing unwanted rotation,
    /// or locking movement along specific axes.
    ///
    /// When constraints are applied, the corresponding velocity factors are automatically
    /// adjusted to enforce the restrictions.
    ///
    /// ## Example
    /// ```swift
    /// // 2D platformer physics
    /// rigidbody.constraints = [.freezePositionZ, .freezeRotationX, .freezeRotationY]
    ///
    /// // Prevent rotation entirely
    /// rigidbody.constraints = .freezeRotation
    /// ```
    public var constraints: RigidbodyConstraints = .none {
        didSet {
            func freezeAxe(_ value: Float) -> Float {
                if value < -.pi / 2 { return -.pi } else if value > .pi / 2 { return .pi } else { return 0 }
            }

            if self.constraints.contains(.freezePositionX) ||
                self.constraints.contains(.freezePositionY) ||
                self.constraints.contains(.freezePositionZ)
            {
                var factor = Vector3.one
                if self.constraints.contains(.freezePositionX) {
                    factor.x = 0
                }
                if self.constraints.contains(.freezePositionY) {
                    factor.y = 0
                }
                if self.constraints.contains(.freezePositionZ) {
                    factor.z = 0
                }
                self.velocityFactor = factor
            }

            if self.constraints.contains(.freezeRotationX) ||
                self.constraints.contains(.freezeRotationY) ||
                self.constraints.contains(.freezeRotationZ)
            {
                var factor = Vector3.one
                if self.constraints.contains(.freezeRotationX) {
                    factor.x = 0
                }
                if self.constraints.contains(.freezeRotationY) {
                    factor.y = 0
                }
                if self.constraints.contains(.freezeRotationZ) {
                    factor.z = 0
                }
                self.angularVelocityFactor = factor
            }
        }
    }

    /// The world space position of the rigidbody's transform.
    ///
    /// This is a convenience property that accesses the position from the GameObject's transform.
    public var position: Vector3 {
        transform?.position ?? .zero
    }

    /// The local space position of the rigidbody's transform relative to its parent.
    ///
    /// This is a convenience property that accesses the local position from the GameObject's transform.
    public var localPosition: Vector3 {
        transform?.localPosition ?? .zero
    }

    /// The local space rotation of the rigidbody's transform as a quaternion.
    ///
    /// This is a convenience property that accesses the local rotation from the GameObject's transform.
    public var localRotation: Quaternion {
        transform?.localRotation ?? .zero
    }

    /// Controls whether gravity affects this rigidbody.
    ///
    /// When `true`, the rigidbody is affected by the scene's gravity settings and will fall
    /// downward. When `false`, the object will not be pulled by gravity, useful for floating
    /// objects, flying characters, or space environments.
    ///
    /// ## Example
    /// ```swift
    /// // Flying drone that ignores gravity
    /// let drone = GameObject(name: "Drone")
    /// let rb = drone.addComponent(Rigidbody.self)
    /// rb.useGravity = false
    /// ```
    public var useGravity: Bool = true {
        didSet {
            gameObject?.node.physicsBody?.isAffectedByGravity = self.useGravity
        }
    }

    /// Controls whether this rigidbody is completely static and immovable.
    ///
    /// When `true`, the object is treated as a static, non-moving obstacle that will
    /// never be moved by physics. This provides performance optimizations for objects
    /// like walls, floors, and other permanent level geometry.
    ///
    /// Static objects should not be moved at runtime. For objects that need to move
    /// but shouldn't be affected by physics, use ``isKinematic`` instead.
    ///
    /// ## Example
    /// ```swift
    /// // Static wall
    /// let wall = GameObject(name: "Wall")
    /// let rb = wall.addComponent(Rigidbody.self)
    /// rb.isStatic = true
    /// ```
    public var isStatic: Bool = false {
        didSet {
            if self.isStatic {
                gameObject?.node.movabilityHint = .fixed
            } else {
                gameObject?.node.movabilityHint = .movable
            }
        }
    }

    /// Controls whether this rigidbody is kinematic.
    ///
    /// Kinematic rigidbodies are not affected by forces, gravity, or collisions from
    /// other objects, but they can affect dynamic rigidbodies. This is useful for
    /// character controllers, moving platforms, or objects with scripted animation.
    ///
    /// When `true`:
    /// - Not affected by forces or gravity
    /// - Can be moved by directly setting transform properties
    /// - Will push dynamic objects it collides with
    ///
    /// When `false` (dynamic):
    /// - Fully simulated by physics
    /// - Affected by forces, gravity, and collisions
    ///
    /// ## Example
    /// ```swift
    /// // Moving platform
    /// let platform = GameObject(name: "Platform")
    /// let rb = platform.addComponent(Rigidbody.self)
    /// rb.isKinematic = true // Won't fall or be pushed
    /// rb.useGravity = false
    ///
    /// // In your script, move it directly
    /// platform.transform.position = newPosition
    /// ```
    public var isKinematic: Bool = true

    // MARK: - Physics Properties

    /// The mass of the rigidbody in kilograms.
    ///
    /// Mass affects how the object responds to forces and collisions. Heavier objects
    /// require more force to move and have more momentum. The mass should be proportional
    /// to the object's size and material density.
    ///
    /// - Default: 1.0
    ///
    /// ## Example
    /// ```swift
    /// let boulder = GameObject(name: "Boulder")
    /// let rb = boulder.addComponent(Rigidbody.self)
    /// rb.mass = 100.0 // Very heavy object
    ///
    /// let feather = GameObject(name: "Feather")
    /// let rb2 = feather.addComponent(Rigidbody.self)
    /// rb2.mass = 0.01 // Very light object
    /// ```
    public var mass: Float {
        get {
            return self.properties[.mass] as? Float ?? gameObject?.node.physicsBody?.mass.toFloat() ?? 1.0
        }
        set {
            self.properties[.mass] = newValue
            gameObject?.node.physicsBody?.mass = newValue.toCGFloat()
        }
    }

    /// The bounciness (elasticity) of the rigidbody.
    ///
    /// Also known as the coefficient of restitution, this value determines how much
    /// energy is retained after a collision. A value of 0 means no bounce (inelastic),
    /// while a value of 1 means perfect bounce with no energy loss.
    ///
    /// - Range: 0.0 to 1.0
    /// - Default: 0.0
    ///
    /// ## Example
    /// ```swift
    /// // Bouncy rubber ball
    /// let ball = GameObject(name: "Ball")
    /// let rb = ball.addComponent(Rigidbody.self)
    /// rb.restitution = 0.9
    ///
    /// // Non-bouncy box
    /// let box = GameObject(name: "Box")
    /// let rb2 = box.addComponent(Rigidbody.self)
    /// rb2.restitution = 0.1
    /// ```
    public var restitution: Float {
        get {
            return self.properties[.restitution] as? Float ?? gameObject?.node.physicsBody?.restitution.toFloat() ?? 0.0
        }
        set {
            self.properties[.restitution] = newValue
            gameObject?.node.physicsBody?.restitution = newValue.toCGFloat()
        }
    }

    /// The friction coefficient for sliding contacts.
    ///
    /// Friction resists movement when surfaces slide against each other. Higher values
    /// create more resistance to sliding motion.
    ///
    /// - Range: 0.0 (frictionless) to 1.0 (maximum friction)
    /// - Default: 0.5
    ///
    /// ## Example
    /// ```swift
    /// // Slippery ice
    /// let ice = GameObject(name: "Ice")
    /// let rb = ice.addComponent(Rigidbody.self)
    /// rb.friction = 0.05
    ///
    /// // Sticky rubber
    /// let rubber = GameObject(name: "Rubber")
    /// let rb2 = rubber.addComponent(Rigidbody.self)
    /// rb2.friction = 0.9
    /// ```
    public var friction: Float {
        get {
            return self.properties[.friction] as? Float ?? gameObject?.node.physicsBody?.friction.toFloat() ?? 0.5
        }
        set {
            self.properties[.friction] = newValue
            gameObject?.node.physicsBody?.friction = newValue.toCGFloat()
        }
    }

    /// The rolling friction coefficient for rotating objects.
    ///
    /// Rolling friction creates resistance when spherical or cylindrical objects roll
    /// across surfaces. This is typically much lower than sliding friction.
    ///
    /// - Range: 0.0 (no rolling resistance) to 1.0 (high resistance)
    /// - Default: 0.0
    ///
    /// ## Example
    /// ```swift
    /// // Bowling ball with realistic rolling friction
    /// let ball = GameObject(name: "BowlingBall")
    /// let rb = ball.addComponent(Rigidbody.self)
    /// rb.rollingFriction = 0.01
    /// ```
    public var rollingFriction: Float {
        get {
            return self.properties[.rollingFriction] as? Float ?? gameObject?.node.physicsBody?.rollingFriction
                .toFloat() ?? 0.0
        }
        set {
            self.properties[.rollingFriction] = newValue
            gameObject?.node.physicsBody?.rollingFriction = newValue.toCGFloat()
        }
    }

    /// The linear damping applied to velocity.
    ///
    /// Damping reduces velocity over time, simulating air resistance or drag. Higher
    /// values cause the object to slow down more quickly. Use this to create air
    /// resistance effects or control how quickly objects come to rest.
    ///
    /// - Range: 0.0 (no damping) to 1.0 (high damping)
    /// - Default: 0.1
    ///
    /// ## Example
    /// ```swift
    /// // Object in water (high drag)
    /// let underwater = GameObject(name: "Underwater")
    /// let rb = underwater.addComponent(Rigidbody.self)
    /// rb.damping = 0.8
    /// ```
    public var damping: Float {
        get {
            return self.properties[.damping] as? Float ?? gameObject?.node.physicsBody?.damping.toFloat() ?? 0.1
        }
        set {
            self.properties[.damping] = newValue
            gameObject?.node.physicsBody?.damping = newValue.toCGFloat()
        }
    }

    /// The angular damping applied to rotational velocity.
    ///
    /// Angular damping reduces rotational speed over time. Higher values cause spinning
    /// objects to slow down more quickly. This is useful for controlling how long
    /// objects continue to spin after being set in motion.
    ///
    /// - Range: 0.0 (no damping) to 1.0 (high damping)
    /// - Default: 0.1
    ///
    /// ## Example
    /// ```swift
    /// // Spinning top that slows down gradually
    /// let top = GameObject(name: "SpinningTop")
    /// let rb = top.addComponent(Rigidbody.self)
    /// rb.angularDamping = 0.05
    /// ```
    public var angularDamping: Float {
        get {
            return self.properties[.angularDamping] as? Float ?? gameObject?.node.physicsBody?.angularDamping
                .toFloat() ?? 0.1
        }
        set {
            self.properties[.angularDamping] = newValue
            gameObject?.node.physicsBody?.angularDamping = newValue.toCGFloat()
        }
    }

    /// The linear velocity vector of the rigidbody in world space.
    ///
    /// The velocity represents the rate of change of position per second. You can read this
    /// to check how fast an object is moving, or set it to instantly change the object's speed
    /// and direction. Modifying velocity directly bypasses physics forces.
    ///
    /// ## Example
    /// ```swift
    /// // Set object to move forward at 10 units per second
    /// rigidbody.velocity = Vector3(0, 0, 10)
    ///
    /// // Check if object is moving fast
    /// if rigidbody.velocity.magnitude() > 20 {
    ///     print("Moving too fast!")
    /// }
    ///
    /// // Stop all movement
    /// rigidbody.velocity = .zero
    /// ```
    public var velocity: Vector3 {
        get {
            return self.properties[.velocity] as? Vector3 ?? gameObject?.node.physicsBody?.velocity ?? .zero
        }
        set {
            self.properties[.velocity] = newValue
            gameObject?.node.physicsBody?.velocity = newValue
        }
    }

    /// The angular velocity of the rigidbody as a four-component vector.
    ///
    /// Angular velocity represents the rotation rate around an axis. The direction of the
    /// vector indicates the axis of rotation, and the magnitude indicates the rotation speed
    /// in radians per second.
    ///
    /// ## Example
    /// ```swift
    /// // Spin object around Y axis
    /// rigidbody.angularVelocity = Vector4(0, 2, 0, 0)
    ///
    /// // Stop all rotation
    /// rigidbody.angularVelocity = .zero
    /// ```
    public var angularVelocity: Vector4 {
        get {
            return self.properties[.angularVelocity] as? Vector4 ?? gameObject?.node.physicsBody?
                .angularVelocity ?? .zero
        }
        set {
            self.properties[.angularVelocity] = newValue
            gameObject?.node.physicsBody?.angularVelocity = newValue
        }
    }

    /// Multiplier for velocity along each axis (used for constraints).
    ///
    /// This factor is automatically set when applying ``constraints`` to freeze position.
    /// Each component scales the velocity along that axis, where 0 completely prevents
    /// movement and 1 allows full movement.
    ///
    /// - Default: Vector3(1, 1, 1)
    public var velocityFactor: Vector3 {
        get {
            return self.properties[.velocityFactor] as? Vector3 ?? gameObject?.node.physicsBody?.velocityFactor ?? .one
        }
        set {
            self.properties[.velocityFactor] = newValue
            gameObject?.node.physicsBody?.velocityFactor = newValue
        }
    }

    /// Multiplier for angular velocity around each axis (used for constraints).
    ///
    /// This factor is automatically set when applying ``constraints`` to freeze rotation.
    /// Each component scales the rotational velocity around that axis, where 0 completely
    /// prevents rotation and 1 allows full rotation.
    ///
    /// - Default: Vector3(1, 1, 1)
    public var angularVelocityFactor: Vector3 {
        get {
            return self.properties[.angularVelocityFactor] as? Vector3 ?? gameObject?.node.physicsBody?
                .angularVelocityFactor ?? .one
        }
        set {
            self.properties[.angularVelocityFactor] = newValue
            gameObject?.node.physicsBody?.angularVelocityFactor = newValue
        }
    }

    /// Controls whether the rigidbody can sleep when at rest.
    ///
    /// When `true`, the physics engine can put the rigidbody to sleep when it's stationary,
    /// improving performance. Sleeping objects don't consume simulation time until they're
    /// disturbed by forces or collisions. Set to `false` if you need the object to be
    /// continuously active regardless of motion.
    ///
    /// - Default: true
    ///
    /// ## Example
    /// ```swift
    /// // Always keep active for precise simulation
    /// rigidbody.allowsResting = false
    /// ```
    public var allowsResting: Bool {
        get {
            return self.properties[.allowsResting] as? Bool ?? gameObject?.node.physicsBody?.allowsResting ?? true
        }
        set {
            self.properties[.allowsResting] = newValue
            gameObject?.node.physicsBody?.allowsResting = newValue
        }
    }

    // MARK: - Legacy Property Access (Deprecated)

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

    var properties = [Properties.Getter: Any]()

    public func set(property: Properties.Setter) {
        let physicsBody = gameObject?.node.physicsBody

        switch property {
        case .mass(let value):
            self.properties[.mass] = value.toCGFloat()
            physicsBody?.mass = value.toCGFloat()
        case .restitution(let value):
            self.properties[.restitution] = value.toCGFloat()
            physicsBody?.restitution = value.toCGFloat()
        case .friction(let value):
            self.properties[.friction] = value.toCGFloat()
            physicsBody?.friction = value.toCGFloat()
        case .rollingFriction(let value):
            self.properties[.rollingFriction] = value.toCGFloat()
            physicsBody?.rollingFriction = value.toCGFloat()
        case .damping(let value):
            self.properties[.damping] = value.toCGFloat()
            physicsBody?.damping = value.toCGFloat()
        case .angularDamping(let value):
            self.properties[.angularDamping] = value.toCGFloat()
            physicsBody?.angularDamping = value.toCGFloat()
        case .velocity(let value):
            self.properties[.velocity] = value
            physicsBody?.velocity = value
        case .angularVelocity(let value):
            self.properties[.angularVelocity] = value
            physicsBody?.angularVelocity = value
        case .velocityFactor(let value):
            self.properties[.velocityFactor] = value
            physicsBody?.velocityFactor = value
        case .angularVelocityFactor(let value):
            self.properties[.angularVelocityFactor] = value
            physicsBody?.angularVelocityFactor = value
        case .allowsResting(let value):
            self.properties[.allowsResting] = value
            physicsBody?.allowsResting = value
        }
    }

    public func get<T>(property: Properties.Getter) -> T? where T: Getteable {
        let physicsBody = gameObject?.node.physicsBody

        switch property {
        case .mass:
            return self.properties[.mass] as? T ?? physicsBody?.mass.toFloat() as? T
        case .restitution:
            return self.properties[.restitution] as? T ?? physicsBody?.restitution.toFloat() as? T
        case .friction:
            return self.properties[.friction] as? T ?? physicsBody?.friction.toFloat() as? T
        case .rollingFriction:
            return self.properties[.rollingFriction] as? T ?? physicsBody?.rollingFriction.toFloat() as? T
        case .damping:
            return self.properties[.damping] as? T ?? physicsBody?.damping.toFloat() as? T
        case .angularDamping:
            return self.properties[.angularDamping] as? T ?? physicsBody?.angularDamping.toFloat() as? T
        case .velocity:
            return self.properties[.velocity] as? T ?? physicsBody?.velocity as? T
        case .angularVelocity:
            return self.properties[.angularVelocity] as? T ?? physicsBody?.angularVelocity as? T
        case .velocityFactor:
            return self.properties[.velocityFactor] as? T ?? physicsBody?.velocityFactor as? T
        case .angularVelocityFactor:
            return self.properties[.angularVelocityFactor] as? T ?? physicsBody?.angularVelocityFactor as? T
        case .allowsResting:
            return self.properties[.allowsResting] as? T ?? physicsBody?.allowsResting as? T
        }
    }

    /// Configures the rigidbody using a closure-based builder pattern.
    ///
    /// This method provides a convenient way to configure multiple properties in a chainable
    /// manner. The closure receives the rigidbody instance, allowing you to set properties
    /// inline during initialization.
    ///
    /// - Parameter configurationBlock: A closure that receives the rigidbody for configuration.
    /// - Returns: The configured rigidbody instance for further chaining.
    ///
    /// ## Example
    /// ```swift
    /// let rb = gameObject.addComponent(Rigidbody.self)
    ///     .configure { rb in
    ///         rb.mass = 10.0
    ///         rb.useGravity = true
    ///         rb.friction = 0.8
    ///         rb.constraints = .freezeRotation
    ///     }
    /// ```
    @discardableResult public func configure(_ configurationBlock: (Rigidbody) -> Void) -> Rigidbody {
        configurationBlock(self)
        return self
    }

    override public func onDestroy() {
        gameObject?.node.physicsBody = nil
    }

    override public func start() {
        if let _ = getComponent(Collider.self) {
            return
        }
        gameObject?.updatePhysicsBody()
    }

    /// Moves the rigidbody to a specific position.
    ///
    /// This method directly sets the position of the rigidbody's transform. For kinematic
    /// rigidbodies, this is the recommended way to move the object. For dynamic rigidbodies,
    /// consider using ``addForce(_:)`` instead for more realistic physics-based movement.
    ///
    /// - Parameter position: The target position in world space.
    ///
    /// ## Example
    /// ```swift
    /// // Move kinematic platform
    /// let newPos = Vector3(10, 0, 0)
    /// rigidbody.movePosition(newPos)
    /// ```
    public func movePosition(_ position: Vector3) {
        guard let transform = gameObject?.transform
        else { return }

        transform.position = position
    }

    /// Rotates the rigidbody to a specific rotation.
    ///
    /// This method directly sets the rotation of the rigidbody's transform using Euler angles.
    /// For kinematic rigidbodies, this is the recommended way to rotate the object.
    ///
    /// - Parameter to: The target rotation as Euler angles in degrees.
    ///
    /// ## Example
    /// ```swift
    /// // Rotate 90 degrees around Y axis
    /// rigidbody.moveRotation(Vector3(0, 90, 0))
    /// ```
    public func moveRotation(_ to: Vector3) {
        guard let transform = gameObject?.transform
        else { return }

        transform.localEulerAngles = to
    }

    /// Applies a force to the rigidbody as an impulse.
    ///
    /// This method applies an instantaneous force to the rigidbody, immediately affecting its
    /// velocity. The force is applied as an impulse, meaning it's a one-time push rather than
    /// a continuous force. Use this for events like jumps, explosions, or projectile launches.
    ///
    /// The direction parameter can also specify magnitude - a longer vector creates a stronger force.
    ///
    /// - Parameter direction: The force vector to apply. Both direction and magnitude are used.
    ///
    /// ## Example
    /// ```swift
    /// // Make player jump
    /// func jump() {
    ///     let jumpForce = Vector3(0, 10, 0)
    ///     rigidbody?.addForce(jumpForce)
    /// }
    ///
    /// // Launch projectile forward
    /// let launchForce = transform.forward * 500
    /// rigidbody?.addForce(launchForce)
    /// ```
    public func addForce(_ direction: Vector3) {
        guard let physicsBody = gameObject?.node.physicsBody
        else { return }

        physicsBody.applyForce(direction, asImpulse: true)
    }

    /// Applies a torque to the rigidbody to create rotational motion.
    ///
    /// Torque creates angular acceleration, causing the object to rotate. The torque vector's
    /// direction determines the axis of rotation (using the right-hand rule), and its magnitude
    /// determines the strength of the rotation.
    ///
    /// - Parameters:
    ///   - torque: The torque vector to apply as a four-component vector.
    ///   - asImpulse: If `true`, applies torque as an instantaneous impulse. If `false`, applies
    ///                as a continuous force.
    ///
    /// ## Example
    /// ```swift
    /// // Spin object around Y axis
    /// let spinTorque = Vector4(0, 5, 0, 0)
    /// rigidbody.addTorque(spinTorque, asImpulse: true)
    /// ```
    public func addTorque(_ torque: Vector4, asImpulse: Bool) {
        guard let physicsBody = gameObject?.node.physicsBody
        else { return }

        physicsBody.applyTorque(torque, asImpulse: asImpulse)
    }

    /// Applies an explosion force radiating outward from a point.
    ///
    /// This method calculates the direction and strength of force based on distance from the
    /// explosion center. Objects closer to the center receive stronger forces. The force falls
    /// off linearly with distance.
    ///
    /// You can optionally replace specific axis components to create specialized explosion effects,
    /// such as horizontal-only explosions or upward-biased explosions.
    ///
    /// - Parameters:
    ///   - explosionForce: The strength of the explosion force.
    ///   - explosionPosition: The center point of the explosion in world space.
    ///   - explosionRadius: The maximum radius of the explosion effect.
    ///   - replacePosition: Optional position component overrides. Set specific axis values to
    ///                      replace the calculated direction on that axis.
    ///
    /// ## Example: Standard Explosion
    /// ```swift
    /// func explode() {
    ///     let explosionCenter = transform.position
    ///     let affectedObjects = Physics.overlapSphere(
    ///         position: explosionCenter,
    ///         radius: 10.0
    ///     )
    ///
    ///     for collider in affectedObjects {
    ///         if let rb = collider.gameObject?.getComponent(Rigidbody.self) {
    ///             rb.addExplosionForce(
    ///                 explosionForce: 1000,
    ///                 explosionPosition: explosionCenter,
    ///                 explosionRadius: 10.0
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Example: Horizontal Explosion
    /// ```swift
    /// // Explosion that only pushes horizontally (no vertical force)
    /// rigidbody.addExplosionForce(
    ///     explosionForce: 500,
    ///     explosionPosition: explosionCenter,
    ///     explosionRadius: 8.0,
    ///     replacePosition: Vector3Nullable(y: 0) // Force Y component to 0
    /// )
    /// ```
    public func addExplosionForce(
        explosionForce: Float,
        explosionPosition: Vector3,
        explosionRadius: Float,
        replacePosition: Vector3Nullable? = nil
    ) {
        guard let gameObject,
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

    /// Clears all forces currently acting on the rigidbody.
    ///
    /// This method removes all accumulated forces and torques, effectively stopping all
    /// physics-based acceleration. The object's current velocity is not affected - only
    /// forces that would continue to accelerate it are removed.
    ///
    /// Use this when you need to reset physics state, such as when respawning an object
    /// or canceling all pending forces.
    ///
    /// ## Example
    /// ```swift
    /// // Reset object physics state
    /// rigidbody.clearAllForces()
    /// rigidbody.velocity = .zero
    /// rigidbody.angularVelocity = .zero
    /// ```
    public func clearAllForces() {
        guard let physicsBody = gameObject?.node.physicsBody
        else { return }

        physicsBody.clearAllForces()
    }
}
