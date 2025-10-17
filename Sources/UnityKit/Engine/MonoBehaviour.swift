import Foundation

/// A closure that determines when a coroutine should exit.
///
/// - Parameter TimeInterval: The time elapsed since the coroutine started.
/// - Returns: `true` if the coroutine should exit, `false` to continue.
public typealias CoroutineCondition = (TimeInterval) -> Bool

/// A closure that executes as part of a coroutine.
public typealias CoroutineClosure = () -> Void

/// A coroutine definition consisting of an execution closure and optional exit condition.
///
/// - Parameters:
///   - execute: The closure to execute.
///   - exitCondition: Optional condition to check when the coroutine should exit.
public typealias Coroutine = (execute: CoroutineClosure, exitCondition: CoroutineCondition?)

private typealias CoroutineInfo = (coroutine: Coroutine, thread: CoroutineThread)

/// Specifies which thread a coroutine should execute on.
public enum CoroutineThread {
    /// Execute on the main thread.
    case main
    /// Execute on a background thread.
    case background
}

/// Base class for creating custom game behaviors and scripts.
///
/// MonoBehaviour is the base class from which every UnityKit script derives. It provides access to
/// lifecycle methods, physics callbacks, and coroutine functionality.
///
/// ## Overview
///
/// MonoBehaviour scripts are attached to GameObjects to define custom behavior. When you create a new
/// script, it should inherit from MonoBehaviour to access the component lifecycle and event callbacks.
///
/// ## Lifecycle Methods
///
/// Override these methods to execute code at specific points in the component's lifecycle:
/// - ``awake()`` - Called when the script instance is being loaded
/// - ``start()`` - Called before the first frame update
/// - ``update()`` - Called every frame
/// - ``fixedUpdate()`` - Called at fixed time intervals
/// - ``onEnable()`` - Called when the component becomes enabled
/// - ``onDisable()`` - Called when the component becomes disabled
/// - ``onDestroy()`` - Called when the component is destroyed
///
/// ## Physics Callbacks
///
/// Override these methods to respond to physics events:
/// - ``onCollisionEnter(_:)`` - Called when this collider/rigidbody begins touching another
/// - ``onCollisionExit(_:)`` - Called when this collider/rigidbody stops touching another
/// - ``onTriggerEnter(_:)`` - Called when a collider enters the trigger
/// - ``onTriggerExit(_:)`` - Called when a collider exits the trigger
///
/// ## Example
///
/// ```swift
/// class PlayerController: MonoBehaviour {
///     var speed: Float = 5.0
///
///     override func update() {
///         if Input.getKey(.w) {
///             transform?.position.z += speed * Float(Time.deltaTime)
///         }
///     }
///
///     override func onCollisionEnter(_ collision: Collision) {
///         print("Player collided with \(collision.contactPoint)")
///     }
/// }
/// ```
open class MonoBehaviour: Behaviour, Instantiable {
    override var order: ComponentOrder {
        return .monoBehaviour
    }

    private var queuedCoroutineInfo = [CoroutineInfo]()
    private var currentCoroutineInfo: CoroutineInfo?
    private var timePassed: TimeInterval = 0

    /// MonoBehaviour always participates in updates.
    ///
    /// - Returns: Always returns `false` to ensure update methods are called.
    override public var ignoreUpdates: Bool {
        return false
    }

    /// Destroys the MonoBehaviour and cleans up coroutines.
    ///
    /// This method cancels all running and queued coroutines before destroying the component.
    override open func destroy() {
        self.currentCoroutineInfo = nil
        self.queuedCoroutineInfo.removeAll()
        super.destroy()
    }

    /// Creates a copy of this MonoBehaviour for the specified ``GameObject``.
    ///
    /// - Parameter gameObject: The GameObject that will own the instantiated component.
    /// - Returns: A new instance of this MonoBehaviour type.
    open func instantiate(gameObject: GameObject) -> Self {
        return type(of: self).init()
    }

    /// Called when the component becomes enabled and active.
    ///
    /// Override this method to perform initialization when the component is enabled.
    /// This is called when the component's ``Behaviour/enabled`` property is set to `true`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onEnable() {
    ///     // Start listening for events
    ///     NotificationCenter.default.addObserver(...)
    /// }
    /// ```
    override open func onEnable() {}

