import Foundation

/// Destroys a ``GameObject`` and removes it from the scene.
///
/// This is a convenience function that calls ``Object/destroy(_:)`` on the specified GameObject.
///
/// - Parameter gameObject: The GameObject to destroy.
///
/// ## Example
///
/// ```swift
/// let enemy = GameObject(name: "Enemy")
/// destroy(enemy)
/// ```
public func destroy(_ gameObject: GameObject) {
    Object.destroy(gameObject)
}

/// The base class for all UnityKit entities.
///
/// `Object` is the fundamental base class from which all UnityKit objects derive, including ``GameObject``,
/// ``Component``, and their subclasses. It provides core functionality for object identity, lifecycle management,
/// and the component system.
///
/// ## Overview
///
/// Every object in UnityKit inherits from `Object`, which provides:
/// - Unique identification through the ``id`` property
/// - Component management for attaching behaviors and functionality
/// - Lifecycle methods (``awake()``, ``start()``, ``update()``, etc.)
/// - Thread-safe component access and modification
/// - Object destruction and cleanup
///
/// ## Component-Based Architecture
///
/// UnityKit follows a component-based architecture where functionality is composed by attaching ``Component``
/// instances to objects rather than using deep inheritance hierarchies. Objects maintain a collection of
/// components that can be queried, added, or removed at runtime.
///
/// The component system includes:
/// - Thread-safe component storage with concurrent read access
/// - Component type caching for efficient lookups
/// - Automatic lifecycle management (awake, start, destroy)
/// - Ordered component execution based on priority
///
/// ## Lifecycle Management
///
/// Objects participate in the UnityKit lifecycle with several key methods:
/// - ``awake()`` - Called when the object is first created
/// - ``start()`` - Called before the first frame update
/// - ``preUpdate()`` - Called every frame before rendering
/// - ``update()`` - Called every frame after rendering
/// - ``fixedUpdate()`` - Called at fixed time intervals for physics
/// - ``destroy()`` - Removes the object and cleans up resources
///
/// - Important: Lifecycle methods are marked as deprecated for direct calls to prevent accidental invocation.
///   The framework manages these calls automatically. You should only override these methods, never call them directly.
///
/// ## Thread Safety
///
/// Object's component system is thread-safe, using concurrent dispatch queues to allow multiple readers
/// while serializing writes. This ensures components can be safely accessed from different threads without
/// data races.
///
/// ## Example
///
/// ```swift
/// class Enemy: Object {
///     override func awake() {
///         // Initialize when created
///         name = "Enemy"
///     }
///
///     override func start() {
///         // Setup before first update
///         addComponent(Rigidbody.self)
///         addComponent(BoxCollider.self)
///     }
///
///     override func update() {
///         // Update every frame
///         if let transform = getComponent(Transform.self) {
///             transform.position.y -= 0.1
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Creating Objects
///
/// - ``init()``
///
/// ### Identity
///
/// - ``id``
/// - ``name``
/// - ``getInstanceID()``
///
/// ### Managing Components
///
/// - ``addComponent(_:)``
/// - ``getComponent(_:)``
/// - ``getComponents(_:)``
/// - ``removeComponent(_:)``
/// - ``removeComponentsOfType(_:)``
///
/// ### Lifecycle Methods
///
/// - ``awake()``
/// - ``start()``
/// - ``preUpdate()``
/// - ``update()``
/// - ``fixedUpdate()``
/// - ``destroy()``
///
/// ### Destroying Objects
///
/// - ``destroy(_:)``
open class Object: Identifiable, Equatable {
    private static var cache = [ObjectIdentifier: [Component]]()
    private static let cacheQueue = DispatchQueue(label: "com.unitykit.object.cache", qos: .userInitiated)

    /// The name of this object.
    ///
    /// Use this property to identify objects in your scene or for debugging purposes.
    /// The name is optional and can be set to any string value.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let player = GameObject()
    /// player.name = "Player"
    /// print(player.name) // "Player"
    /// ```
    open var name: String?

