import Foundation

/// Base class for components that can be enabled or disabled.
///
/// Behaviour extends ``Component`` by adding enabled/disabled state management. When a Behaviour is disabled,
/// it continues to exist but may not participate in certain operations depending on the subclass implementation.
///
/// ## Overview
///
/// Behaviour is the base class for all components that support being enabled or disabled. Most game scripts
/// inherit from ``MonoBehaviour``, which inherits from Behaviour. This provides a consistent way to toggle
/// component functionality at runtime without destroying the component.
///
/// The enabled state is managed through the ``enabled`` property. When this property changes, the appropriate
/// callback method (``onEnable()`` or ``onDisable()``) is automatically invoked.
///
/// - Note: Behaviour itself doesn't implement any specific enabled/disabled behavior. Subclasses determine
///   how the enabled state affects their functionality.
///
/// ## State Management
///
/// The enabled state allows you to temporarily deactivate components without destroying them. This is useful for:
/// - Temporarily disabling game mechanics
/// - Implementing pause functionality
/// - Toggling visual effects
/// - Managing component activation based on game state
///
/// ## Example
///
/// ```swift
/// class CustomBehaviour: Behaviour {
///     override func onEnable() {
///         print("Behaviour enabled")
///         // Start operations
///     }
///
///     override func onDisable() {
///         print("Behaviour disabled")
///         // Stop operations
///     }
/// }
///
/// let gameObject = GameObject()
/// let behaviour = gameObject.addComponent(CustomBehaviour.self)
///
/// behaviour.enabled = true   // Triggers onEnable()
/// behaviour.enabled = false  // Triggers onDisable()
/// ```
///
/// ## Topics
///
/// ### Managing State
///
/// - ``enabled``
///
/// ### Responding to State Changes
///
/// - ``onEnable()``
/// - ``onDisable()``
open class Behaviour: Component {
    /// Controls whether this Behaviour is enabled.
    ///
    /// When this property changes, the appropriate callback method is automatically invoked:
    /// - Setting to `true` triggers ``onEnable()``
    /// - Setting to `false` triggers ``onDisable()``
    ///
    /// The callbacks are only invoked when the value actually changes. Setting `enabled` to its
    /// current value will not trigger the callbacks.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let behaviour = gameObject.getComponent(MyBehaviour.self)
    /// behaviour?.enabled = false  // Disable the behaviour
    ///
    /// // Later...
    /// behaviour?.enabled = true   // Re-enable the behaviour
    /// ```
    public var enabled: Bool = false {
        didSet {
            guard self.enabled != oldValue else { return }

            if self.enabled {
                self.onEnable()
            } else {
                self.onDisable()
            }
        }
    }

    func enableChanged() {}

    /// Called when the Behaviour becomes enabled and active.
    ///
    /// Override this method to perform initialization or setup when the component is enabled.
    /// This is called automatically by the framework when ``enabled`` is set to `true`.
    ///
    /// - Note: This method is not called when the component is first created. Override ``awake()``
    ///   or ``start()`` for initialization that should happen once.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onEnable() {
    ///     // Resume operations
    ///     timer?.start()
    ///     registerForNotifications()
    /// }
    /// ```
    open func onEnable() {}

    /// Called when the Behaviour becomes disabled.
    ///
    /// Override this method to perform cleanup or teardown when the component is disabled.
    /// This is called automatically by the framework when ``enabled`` is set to `false`.
    ///
    /// - Note: This method is also called when the component is destroyed. If you need to distinguish
    ///   between disable and destroy, use ``onDestroy()`` for final cleanup.
    ///
    /// ## Example
    ///
    /// ```swift
    /// override func onDisable() {
    ///     // Pause operations
    ///     timer?.stop()
    ///     unregisterFromNotifications()
    /// }
    /// ```
    open func onDisable() {}
}
