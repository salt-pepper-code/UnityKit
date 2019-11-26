import Foundation
import SceneKit

/**
 Position, rotation and scale of an object.

 Every object in a scene has a Transform. It's used to store and manipulate the position, rotation and scale of the object. Every Transform can have a parent, which allows you to apply position, rotation and scale hierarchically.
 ### Usage Example: ###
 ````
    public class ExampleClass: MonoBehaviour {
        void Example() {
            transform?.children?.forEach {
                $0.position += Vector3.up * 10.0
            }
        }
    }
 ````
 */
public final class Transform: Component {
    override internal var order: ComponentOrder {
        return .transform
    }
    /// Create a new instance
    public required init() {
        super.init()
        self.ignoreUpdates = true
    }

    public init(_ gameObject: GameObject) {
        super.init()
        self.ignoreUpdates = true
        self.gameObject = gameObject
    }
    /// The children of the transform.
    public var children: [Transform]? { return gameObject?.getChildren().map { $0.transform } }
    /// The parent of the transform.
    public var parent: Transform? { return gameObject?.parent?.transform }
    /// The number of children the Transform has.
    public var childCount: Int { return gameObject?.getChildren().count ?? 0 }

    /// The blue axis of the transform in world space.
    public var forward: Vector3 {
        guard let node = gameObject?.node
            else { return .zero }

        return Vector3(hasOrIsPartOfPhysicsBody() ? node.presentation.simdWorldFront : node.simdWorldFront)
    }

    /// The negative blue axis of the transform in world space.
    public var back: Vector3 {
        return forward.negated()
    }

    /// The green axis of the transform in world space.
    public var up: Vector3 {
        guard let node = gameObject?.node
            else { return .zero }

        return Vector3(hasOrIsPartOfPhysicsBody() ? node.presentation.simdWorldUp : node.simdWorldUp)
    }

    /// The negative green axis of the transform in world space.
    public var bottom: Vector3 {
        return up.negated()
    }

    /// The red axis of the transform in world space.
    public var right: Vector3 {
        guard let node = gameObject?.node
            else { return .zero }

        return Vector3(hasOrIsPartOfPhysicsBody() ? node.presentation.simdWorldRight : node.simdWorldRight)
    }

    /// The negative red axis of the transform in world space.
    public var left: Vector3 {
        return right.negated()
    }

    /// The global scale of the object (Read Only).
    public var lossyScale: Vector3 {
        guard let parent = gameObject?.parent
            else { return localScale }

        return parent.transform.lossyScale * localScale
    }

    private func hasOrIsPartOfPhysicsBody() -> Bool {
        guard let gameObject = gameObject
            else { return false }

        guard let parent = gameObject.parent
            else { return gameObject.node.physicsBody != nil }

        return gameObject.node.physicsBody != nil || parent.transform.hasOrIsPartOfPhysicsBody()
    }

    /**
        The position of the transform in world space.

        The position member can be accessed by the Game code. Setting this value can be used to animate the GameObject. The example below makes an attached sphere bounce by updating the position. This bouncing slowly comes to an end. The position can also be use to determine where in 3D space the transform.
    */
    public var position: Vector3 {
        get {
            guard let node = gameObject?.node
                else { return .zero }

            return hasOrIsPartOfPhysicsBody() ? node.presentation.worldPosition : node.worldPosition
        }
        set {
            guard let node = gameObject?.node
                else { return }

            node.worldPosition = newValue
        }
    }

    /// The orientation of the transform in world space stored as a Quaternion.
    public var orientation: Quaternion {
        get {
            guard let node = gameObject?.node
                else { return .zero }

            return hasOrIsPartOfPhysicsBody() ? node.presentation.worldOrientation : node.worldOrientation
        }
        set {
            gameObject?.node.worldOrientation = newValue
        }
    }

    /// The orientation of the transform relative to the parent transform's orientation.
    public var localOrientation: Quaternion {
        get {
            guard let node = gameObject?.node
                else { return .zero }

            return hasOrIsPartOfPhysicsBody() ? node.presentation.orientation : node.orientation
        }
        set {
            gameObject?.node.orientation = newValue
        }
    }

    /// Position of the transform relative to the parent transform.
    public var localPosition: Vector3 {
        get {
            guard let node = gameObject?.node
                else { return .zero }

            return hasOrIsPartOfPhysicsBody() ? node.presentation.position : node.position
        }
        set {
            gameObject?.node.position = newValue
        }
    }

    /// The rotation of the transform relative to the parent transform's rotation.
    public var localRotation: Vector4 {
        get {
            guard let node = gameObject?.node
                else { return .zero }

            return hasOrIsPartOfPhysicsBody() ? node.presentation.rotation : node.rotation
        }
        set {
            gameObject?.node.rotation = newValue
        }
    }

    /// The rotation as Euler angles in degrees.
    public var localEulerAngles: Vector3 {
        get {
            guard let node = gameObject?.node
                else { return .zero }

            return hasOrIsPartOfPhysicsBody() ? node.presentation.orientation.toEuler().radiansToDegrees() : node.orientation.toEuler().radiansToDegrees()
        }
        set {
            gameObject?.node.eulerAngles = newValue.degreesToRadians()
        }
    }

    /// The scale of the transform relative to the parent.
    public var localScale: Vector3 {
        get {
            guard let node = gameObject?.node
                else { return .zero }

            return hasOrIsPartOfPhysicsBody() ? node.presentation.scale : node.scale
        }
        set {
            gameObject?.node.scale = newValue
        }
    }

    /// Rotates the transform so the forward vector points at /target/'s current position.
    ///
    /// - Parameter target: Object to point towards.
    public func lookAt(_ target: Transform) {
        if let constraints = gameObject?.node.constraints, constraints.count > 0 {
            Debug.warning("remove constraints on node before using lookAt")
            return
        }

        gameObject?.node.look(at: target.position)
    }
}
