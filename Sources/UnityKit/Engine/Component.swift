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

/// Base class for all components that can be attached to ``GameObject``s.
///
/// Components are the building blocks of GameObjects. A GameObject can have multiple components attached,
/// each providing different functionality such as rendering, physics, audio, or custom behavior.
///
/// ## Overview
///
/// Components follow Unity's component-based architecture pattern. Instead of creating deep inheritance hierarchies,
/// you compose functionality by attaching different components to GameObjects.
///
/// - Note: You typically don't instantiate ``Component`` directly. Instead, use ``addComponent(_:)`` on a ``GameObject``
///   or subclass ``MonoBehaviour`` to create custom behaviors.
///
/// ## Lifecycle Methods
///
/// Components participate in the GameObject lifecycle:
/// - ``awake()`` - Called when the component is first created
/// - ``start()`` - Called before the first frame update
/// - ``update()`` - Called every frame
/// - ``fixedUpdate()`` - Called at fixed time intervals
/// - ``onDestroy()`` - Called when the component is destroyed
///
/// ## Example
///
/// ```swift
/// let gameObject = GameObject(name: "Player")
/// let rigidbody = gameObject.addComponent(Rigidbody.self)
/// let camera = gameObject.addComponent(Camera.self)
/// ```
open class Component: Object, Hashable {
    /// The ``GameObject`` this component is attached to.
    ///
    /// A component is always attached to a GameObject. Use this property to access
    /// other components on the same GameObject or to modify the GameObject's properties.
    ///
    /// - Note: This is a weak reference to prevent retain cycles.
    public internal(set) weak var gameObject: GameObject?

    var implementsPreUpdate = true
    var implementsUpdate = true
    var implementsFixedUpdate = true
    var order: ComponentOrder {
        return .other
    }

    /// Determines whether this component should skip update calls.
    ///
    /// When `true`, the component won't receive `update()`, `fixedUpdate()`, or `preUpdate()` calls.
    /// This can improve performance for components that don't need per-frame updates.
    ///
    /// - Returns: `true` by default. Override in subclasses to return `false` if updates are needed.
    public var ignoreUpdates: Bool {
        return true
    }

    /// Shortcut to access the ``Transform`` component of the attached ``GameObject``.
    ///
    /// Every GameObject has a Transform component, so this is a convenience property
    /// to access it without calling `getComponent()`.
    public var transform: Transform? {
        return self.gameObject?.transform
    }

    /// Returns the unique type identifier for this Component class.
    ///
    /// Used internally for component caching and type lookups.
    static var cacheKey: ObjectIdentifier {
        return ObjectIdentifier(Self.self)
    }

    /// Hashes the component using its unique object identifier.
    ///
    /// - Parameter hasher: The hasher to use when combining the component's identity.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    /// Creates a new component instance.
    ///
    /// - Note: Components are typically created through ``GameObject/addComponent(_:)`` rather than directly.
    public required init() {
        super.init()
        Debug.debug("\(Self.self).init()")
    }

    /// Called before the component's first update.
    ///
    /// Override this method to perform pre-update initialization or checks.
    /// The framework automatically calls this method - do not invoke it manually.
    ///
    /// - Warning: Do not call this method directly. Override only if needed.
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    override open func preUpdate() {
        self.implementsPreUpdate = false
    }

    /// Called every frame to update the component.
    ///
    /// Override this method to implement per-frame behavior. Use ``Time/deltaTime`` to make
    /// updates frame-rate independent.
    ///
    /// - Warning: Do not call this method directly. Override only if needed.
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    override open func update() {
        self.implementsUpdate = false
    }

    /// Called at fixed time intervals for physics and other fixed-rate updates.
    ///
    /// Use this method for physics calculations or other updates that should happen
    /// at a consistent rate regardless of frame rate.
    ///
    /// - Warning: Do not call this method directly. Override only if needed.
    @available(*, deprecated, message: "DO NOT call this method directly. Override only. Except in framework. The framework calls this automatically.")
    override open func fixedUpdate() {
        self.implementsFixedUpdate = false
    }

    /// Destroys the component and removes it from its ``GameObject``.
    ///
    /// This method is called automatically by the framework when the component is destroyed.
    /// It triggers ``onDestroy()`` and removes the component from its GameObject.
    override open func destroy() {
        Debug.debug("\(Self.self).destroy()")
        self.gameObject?.removeComponent(self)
    }

    /// Called when the component is about to be destroyed.
    ///
    /// Override this method to perform cleanup operations such as releasing resources,
    /// canceling timers, or saving state.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onDestroy() {
    ///     // Clean up resources
    ///     audioSource.stop()
    ///     timer?.invalidate()
    /// }
    /// ```
    open func onDestroy() {}

    /// Removes this component from its ``GameObject``.
    ///
    /// This is a convenience method that calls ``GameObject/removeComponent(_:)`` on the
    /// attached GameObject.
    public func remove() {
        self.gameObject?.removeComponent(self)
    }

    /// Removes the specified component from this component's ``GameObject``.
    ///
    /// - Parameter component: The component instance to remove.
    override public func removeComponent(_ component: Component) {
        self.gameObject?.removeComponent(component)
    }

    /// Removes all components of the specified type from this component's ``GameObject``.
    ///
    /// - Parameter type: The type of components to remove.
    override public func removeComponentsOfType(_ type: Component.Type) {
        self.gameObject?.removeComponentsOfType(type)
    }

    /// Gets the first component of the specified type attached to this component's ``GameObject``.
    ///
    /// - Parameter type: The type of component to find.
    /// - Returns: The first component of the specified type, or `nil` if none exists.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let rigidbody = getComponent(Rigidbody.self) {
    ///     rigidbody.velocity = Vector3(0, 10, 0)
    /// }
    /// ```
    override open func getComponent<T: Component>(_ type: T.Type) -> T? {
        return self.gameObject?.getComponent(type)
    }

    /// Gets all components of the specified type attached to this component's ``GameObject``.
    ///
    /// - Parameter type: The type of components to find.
    /// - Returns: An array of all components of the specified type, or an empty array if none exist.
    override open func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return self.gameObject?.getComponents(type) ?? []
    }

    /// Adds a new component of the specified type to this component's ``GameObject``.
    ///
    /// - Parameter type: The type of component to add.
    /// - Returns: The newly created component instance.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let audioSource = addComponent(AudioSource.self)
    /// audioSource.clip = myAudioClip
    /// audioSource.play()
    /// ```
    @discardableResult override open func addComponent<T: Component>(_ type: T.Type) -> T {
        return (self.gameObject ?? GameObject()).addComponent(type)
    }
}
