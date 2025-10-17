import Foundation
import SceneKit

/// Position, rotation and scale of an object.
///
/// Every object in a scene has a ``Transform``. It's used to store and manipulate the position, rotation and scale of the object.
/// Every ``Transform`` can have a parent, which allows you to apply position, rotation and scale hierarchically.
///
/// ## Overview
///
/// The ``Transform`` component is fundamental to UnityKit's scene graph. It defines an object's position, rotation, and scale
/// in both world space and local space (relative to its parent). Transforms form a parent-child hierarchy, allowing
/// complex scene structures where child transforms inherit and compound their parent's transformations.
///
/// ### Coordinate System
///
/// UnityKit uses a right-handed coordinate system:
/// - **Red axis (X)**: Right/Left - Accessed via ``right`` and ``left``
/// - **Green axis (Y)**: Up/Down - Accessed via ``up`` and ``bottom``
/// - **Blue axis (Z)**: Forward/Back - Accessed via ``forward`` and ``back``
///
/// ### World Space vs Local Space
///
/// - **World space** properties (like ``position``, ``orientation``) represent absolute values in the scene
/// - **Local space** properties (like ``localPosition``, ``localOrientation``) are relative to the parent transform
/// - If a transform has no parent, world and local values are identical
///
/// ### Parent-Child Relationships
///
/// When a transform has a parent:
/// - Moving the parent also moves all children
/// - Rotating the parent rotates children around the parent's pivot
/// - Scaling the parent scales all children
/// - Children maintain their local offset from the parent
///
/// ## Topics
///
/// ### Position and Scale
///
/// - ``position``
/// - ``localPosition``
/// - ``localScale``
/// - ``lossyScale``
///
/// ### Rotation and Orientation
///
/// - ``orientation``
/// - ``localOrientation``
/// - ``localRotation``
/// - ``localEulerAngles``
///
/// ### Direction Vectors
///
/// - ``forward``
/// - ``back``
/// - ``up``
/// - ``bottom``
/// - ``right``
/// - ``left``
///
/// ### Hierarchy
///
/// - ``parent``
/// - ``children``
/// - ``childCount``
///
/// ### Methods
///
/// - ``lookAt(_:)``
/// - ``lookAt(_:up:localFront:)``
///
/// ### Example: Basic Transform Manipulation
///
/// ```swift
/// class MoveUpExample: MonoBehaviour {
///     func update() {
///         // Move the object up by 1 unit per second
///         transform?.position += Vector3.up * Time.deltaTime
///     }
/// }
/// ```
///
/// ### Example: Working with Hierarchy
///
/// ```swift
/// class HierarchyExample: MonoBehaviour {
///     func start() {
///         // Move all children up by 10 units
///         transform?.children?.forEach { child in
///             child.position += Vector3.up * 10.0
///         }
///     }
/// }
/// ```
///
/// ### Example: Rotation
///
/// ```swift
/// class RotateExample: MonoBehaviour {
///     func update() {
///         // Rotate the object around the Y axis
///         var euler = transform?.localEulerAngles ?? .zero
///         euler.y += 45.0 * Time.deltaTime
///         transform?.localEulerAngles = euler
///     }
/// }
/// ```
///
public final class Transform: Component {
    override var order: ComponentOrder {
        .transform
    }

    public required init() {
        super.init()
    }

    public init(_ gameObject: GameObject) {
        super.init()
        self.gameObject = gameObject
    }

    /// The children of the transform.
    ///
    /// Returns an array of all child transforms. Returns `nil` if there are no children or if the ``gameObject`` is `nil`.
    ///
    /// Changes to the parent transform (position, rotation, scale) affect all children. Children maintain their
    /// local offsets relative to the parent.
    ///
    /// ```swift
    /// // Access all children
    /// if let children = transform?.children {
    ///     for child in children {
    ///         print("Child: \(child.gameObject?.name ?? "unknown")")
    ///     }
    /// }
    /// ```
    public var children: [Transform]? { return gameObject?.getChildren().map(\.transform) }

    /// The parent of the transform.
    ///
    /// Returns the parent transform, or `nil` if this transform is at the root of the hierarchy.
    ///
    /// When a transform has a parent, its ``localPosition``, ``localOrientation``, and ``localScale`` are relative
    /// to the parent's transform. The ``position``, ``orientation``, and ``lossyScale`` represent the combined
    /// (world space) values.
    ///
    /// ```swift
    /// // Check if this transform has a parent
    /// if let parent = transform?.parent {
    ///     print("Parent position: \(parent.position)")
    /// } else {
    ///     print("This is a root transform")
    /// }
    /// ```
    public var parent: Transform? { return gameObject?.parent?.transform }