    private var _components = [Component]()
    private let componentsQueue = DispatchQueue(
        label: "com.unitykit.object.components",
        qos: .userInitiated,
        attributes: .concurrent
    )

    var components: [Component] {
        get {
            self.componentsQueue.sync { self._components }
        }
        set {
            self.componentsQueue.sync(flags: .barrier) { [weak self] in
                self?._components = newValue
            }
        }
    }

    /// The unique identifier for this object.
    ///
    /// Every object has a unique identifier that persists for the lifetime of the object.
    /// This ID is automatically generated when the object is created and cannot be changed.
    ///
    /// - Note: This property satisfies the `Identifiable` protocol requirement.
    ///
    /// ## See Also
    ///
    /// - ``getInstanceID()``
    public let id: String

    /// Creates a new object instance.
    ///
    /// This initializer creates a new object with a unique identifier. The object's lifecycle
    /// methods (``awake()``, ``start()``, etc.) will be called automatically by the framework.
    ///
    /// - Note: Subclasses must override this initializer and call `super.init()`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class CustomObject: Object {
    ///     required init() {
    ///         super.init()
    ///         name = "Custom"
    ///     }
    /// }
    ///
    /// let obj = CustomObject()
    /// ```
    public required init() {
        self.id = UUID().uuidString
    }
    
    deinit {
        Debug.debug("\(Self.self).deinit")
    }

    /// Returns the unique instance identifier of the object.
    ///
    /// This method provides access to the object's unique identifier, which is the same
    /// as the ``id`` property. It exists for compatibility with Unity's API pattern.
    ///
    /// - Returns: The unique identifier string for this object instance.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let obj = GameObject(name: "Player")
    /// let instanceID = obj.getInstanceID()
    /// print("Instance ID: \(instanceID)")
    /// ```
    public func getInstanceID() -> String {
        self.id
    }

    /// Destroys a ``GameObject`` and removes it from the scene.
    ///
    /// This class method removes the specified GameObject from the scene and triggers cleanup
    /// of all attached components. The GameObject's ``destroy()`` instance method will be called.
    ///
    /// - Parameter gameObject: The GameObject to destroy.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let enemy = GameObject(name: "Enemy")
    /// Object.destroy(enemy)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``destroy()``
    /// - ``destroy(_:)-1cnz2`` (global function)
    public class func destroy(_ gameObject: GameObject) {
        gameObject.destroy()
    }

    /// Destroys this object and cleans up its resources.
    ///
    /// This method removes all attached components and prepares the object for deallocation.
    /// Override this method in subclasses to perform additional cleanup operations.
    ///
    /// - Important: When overriding, always call `super.destroy()` to ensure proper cleanup.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class CustomObject: Object {
    ///     override func destroy() {
    ///         // Custom cleanup
    ///         print("Cleaning up custom object")
    ///         super.destroy()
    ///     }
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``destroy(_:)``
    open func destroy() {
        self.removeAllComponents()
    }

    /// Called when the object instance is being loaded.
    ///
    /// Use ``awake()`` to initialize variables or state before the object is used. Awake is called
    /// only once during the lifetime of the object instance, before ``start()`` is called.
    ///
    /// - Warning: DO NOT call this method directly. Override only. The framework calls this automatically.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class Enemy: Object {
    ///     var health: Int = 0
    ///
    ///     override func awake() {
    ///         health = 100
    ///         name = "Enemy"
    ///     }
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``start()``
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    open func awake() {}

    /// Called before the first frame update.
    ///
    /// Start is called on the frame when the object is enabled, just before any of the update methods
    /// are called for the first time. This occurs after ``awake()`` has been called on all objects.
    ///
    /// Use ``start()`` to initialize anything that depends on other objects being awake, such as
    /// references to other components or GameObjects.
    ///
    /// - Warning: DO NOT call this method directly. Override only. The framework calls this automatically.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class Player: Object {
    ///     override func start() {
    ///         // Add components after object is fully initialized
    ///         addComponent(Rigidbody.self)
    ///         addComponent(CapsuleCollider.self)
    ///     }
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``awake()``
    /// - ``update()``
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    open func start() {}

