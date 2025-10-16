import Foundation

public func destroy(_ gameObject: GameObject) {
    Object.destroy(gameObject)
}

open class Object: Identifiable, Equatable {
    private static var cache = [ObjectIdentifier: [Component]]()
    private static let cacheQueue = DispatchQueue(label: "com.unitykit.object.cache", qos: .userInitiated)

    /**
     Determines the name of the receiver.
    */
    open var name: String?

    private var _components = [Component]()
    private let componentsQueue = DispatchQueue(label: "com.unitykit.object.components", qos: .userInitiated, attributes: .concurrent)

    internal var components: [Component] {
        get {
            componentsQueue.sync { _components }
        }
        set {
            componentsQueue.sync(flags: .barrier) { [weak self] in
                self?._components = newValue
            }
        }
    }

    public let id: String

    /// Create a new instance
    public required init() {
        self.id = UUID().uuidString
    }

    /// Returns the instance id of the object.
    public func getInstanceID() -> String {
        id
    }

    /// Removes a gameobject, component or asset.
    public class func destroy(_ gameObject: GameObject) {
        gameObject.destroy()
    }

    /// Removes a gameobject, component or asset.
    open func destroy() {
        removeAllComponents()
    }

    /// Awake is called when the script instance is being loaded.
    open func awake() {
        Debug.debug("\(Self.self).awake()")
    }

    /// Start is called on the frame when a script is enabled just before any of the Update methods are called the first time.
    open func start() {
        Debug.debug("\(Self.self).start()")
    }

    /// preUpdate is called every frame, if the Object is enabled on willRenderScene.
    open func preUpdate() {
    }

    internal func internalUpdate() {
    }

    /// Update is called every frame, if the Object is enabled on didRenderScene.
    open func update() {
    }

    /// fixedUpdate is called every simulated physics frame, if the Object is enabled on didSimulatePhysicsAtTime.
    open func fixedUpdate() {
    }

    internal func movedToScene() {
    }

    internal func removeAllComponents() {
        let comps = components // Thread-safe read
        comps.forEach { $0.remove() }
    }

    /// Remove a component that matches the type.
    public func removeComponentsOfType(_ type: Component.Type) {
        componentsQueue.sync(flags: .barrier) {
            while let index = _components.firstIndex(where: { $0.self === type }) {
                _components[index].remove()
            }
        }
    }

    /// Remove a component instance.
    public func removeComponent(_ component: Component) {
        componentsQueue.sync(flags: .barrier) {
            if let index = _components.firstIndex(where: { $0 == component }) {
                _components[index].onDestroy()
                _components.remove(at: index)
                Object.removeCache(component)
            }
        }
    }

    /// Returns the component of Type type if the game object has one attached, null if it doesn't.
    open func getComponent<T: Component>(_ type: T.Type) -> T? {
        return componentsQueue.sync {
            _components.first { $0 is T } as? T
        }
    }

    /// Returns all components of Type type in the GameObject.
    open func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return componentsQueue.sync {
            _components.compactMap { $0 as? T }
        }
    }

    /// Add a component to this GameObject.
    @discardableResult open func addComponent<T: Component>(_ type: T.Type) -> T {
        return addComponent(external: true, type: type)
    }

    @discardableResult internal func addComponent<T: Component>(external: Bool = true, type: T.Type, gameObject: GameObject? = nil) -> T {
        if external && (T.self === Renderer.self || T.self === Transform.self || T.self === MeshFilter.self || T.self === UI.Canvas.self) {
            fatalError("Can't manually add Renderer, Transform, MeshFilter or Canvas")
        }
        return addComponent(T(), gameObject: gameObject)
    }

    @discardableResult internal func addComponent<T: Component>(_ component: T, gameObject: GameObject? = nil) -> T {
        componentsQueue.sync(flags: .barrier) {
            _components.append(component)
            _components.sort { $0.order.rawValue <= $1.order.rawValue }
        }
        component.gameObject = gameObject
        component.awake()
        if let behaviour = component as? Behaviour {
            behaviour.enabled = true
        }
        Object.addCache(component)
        return component
    }

    internal class func addCache<T: Component>(_ component: T) {
        cacheQueue.sync {
            let key = T.cacheKey
            if var components = Object.cache[key] {
                components.append(component)
                Object.cache[key] = components
            } else {
                Object.cache[key] = [component]
            }
        }
    }

    internal class func removeCache<T: Component>(_ component: T) {
        cacheQueue.sync {
            let key = T.cacheKey
            var components = Object.cache[key]
            if let index = components?.firstIndex(where: { $0 == component }) {
                components?.remove(at: index)
                Object.cache[key] = components
            }
        }
    }

    internal class func cache<T: Component>(_ type: T.Type) -> [T]? {
        return cacheQueue.sync {
            let key = T.cacheKey
            guard let components = Object.cache[key] else { return nil }
            let result = components.compactMap { $0 as? T }
            return result.isEmpty ? nil : result
        }
    }
}
