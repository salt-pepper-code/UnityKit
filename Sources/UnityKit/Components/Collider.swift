import SceneKit

/// Type alias for collision contact information.
///
/// Represents the contact data between two colliding physics bodies, provided by SceneKit.
public typealias Collision = SCNPhysicsContact

/// Base class for all collider components.
///
/// Colliders define the shape of GameObjects for physical collision detection. They work
/// in conjunction with ``Rigidbody`` components to enable physics simulation and collision
/// responses. Colliders can also be used as triggers to detect when objects enter or exit
/// specific areas without physical collision.
///
/// ## Overview
///
/// This is an abstract base class - you should not add a `Collider` directly to a GameObject.
/// Instead, use one of the concrete collider subclasses:
/// - `BoxCollider` - Box-shaped collision volume
/// - `SphereCollider` - Spherical collision volume
/// - `CapsuleCollider` - Capsule-shaped collision volume
/// - `MeshCollider` - Complex mesh-based collision
///
/// ## Collision vs Triggers
///
/// Colliders can operate in two modes:
///
/// - **Collision Mode** (`isTrigger = false`): Objects physically collide and interact,
///   preventing overlap and responding to physics forces.
///
/// - **Trigger Mode** (`isTrigger = true`): Objects can pass through each other, but
///   trigger events are fired when objects enter or exit the trigger volume. Perfect for
///   pickup zones, checkpoints, or detection areas.
///
/// ## Layer-Based Collision Filtering
///
/// Use ``collideWithLayer`` and ``contactWithLayer`` to control which objects interact:
/// - ``collideWithLayer``: Defines which layers this collider physically collides with
/// - ``contactWithLayer``: Defines which layers trigger contact events
///
/// ## Topics
///
/// ### Configuration
///
/// - ``isTrigger``
/// - ``collideWithLayer``
/// - ``contactWithLayer``
///
/// ### Subclassing
///
/// - ``instantiate(gameObject:)``
/// - ``constructBody()``
///
/// ## Example: Physical Collider
/// ```swift
/// let wall = GameObject(name: "Wall")
/// let collider = wall.addComponent(BoxCollider.self)
/// collider.isTrigger = false
/// collider.collideWithLayer = .default
/// ```
///
/// ## Example: Trigger Zone
/// ```swift
/// class PickupZone: MonoBehaviour {
///     override func start() {
///         let collider = gameObject?.addComponent(SphereCollider.self)
///         collider?.isTrigger = true
///         collider?.contactWithLayer = .player
///     }
///
///     override func onTriggerEnter(_ collider: Collider) {
///         print("Player entered pickup zone!")
///         // Award points or collect item
///     }
/// }
/// ```
///
/// - Warning: Do not instantiate `Collider` directly. Use concrete subclasses instead.
public class Collider: Component, Instantiable {
    override var order: ComponentOrder {
        .collider
    }

    /// Creates a copy of this collider for instantiation.
    ///
    /// This method is called internally when cloning GameObjects with collider components.
    /// It copies collision layer settings to the new instance. Subclasses should override
    /// this method to copy additional properties specific to their collider type.
    ///
    /// - Parameter gameObject: The GameObject that will own the cloned collider.
    /// - Returns: A new collider instance with copied properties.
    open func instantiate(gameObject: GameObject) -> Self {
        let clone = type(of: self).init()
        clone.collideWithLayer = self.collideWithLayer
        clone.contactWithLayer = self.contactWithLayer
        return clone
    }

    /// The underlying physics shape used for collision detection.
    ///
    /// This is set by subclasses to define the actual collision geometry.
    var physicsShape: SCNPhysicsShape?

    /// The layers that this collider will physically collide with.
    ///
    /// Use layer masks to control which objects can collide with this collider.
    /// Only objects on the specified layers will cause physical collisions.
    /// If `nil`, the collider may not participate in physical collisions.
    ///
    /// ## Example
    /// ```swift
    /// // Player collides with enemies and environment
    /// playerCollider.collideWithLayer = [.enemy, .environment]
    ///
    /// // Bullets collide only with enemies
    /// bulletCollider.collideWithLayer = .enemy
    /// ```
    public var collideWithLayer: GameObject.Layer? {
        didSet {
            gameObject?.updateBitMask()
        }
    }