    /// Called every frame before rendering.
    ///
    /// PreUpdate is called every frame before the scene is rendered (on `willRenderScene`).
    /// Use this method to prepare objects for rendering or perform updates that must happen
    /// before the frame is drawn.
    ///
    /// - Warning: DO NOT call this method directly. Override only. The framework calls this automatically.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class CameraController: Object {
    ///     override func preUpdate() {
    ///         // Update camera position before rendering
    ///         if let transform = getComponent(Transform.self) {
    ///             transform.lookAt(target)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``update()``
    /// - ``fixedUpdate()``
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    open func preUpdate() {}

    func internalUpdate() {}

    /// Called every frame after rendering.
    ///
    /// Update is called every frame after the scene has been rendered (on `didRenderScene`).
    /// This is the main method for frame-by-frame updates. Use ``Time/deltaTime`` to make
    /// your updates frame-rate independent.
    ///
    /// - Warning: DO NOT call this method directly. Override only. The framework calls this automatically.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class Rotator: Object {
    ///     var rotationSpeed: Float = 45.0
    ///
    ///     override func update() {
    ///         if let transform = getComponent(Transform.self) {
    ///             transform.rotate(
    ///                 Vector3(0, rotationSpeed * Float(Time.deltaTime), 0)
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``preUpdate()``
    /// - ``fixedUpdate()``
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    open func update() {}

    /// Called at fixed time intervals for physics updates.
    ///
    /// FixedUpdate is called at fixed time intervals (on `didSimulatePhysicsAtTime`) and is used
    /// for physics calculations and other updates that should happen at a consistent rate regardless
    /// of frame rate.
    ///
    /// Use ``fixedUpdate()`` for physics operations, rigidbody forces, and any calculation that
    /// needs to be deterministic and frame-rate independent.
    ///
    /// - Warning: DO NOT call this method directly. Override only. The framework calls this automatically.
    ///
    /// ## Example
    ///
    /// ```swift
    /// class PhysicsObject: Object {
    ///     override func fixedUpdate() {
    ///         if let rb = getComponent(Rigidbody.self) {
    ///             rb.addForce(Vector3(0, 9.8, 0))
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``update()``
    /// - ``preUpdate()``
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    open func fixedUpdate() {}

    func movedToScene() {}

    func removeAllComponents() {
        let comps = self.components // Thread-safe read
        comps.forEach { $0.remove() }
    }

    /// Removes all components of the specified type from this object.
    ///
    /// This method removes every component that matches the specified type. Each removed
    /// component's lifecycle cleanup is performed automatically.
    ///
    /// - Parameter type: The type of components to remove.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Remove all AudioSource components
    /// gameObject.removeComponentsOfType(AudioSource.self)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``removeComponent(_:)``
    /// - ``getComponents(_:)``
    public func removeComponentsOfType(_ type: Component.Type) {
        self.componentsQueue.sync(flags: .barrier) {
            while let index = _components.firstIndex(where: { $0.self === type }) {
                self._components[index].remove()
            }
        }
    }

    /// Removes the specified component from this object.
    ///
    /// This method removes a specific component instance, triggering its ``Component/onDestroy()``
    /// method and removing it from the component cache. The operation is thread-safe.
    ///
    /// - Parameter component: The component instance to remove.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let audio = getComponent(AudioSource.self) {
    ///     removeComponent(audio)
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``removeComponentsOfType(_:)``
    /// - ``addComponent(_:)``
    public func removeComponent(_ component: Component) {
        self.componentsQueue.sync(flags: .barrier) {
            if let index = _components.firstIndex(where: { $0 == component }) {
                self._components[index].onDestroy()
                self._components.remove(at: index)
                Object.removeCache(component)
            }
        }
    }

