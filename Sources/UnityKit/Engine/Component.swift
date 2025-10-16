import Foundation

enum ComponentOrder: Int {
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
    public internal(set) weak var gameObject: GameObject?
    var implementsPreUpdate = true
    var implementsUpdate = true
    var implementsFixedUpdate = true
    var order: ComponentOrder {
        return .other
    }

    public var ignoreUpdates: Bool {
        return true
    }

    public var transform: Transform? {
        return self.gameObject?.transform
    }

    /// Returns the ObjectIdentifier for this Component type, used for cache key
    static var cacheKey: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    /// Create a new instance
    public required init() {
        super.init()
        Debug.debug("\(Self.self).init()")
    }

    override open func preUpdate() {
        self.implementsPreUpdate = false
    }

    override open func update() {
        self.implementsUpdate = false
    }

    override open func fixedUpdate() {
        self.implementsFixedUpdate = false
    }

    override open func destroy() {
        Debug.debug("\(Self.self).destroy()")
        self.gameObject?.removeComponent(self)
    }

    open func onDestroy() {}

    public func remove() {
        self.gameObject?.removeComponent(self)
    }

    override public func removeComponent(_ component: Component) {
        self.gameObject?.removeComponent(component)
    }

    override public func removeComponentsOfType(_ type: Component.Type) {
        self.gameObject?.removeComponentsOfType(type)
    }

    override open func getComponent<T: Component>(_ type: T.Type) -> T? {
        return self.gameObject?.getComponent(type)
    }

    override open func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return self.gameObject?.getComponents(type) ?? []
    }

    @discardableResult override open func addComponent<T: Component>(_ type: T.Type) -> T {
        return (self.gameObject ?? GameObject()).addComponent(type)
    }
}
