/// A protocol for objects that can create copies of themselves attached to a GameObject.
///
/// ``Instantiable`` defines a common interface for types that can be instantiated or duplicated
/// as part of a GameObject's component system. This is typically used with ``Component`` types
/// to support cloning or prefab instantiation.
///
/// ## Overview
///
/// When you instantiate a GameObject (such as from a prefab), all of its components need to be
/// copied to the new instance. The Instantiable protocol provides a standardized way for
/// components to create duplicates of themselves.
///
/// ## Implementing Instantiable
///
/// Types conforming to this protocol must implement the ``instantiate(gameObject:)`` method,
/// which creates a new instance of the type and attaches it to the provided GameObject.
///
/// ## Example
///
/// ```swift
/// class CustomComponent: Component, Instantiable {
///     var customValue: Float = 0
///
///     func instantiate(gameObject: GameObject) -> Self {
///         let newComponent = gameObject.addComponent(CustomComponent.self)
///         newComponent.customValue = self.customValue
///         return newComponent as! Self
///     }
/// }
///
/// // When instantiating a prefab
/// let prefab = GameObject()
/// let original = prefab.addComponent(CustomComponent.self)
/// original.customValue = 42
///
/// let instance = prefab.instantiate()
/// if let copy = instance.getComponent(CustomComponent.self) {
///     print(copy.customValue)  // Prints: 42
/// }
/// ```
///
/// ## Topics
///
/// ### Creating Instances
///
/// - ``instantiate(gameObject:)``
public protocol Instantiable {
    /// Creates a new instance of this type attached to the specified GameObject.
    ///
    /// Implementations should create a new instance of the conforming type, copy any
    /// relevant state from the current instance, and attach it to the provided GameObject.
    ///
    /// - Parameter gameObject: The GameObject to attach the new instance to
    /// - Returns: The newly created instance
    ///
    /// ## Example
    ///
    /// ```swift
    /// class HealthComponent: Component, Instantiable {
    ///     var maxHealth: Float = 100
    ///     var currentHealth: Float = 100
    ///
    ///     func instantiate(gameObject: GameObject) -> Self {
    ///         let component = gameObject.addComponent(HealthComponent.self)
    ///         component.maxHealth = self.maxHealth
    ///         component.currentHealth = self.maxHealth  // Reset to full health
    ///         return component as! Self
    ///     }
    /// }
    /// ```
    func instantiate(gameObject: GameObject) -> Self
}