    /// The number of children the Transform has.
    ///
    /// Returns the count of direct children. Does not include grandchildren or deeper descendants.
    ///
    /// ```swift
    /// let count = transform?.childCount ?? 0
    /// print("This transform has \(count) children")
    /// ```
    public var childCount: Int { return gameObject?.getChildren().count ?? 0 }

    /// The blue axis of the transform in world space.
    ///
    /// Returns a normalized vector representing the forward direction (positive Z-axis) of the transform in world coordinates.
    /// This is useful for determining which way an object is facing or for movement in the object's forward direction.
    ///
    /// > Note: For objects with physics bodies, this returns the presentation node's forward vector to ensure smooth visual updates.
    ///
    /// ```swift
    /// // Move forward relative to the object's rotation
    /// transform?.position += transform?.forward ?? .zero * speed * Time.deltaTime
    /// ```
    public var forward: Vector3 {
        guard let node = gameObject?.node
        else { return .zero }

        return Vector3(self.hasOrIsPartOfPhysicsBody() ? node.presentation.simdWorldFront : node.simdWorldFront)
    }

    /// The negative blue axis of the transform in world space.
    ///
    /// Returns a normalized vector representing the backward direction (negative Z-axis) of the transform in world coordinates.
    /// This is the opposite of ``forward``.
    ///
    /// ```swift
    /// // Move backward
    /// transform?.position += transform?.back ?? .zero * speed * Time.deltaTime
    /// ```
    public var back: Vector3 {
        return self.forward.negated()
    }

    /// The green axis of the transform in world space.
    ///
    /// Returns a normalized vector representing the upward direction (positive Y-axis) of the transform in world coordinates.
    /// This represents the "top" of the object based on its rotation.
    ///
    /// > Note: For objects with physics bodies, this returns the presentation node's up vector to ensure smooth visual updates.
    ///
    /// ```swift
    /// // Move upward relative to the object's rotation
    /// transform?.position += transform?.up ?? .zero * jumpForce
    /// ```
    public var up: Vector3 {
        guard let node = gameObject?.node
        else { return .zero }

        return Vector3(self.hasOrIsPartOfPhysicsBody() ? node.presentation.simdWorldUp : node.simdWorldUp)
    }

    /// The negative green axis of the transform in world space.
    ///
    /// Returns a normalized vector representing the downward direction (negative Y-axis) of the transform in world coordinates.
    /// This is the opposite of ``up``.
    ///
    /// ```swift
    /// // Apply gravity in the object's local down direction
    /// transform?.position += transform?.bottom ?? .zero * gravity * Time.deltaTime
    /// ```
    public var bottom: Vector3 {
        return self.up.negated()
    }

    /// The red axis of the transform in world space.
    ///
    /// Returns a normalized vector representing the right direction (positive X-axis) of the transform in world coordinates.
    /// This represents the "right side" of the object based on its rotation.
    ///
    /// > Note: For objects with physics bodies, this returns the presentation node's right vector to ensure smooth visual updates.
    ///
    /// ```swift
    /// // Strafe right
    /// transform?.position += transform?.right ?? .zero * strafeSpeed * Time.deltaTime
    /// ```
    public var right: Vector3 {
        guard let node = gameObject?.node
        else { return .zero }

        return Vector3(self.hasOrIsPartOfPhysicsBody() ? node.presentation.simdWorldRight : node.simdWorldRight)
    }

    /// The negative red axis of the transform in world space.
    ///
    /// Returns a normalized vector representing the left direction (negative X-axis) of the transform in world coordinates.
    /// This is the opposite of ``right``.
    ///
    /// ```swift
    /// // Strafe left
    /// transform?.position += transform?.left ?? .zero * strafeSpeed * Time.deltaTime
    /// ```
    public var left: Vector3 {
        return self.right.negated()
    }

    /// The global scale of the object (Read Only).
    ///
    /// Returns the combined scale of this transform and all its ancestors. This represents the actual scale
    /// of the object in world space, accounting for all parent scales in the hierarchy.
    ///
    /// Unlike ``localScale`` which is relative to the parent, `lossyScale` represents the final,
    /// accumulated scale. The name "lossy" indicates that this value cannot be reliably converted back
    /// to local scale if the hierarchy has non-uniform scaling or rotation.
    ///
    /// > Note: This property is read-only. To modify scale, use ``localScale``.
    ///
    /// ```swift
    /// // Check the final world scale
    /// let worldScale = transform?.lossyScale ?? .zero
    /// print("Object's world scale: \(worldScale)")
    ///
    /// // Compare local vs world scale
    /// if let transform = transform {
    ///     print("Local scale: \(transform.localScale)")
    ///     print("World scale: \(transform.lossyScale)")
    /// }
    /// ```
    public var lossyScale: Vector3 {
        guard let parent = gameObject?.parent
        else { return self.localScale }

        return parent.transform.lossyScale * self.localScale
    }