    /// Called when the component becomes disabled.
    ///
    /// Override this method to perform cleanup when the component is disabled.
    /// This is called when the component's ``Behaviour/enabled`` property is set to `false`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onDisable() {
    ///     // Stop listening for events
    ///     NotificationCenter.default.removeObserver(self)
    /// }
    /// ```
    override open func onDisable() {}

    /// Called when this collider/rigidbody begins touching another collider/rigidbody.
    ///
    /// This callback is sent when a collision is detected. Both objects must have a ``Collider``
    /// component, and at least one must have a ``Rigidbody`` component.
    ///
    /// - Parameter collision: The collision data containing contact information.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onCollisionEnter(_ collision: Collision) {
    ///     if collision.gameObjectB?.tag == .player {
    ///         print("Hit player!")
    ///     }
    /// }
    /// ```
    open func onCollisionEnter(_ collision: Collision) {}

    /// Called when this collider/rigidbody stops touching another collider/rigidbody.
    ///
    /// - Parameter collision: The collision data containing contact information.
    open func onCollisionExit(_ collision: Collision) {}

    /// Called when a collider enters a trigger collider.
    ///
    /// This callback is sent when another collider enters a trigger collider attached to this object.
    /// The trigger collider must have ``Collider/isTrigger`` set to `true`.
    ///
    /// - Parameter collider: The collider that entered the trigger.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onTriggerEnter(_ collider: Collider) {
    ///     if collider.gameObject?.layer == .player {
    ///         print("Player entered trigger zone!")
    ///     }
    /// }
    /// ```
    open func onTriggerEnter(_ collider: Collider) {}

    /// Called when a collider exits a trigger collider.
    ///
    /// - Parameter collider: The collider that exited the trigger.
    open func onTriggerExit(_ collider: Collider) {}

    override func internalUpdate() {
        guard let coroutineInfo = currentCoroutineInfo
        else { return }

        self.timePassed += Time.deltaTime

        let exit: Bool = if let exitCondition = coroutineInfo.coroutine.exitCondition {
            exitCondition(self.timePassed)
        } else {
            true
        }
        guard exit else { return }

        self.queuedCoroutineInfo.removeFirst()
        self.currentCoroutineInfo = nil

        guard let next = nextCoroutineInfo() else { return }

        self.executeCoroutine(next)
    }

    /// Starts a coroutine that executes immediately.
    ///
    /// The coroutine executes once on the specified thread. For delayed or conditional execution,
    /// use ``queueCoroutine(_:thread:)`` instead.
    ///
    /// - Parameters:
    ///   - coroutine: The closure to execute.
    ///   - thread: The thread to execute on. Defaults to `.background`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// startCoroutine({
    ///     print("Coroutine executing!")
    /// }, thread: .main)
    /// ```
    public func startCoroutine(_ coroutine: CoroutineClosure, thread: CoroutineThread = .background) {
        coroutine()
    }

    /// Queues a coroutine for execution with an optional exit condition.
    ///
    /// Coroutines are executed in order and checked every frame. Use the exit condition to control
    /// when the coroutine completes and the next one begins.
    ///
    /// - Parameters:
    ///   - coroutine: A tuple containing the execution closure and optional exit condition.
    ///   - thread: The thread to execute on. Defaults to `.main`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Execute after 2 seconds
    /// queueCoroutine((
    ///     execute: {
    ///         print("Delayed execution")
    ///     },
    ///     exitCondition: { elapsed in
    ///         return elapsed >= 2.0
    ///     }
    /// ))
    /// ```
    public func queueCoroutine(_ coroutine: Coroutine, thread: CoroutineThread = .main) {
        self.queuedCoroutineInfo.append((coroutine: coroutine, thread: thread))
        if self.queuedCoroutineInfo.count == 1,
           let next = nextCoroutineInfo()
        {
            self.executeCoroutine(next)
        }
    }

    private func nextCoroutineInfo() -> CoroutineInfo? {
        guard let first = queuedCoroutineInfo.first
        else { return nil }
        return first
    }

    private func executeCoroutine(_ coroutineInfo: CoroutineInfo) {
        self.timePassed = 0
        self.currentCoroutineInfo = coroutineInfo
        switch coroutineInfo.thread {
        case .main:
            coroutineInfo.coroutine.execute()
        case .background:
            DispatchQueue.global(qos: .background).async {
                coroutineInfo.coroutine.execute()
            }
        }
    }
}