    /// Returns the first component of the specified type attached to this object.
    ///
    /// This method searches for a component of the specified type and returns the first match found.
    /// The search is performed in a thread-safe manner.
    ///
    /// - Parameter type: The type of component to find.
    /// - Returns: The first component of the specified type, or `nil` if no component of that type exists.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let rigidbody = getComponent(Rigidbody.self) {
    ///     rigidbody.velocity = Vector3(0, 10, 0)
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``getComponents(_:)``
    /// - ``addComponent(_:)``
    open func getComponent<T: Component>(_ type: T.Type) -> T? {
        return self.componentsQueue.sync {
            self._components.first { $0 is T } as? T
        }
    }

    /// Returns all components of the specified type attached to this object.
    ///
    /// This method searches for all components of the specified type and returns them as an array.
    /// The search is performed in a thread-safe manner.
    ///
    /// - Parameter type: The type of components to find.
    /// - Returns: An array of all components of the specified type, or an empty array if none exist.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let allColliders = getComponents(Collider.self)
    /// for collider in allColliders {
    ///     collider.isTrigger = true
    /// }
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``getComponent(_:)``
    /// - ``removeComponentsOfType(_:)``
    open func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return self.componentsQueue.sync {
            self._components.compactMap { $0 as? T }
        }
    }

    /// Adds a new component of the specified type to this object.
    ///
    /// This method creates a new component instance of the specified type and attaches it to the object.
    /// The component's ``Component/awake()`` method is called automatically after being added. Components
    /// are stored in order based on their execution priority.
    ///
    /// - Parameter type: The type of component to add.
    /// - Returns: The newly created and attached component instance.
    ///
    /// - Important: Some components (``Renderer``, ``Transform``, ``MeshFilter``, ``UI/Canvas``) cannot be
    ///   manually added and will cause a fatal error if attempted.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let gameObject = GameObject(name: "Player")
    /// let rigidbody = gameObject.addComponent(Rigidbody.self)
    /// rigidbody.mass = 2.0
    ///
    /// let collider = gameObject.addComponent(BoxCollider.self)
    /// collider.size = Vector3(1, 2, 1)
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``getComponent(_:)``
    /// - ``removeComponent(_:)``
    @discardableResult open func addComponent<T: Component>(_ type: T.Type) -> T {
        return self.addComponent(external: true, type: type)
    }

    @discardableResult func addComponent<T: Component>(
        external: Bool = true,
        type: T.Type,
        gameObject: GameObject? = nil
    ) -> T {
        if external,
           T.self === Renderer.self || T.self === Transform.self || T.self === MeshFilter.self || T.self === UI.Canvas
               .self
        {
            fatalError("Can't manually add Renderer, Transform, MeshFilter or Canvas")
        }
        return self.addComponent(T(), gameObject: gameObject)
    }

    @discardableResult func addComponent<T: Component>(_ component: T, gameObject: GameObject? = nil) -> T {
        self.componentsQueue.sync(flags: .barrier) {
            self._components.append(component)
            self._components.sort { $0.order.rawValue <= $1.order.rawValue }
        }
        component.gameObject = gameObject
        component.awake()
        if let behaviour = component as? Behaviour {
            behaviour.enabled = true
        }
        Object.addCache(component)
        return component
    }

    class func addCache<T: Component>(_ component: T) {
        self.cacheQueue.sync {
            let key = T.cacheKey
            if var components = Object.cache[key] {
                components.append(component)
                Object.cache[key] = components
            } else {
                Object.cache[key] = [component]
            }
        }
    }

    class func removeCache<T: Component>(_ component: T) {
        self.cacheQueue.sync {
            let key = T.cacheKey
            var components = Object.cache[key]
            if let index = components?.firstIndex(where: { $0 == component }) {
                components?.remove(at: index)
                Object.cache[key] = components
            }
        }
    }

    class func cache<T: Component>(_ type: T.Type) -> [T]? {
        return self.cacheQueue.sync {
            let key = T.cacheKey
            guard let components = Object.cache[key] else { return nil }
            let result = components.compactMap { $0 as? T }
            return result.isEmpty ? nil : result
        }
    }
}