    private func hasOrIsPartOfPhysicsBody() -> Bool {
        guard let gameObject
        else { return false }

        guard let parent = gameObject.parent
        else { return gameObject.node.physicsBody != nil }

        return gameObject.node.physicsBody != nil || parent.transform.hasOrIsPartOfPhysicsBody()
    }

    /// The position of the transform in world space.
    ///
    /// Returns the absolute position of the transform in the scene's coordinate system. This is the final position
    /// after applying all parent transforms in the hierarchy. Setting this value moves the object to the specified
    /// world position, regardless of parent transforms.
    ///
    /// For objects with physics bodies, the getter returns the presentation node's position to ensure smooth
    /// visual updates during physics simulation.
    ///
    /// > Note: If you need position relative to the parent, use ``localPosition`` instead.
    ///
    /// ```swift
    /// // Set absolute world position
    /// transform?.position = Vector3(x: 10, y: 5, z: 0)
    ///
    /// // Move to a specific world position over time
    /// let targetPos = Vector3(x: 0, y: 10, z: 0)
    /// transform?.position = Vector3.lerp(
    ///     from: transform?.position ?? .zero,
    ///     to: targetPos,
    ///     t: Time.deltaTime
    /// )
    ///
    /// // Animate by updating position each frame
    /// class Bouncer: MonoBehaviour {
    ///     var velocity = Vector3.up * 5.0
    ///
    ///     func update() {
    ///         // Apply velocity
    ///         transform?.position += velocity * Time.deltaTime
    ///
    ///         // Simple gravity
    ///         velocity += Vector3.down * 9.8 * Time.deltaTime
    ///
    ///         // Bounce at ground level
    ///         if let pos = transform?.position, pos.y < 0 {
    ///             transform?.position.y = 0
    ///             velocity.y = abs(velocity.y) * 0.8  // Lose energy
    ///         }
    ///     }
    /// }
    /// ```
    public var position: Vector3 {
        get {
            guard let node = gameObject?.node
            else { return .zero }

            return self.hasOrIsPartOfPhysicsBody() ? node.presentation.worldPosition : node.worldPosition
        }
        set {
            guard let node = gameObject?.node
            else { return }

            node.worldPosition = newValue
        }
    }

    /// The orientation of the transform in world space stored as a Quaternion.
    ///
    /// Returns the absolute rotation of the transform as a quaternion in world coordinates. Quaternions provide
    /// a mathematically robust way to represent rotations without gimbal lock issues.
    ///
    /// For objects with physics bodies, the getter returns the presentation node's orientation to ensure smooth
    /// visual updates during physics simulation.
    ///
    /// > Note: For euler angle representation, use ``localEulerAngles``. For local orientation relative to parent,
    /// > use ``localOrientation``.
    ///
    /// ```swift
    /// // Set world orientation directly
    /// transform?.orientation = Quaternion.identity
    ///
    /// // Rotate towards a target orientation
    /// let targetOrientation = Quaternion(angle: .pi / 2, axis: Vector3.up)
    /// transform?.orientation = Quaternion.slerp(
    ///     from: transform?.orientation ?? .identity,
    ///     to: targetOrientation,
    ///     t: Time.deltaTime * rotationSpeed
    /// )
    /// ```
    public var orientation: Quaternion {
        get {
            guard let node = gameObject?.node
            else { return .zero }

            return self.hasOrIsPartOfPhysicsBody() ? node.presentation.worldOrientation : node.worldOrientation
        }
        set {
            gameObject?.node.worldOrientation = newValue
        }
    }

    /// The orientation of the transform relative to the parent transform's orientation.
    ///
    /// Returns the rotation as a quaternion relative to the parent's orientation. If there is no parent,
    /// this is equivalent to ``orientation`` (world orientation).
    ///
    /// For objects with physics bodies, the getter returns the presentation node's orientation to ensure smooth
    /// visual updates during physics simulation.
    ///
    /// > Note: Quaternions are often preferred over euler angles for rotations to avoid gimbal lock.
    ///
    /// ```swift
    /// // Set local orientation
    /// transform?.localOrientation = Quaternion.identity
    ///
    /// // Rotate relative to parent
    /// let rotation = Quaternion(angle: .pi / 4, axis: Vector3.up)
    /// transform?.localOrientation = rotation
    /// ```
    public var localOrientation: Quaternion {
        get {
            guard let node = gameObject?.node
            else { return .zero }

            return self.hasOrIsPartOfPhysicsBody() ? node.presentation.orientation : node.orientation
        }
        set {
            gameObject?.node.orientation = newValue
        }
    }