    /// Controls whether this collider acts as a trigger.
    ///
    /// When `true`, the collider becomes a trigger that detects overlaps without
    /// causing physical collisions. Objects can pass through triggers, but trigger
    /// events (`onTriggerEnter`, `onTriggerExit`) are fired.
    ///
    /// Setting this to `true` automatically sets ``contactWithLayer`` if it's `nil`.
    ///
    /// ## Example
    /// ```swift
    /// // Create a checkpoint trigger
    /// let checkpoint = GameObject(name: "Checkpoint")
    /// let collider = checkpoint.addComponent(BoxCollider.self)
    /// collider.isTrigger = true
    /// collider.contactWithLayer = .player
    /// ```
    public var isTrigger: Bool = false {
        didSet {
            if self.isTrigger, self.contactWithLayer == nil {
                self.contactWithLayer = self.collideWithLayer
            }
            gameObject?.updateBitMask()
        }
    }

    /// The layers that this collider will generate contact events with.
    ///
    /// Contact events are triggered when this collider overlaps with objects on the
    /// specified layers. This works in conjunction with ``isTrigger`` to enable trigger
    /// behavior. When you set this property, ``isTrigger`` is automatically set to `true`.
    ///
    /// ## Example
    /// ```swift
    /// // Detect when player touches collectible
    /// collectibleCollider.contactWithLayer = .player
    /// // isTrigger is now automatically true
    /// ```
    public var contactWithLayer: GameObject.Layer? {
        didSet {
            self.isTrigger = self.contactWithLayer != nil
        }
    }

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {
        guard let gameObject
        else { return nil }

        return gameObject.getComponents(Collider.self)
            .compactMap { collider -> SCNPhysicsShape? in collider.physicsShape }
    }

    /// Called internally by the physics system when a collision begins.
    ///
    /// This method is invoked by SceneKit's physics world when two colliders start touching.
    /// It triggers the appropriate callbacks on MonoBehaviour components attached to the
    /// GameObject, including `onCollisionEnter` and `onTriggerEnter`.
    ///
    /// - Parameters:
    ///   - world: The physics world managing the collision.
    ///   - contact: The collision contact information.
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: Collision) {
        guard self.isTrigger,
              let gameObject,
              contact.nodeA.name == gameObject.name || contact.nodeB.name == gameObject.name
        else { return }

        for component in gameObject.components {
            guard let monoBehaviour = component as? MonoBehaviour
            else { continue }

            monoBehaviour.onCollisionEnter(contact)
            monoBehaviour.onTriggerEnter(self)
        }
    }

    /// Called internally by the physics system when a collision ends.
    ///
    /// This method is invoked by SceneKit's physics world when two colliders stop touching.
    /// It triggers the appropriate callbacks on MonoBehaviour components attached to the
    /// GameObject, including `onCollisionExit` and `onTriggerExit`.
    ///
    /// - Parameters:
    ///   - world: The physics world managing the collision.
    ///   - contact: The collision contact information.
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: Collision) {
        guard self.isTrigger,
              let gameObject,
              contact.nodeA.name == gameObject.name || contact.nodeB.name == gameObject.name
        else { return }

        for component in gameObject.components {
            guard let monoBehaviour = component as? MonoBehaviour
            else { continue }

            monoBehaviour.onCollisionExit(contact)
            monoBehaviour.onTriggerExit(self)
        }
    }

    override public func start() {
        self.constructBody()
        gameObject?.updatePhysicsBody()
    }

    /// Called when the collider is destroyed.
    ///
    /// Override this method in subclasses to perform cleanup when the collider is removed.
    override public func onDestroy() {}

    /// Constructs the physics body for this collider.
    ///
    /// This abstract method must be implemented by concrete collider subclasses to create
    /// their specific collision shapes (box, sphere, capsule, mesh, etc.).
    ///
    /// - Warning: This method will trigger a fatal error if called on the base `Collider` class.
    ///            Always use concrete subclasses like `BoxCollider` or `SphereCollider`.
    func constructBody() {
        fatalError("Can't use Collider as a component, please use subclasses")
    }
}
