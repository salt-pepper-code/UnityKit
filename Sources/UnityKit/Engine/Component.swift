import Foundation

internal enum ComponentOrder: Int {
    case transform
    case priority
    case renderer
    case rigidbody
    case collider
    case vehicle
    case other
    case monoBehaviour
}

/**
 Base class for everything attached to GameObjects.

 - notes:
 Note that your code will never directly create a Component. Instead, you write script code (subclass from MonoBehaviour), and attach the script to a GameObject. See [MonoBehaviour](MonoBehaviour.html).
 */
open class Component: Object, Hashable {
    /**
     The game object this component is attached to. A component is always attached to a game object.
     */
    internal(set) public weak var gameObject: GameObject?
    internal var implementsPreUpdate = true
    internal var implementsUpdate = true
    internal var implementsFixedUpdate = true
    internal var order: ComponentOrder {
        return .other
    }
    public var ignoreUpdates: Bool {
        return true
    }

    public var transform: Transform? {
        return gameObject?.transform
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    /// Create a new instance
    public required init() {
        super.init()
    }

    open override func preUpdate() {
        implementsPreUpdate = false
    }

    open override func update() {
        implementsUpdate = false
    }

    open override func fixedUpdate() {
        implementsFixedUpdate = false
    }

    open override func destroy() {
        gameObject?.removeComponent(self)
    }

    open func onDestroy() {
    }

    public func remove() {
        gameObject?.removeComponent(self)
    }

    public override func removeComponent(_ component: Component) {
        gameObject?.removeComponent(component)
    }

    public override func removeComponentsOfType(_ type: Component.Type) {
        gameObject?.removeComponentsOfType(type)
    }

    open override func getComponent<T: Component>(_ type: T.Type) -> T? {
        return gameObject?.getComponent(type)
    }

    open override func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return gameObject?.getComponents(type) ?? []
    }

    @discardableResult open override func addComponent<T: Component>(_ type: T.Type) -> T {
        return (gameObject ?? GameObject()).addComponent(type)
    }
}