    /// Position of the transform relative to the parent transform.
    ///
    /// Returns the position of the transform in its parent's local coordinate space. If the transform has no parent,
    /// this is equivalent to ``position`` (world position).
    ///
    /// For objects with physics bodies, the getter returns the presentation node's position to ensure smooth
    /// visual updates during physics simulation.
    ///
    /// Setting ``localPosition`` positions the object relative to its parent. When the parent moves, rotates, or scales,
    /// the child maintains this local offset.
    ///
    /// ```swift
    /// // Position relative to parent
    /// transform?.localPosition = Vector3(x: 2, y: 0, z: 0)  // 2 units to the right of parent
    ///
    /// // Orbit around parent
    /// class Orbiter: MonoBehaviour {
    ///     var angle: Float = 0
    ///     let radius: Float = 5.0
    ///
    ///     func update() {
    ///         angle += Time.deltaTime
    ///         transform?.localPosition = Vector3(
    ///             x: cos(angle) * radius,
    ///             y: 0,
    ///             z: sin(angle) * radius
    ///         )
    ///     }
    /// }
    /// ```
    public var localPosition: Vector3 {
        get {
            guard let node = gameObject?.node
            else { return .zero }

            return self.hasOrIsPartOfPhysicsBody() ? node.presentation.position : node.position
        }
        set {
            gameObject?.node.position = newValue
        }
    }

    /// The rotation of the transform relative to the parent transform's rotation.
    ///
    /// Returns the rotation as a 4-component vector (axis-angle representation) relative to the parent's rotation.
    /// The first three components (x, y, z) define the rotation axis, and the w component defines the angle in radians.
    ///
    /// For objects with physics bodies, the getter returns the presentation node's rotation to ensure smooth
    /// visual updates during physics simulation.
    ///
    /// > Note: For most use cases, prefer ``localOrientation`` (quaternion) or ``localEulerAngles`` (degrees) for easier manipulation.
    ///
    /// ```swift
    /// // Rotate around Y axis
    /// transform?.localRotation = Vector4(x: 0, y: 1, z: 0, w: .pi / 2)  // 90 degrees around Y
    /// ```
    public var localRotation: Vector4 {
        get {
            guard let node = gameObject?.node
            else { return .zero }

            return self.hasOrIsPartOfPhysicsBody() ? node.presentation.rotation : node.rotation
        }
        set {
            gameObject?.node.rotation = newValue
        }
    }

    /// The rotation as Euler angles in degrees.
    ///
    /// Returns the rotation as euler angles (pitch, yaw, roll) in degrees, relative to the parent transform.
    /// Euler angles provide an intuitive way to represent rotations using three separate angle values.
    ///
    /// - **X (pitch)**: Rotation around the X-axis (tilting up/down)
    /// - **Y (yaw)**: Rotation around the Y-axis (turning left/right)
    /// - **Z (roll)**: Rotation around the Z-axis (rolling/banking)
    ///
    /// For objects with physics bodies, the getter returns the presentation node's euler angles to ensure smooth
    /// visual updates during physics simulation.
    ///
    /// > Warning: Euler angles can suffer from gimbal lock when rotating around multiple axes. For complex rotations,
    /// > consider using ``localOrientation`` (quaternions) instead.
    ///
    /// ```swift
    /// // Set specific rotation angles
    /// transform?.localEulerAngles = Vector3(x: 0, y: 45, z: 0)  // Rotate 45° around Y axis
    ///
    /// // Continuously rotate
    /// class Spinner: MonoBehaviour {
    ///     func update() {
    ///         var euler = transform?.localEulerAngles ?? .zero
    ///         euler.y += 90.0 * Time.deltaTime  // 90 degrees per second
    ///         transform?.localEulerAngles = euler
    ///     }
    /// }
    /// ```
    public var localEulerAngles: Vector3 {
        get {
            guard let node = gameObject?.node
            else { return .zero }

            return self.hasOrIsPartOfPhysicsBody() ? node.presentation.orientation.toEuler().radiansToDegrees() : node
                .orientation.toEuler().radiansToDegrees()
        }
        set {
            gameObject?.node.eulerAngles = newValue.degreesToRadians()
        }
    }

    /// The scale of the transform relative to the parent.
    ///
    /// Returns the scale factors for the X, Y, and Z axes relative to the parent transform. A value of (1, 1, 1)
    /// represents the original size. Values greater than 1 enlarge the object, values less than 1 shrink it.
    ///
    /// For objects with physics bodies, the getter returns the presentation node's scale to ensure smooth
    /// visual updates during physics simulation.
    ///
    /// > Note: For the final world-space scale accounting for all parents, use ``lossyScale``.
    ///
    /// ```swift
    /// // Set uniform scale
    /// transform?.localScale = Vector3(x: 2, y: 2, z: 2)  // Double the size
    ///
    /// // Non-uniform scale
    /// transform?.localScale = Vector3(x: 1, y: 2, z: 1)  // Stretch vertically
    ///
    /// // Animate scale
    /// class Pulser: MonoBehaviour {
    ///     func update() {
    ///         let scale = 1.0 + sin(Time.time * 2.0) * 0.2
    ///         transform?.localScale = Vector3(x: scale, y: scale, z: scale)
    ///     }
    /// }
    /// ```
    public var localScale: Vector3 {
        get {
            guard let node = gameObject?.node
            else { return .zero }

            return self.hasOrIsPartOfPhysicsBody() ? node.presentation.scale : node.scale
        }
        set {
            gameObject?.node.scale = newValue
        }
    }

    /// Rotates the transform so the forward vector points at the target's current position.
    ///
    /// Aligns this transform's ``forward`` vector to point towards the target transform's ``position``.
    /// This is useful for cameras tracking objects, turrets aiming at targets, or any object that needs
    /// to face another object.
    ///
    /// The rotation is applied immediately and affects the transform's ``orientation`` and ``localOrientation``.
    ///
    /// > Warning: This method will fail if the transform has constraints applied. Remove any constraints
    /// > using `node.constraints = nil` before calling ``lookAt(_:)``.
    ///
    /// - Parameter target: The transform to point towards.
    ///
    /// ```swift
    /// class CameraFollow: MonoBehaviour {
    ///     var target: Transform?
    ///
    ///     func update() {
    ///         // Keep the camera looking at the target
    ///         if let target = target {
    ///             transform?.lookAt(target)
    ///         }
    ///     }
    /// }
    ///
    /// // Turret aiming example
    /// class Turret: MonoBehaviour {
    ///     var enemy: Transform?
    ///
    ///     func start() {
    ///         // Find enemy
    ///         enemy = GameObject.find(name: "Enemy")?.transform
    ///     }
    ///
    ///     func update() {
    ///         if let enemy = enemy {
    ///             transform?.lookAt(enemy)
    ///         }
    ///     }
    /// }
    /// ```
    public func lookAt(_ target: Transform) {
        if let constraints = gameObject?.node.constraints, constraints.count > 0 {
            Debug.warning("remove constraints on node before using lookAt")
            return
        }

        gameObject?.node.look(at: target.position)
    }

    /// Rotates the transform so the forward vector points at the target's current position with custom up vector and local front.
    ///
    /// This advanced variant of ``lookAt(_:)`` allows you to specify a custom world up vector and local front vector,
    /// providing more control over the orientation.
    ///
    /// > Warning: This method will fail if the transform has constraints applied. Remove any constraints
    /// > using `node.constraints = nil` before calling this method.
    ///
    /// - Parameters:
    ///   - target: The transform to point towards.
    ///   - worldUp: The up vector in world space used to determine the final orientation.
    ///   - localFront: The local front vector that should point towards the target.
    ///
    /// ```swift
    /// class CustomLookAt: MonoBehaviour {
    ///     var target: Transform?
    ///
    ///     func update() {
    ///         if let target = target {
    ///             // Look at target with custom up vector
    ///             let customUp = SCNVector3(x: 0, y: 1, z: 0)
    ///             let customFront = SCNVector3(x: 0, y: 0, z: 1)
    ///             transform?.lookAt(target, up: customUp, localFront: customFront)
    ///         }
    ///     }
    /// }
    /// ```
    public func lookAt(
        _ target: Transform,
        up worldUp: SCNVector3,
        localFront: SCNVector3
    ) {
        if let constraints = gameObject?.node.constraints, constraints.count > 0 {
            Debug.warning("remove constraints on node before using lookAt")
            return
        }

        gameObject?.node.look(at: target.position, up: worldUp, localFront: localFront)
    }
}
