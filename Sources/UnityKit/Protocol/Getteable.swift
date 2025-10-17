import CoreGraphics

/// A protocol marking types that can be retrieved from component properties.
///
/// ``Getteable`` is a marker protocol used to constrain generic types in the UnityKit API,
/// particularly in animation and property manipulation systems. Types conforming to this
/// protocol can be safely used with certain getter/setter operations.
///
/// ## Overview
///
/// This protocol doesn't require any methods or properties to be implemented. It simply
/// serves as a type constraint to ensure type safety when working with animatable or
/// retrievable values in the UnityKit framework.
///
/// ## Conforming Types
///
/// UnityKit provides default conformance for common value types:
/// - `Bool` - Boolean values
/// - `Float` - Single-precision floating point numbers
/// - `CGFloat` - Core Graphics floating point numbers
/// - `Vector3` - 3D vectors (position, scale, rotation)
/// - `Vector4` - 4D vectors (colors, quaternions)
///
/// ## Example Usage
///
/// ```swift
/// // The protocol is typically used as a constraint in generic functions
/// func getValue<T: Getteable>(from component: Component, keyPath: KeyPath<Component, T>) -> T {
///     return component[keyPath: keyPath]
/// }
///
/// // Used with animations or property accessors
/// class AnimationSystem {
///     func animate<T: Getteable>(_ property: WritableKeyPath<Transform, T>,
///                                from: T,
///                                to: T,
///                                duration: Float) {
///         // Animation logic
///     }
/// }
/// ```
///
/// ## Extending Getteable
///
/// You can extend your own types to conform to Getteable:
///
/// ```swift
/// struct CustomColor {
///     var r, g, b, a: Float
/// }
///
/// extension CustomColor: Getteable {}
///
/// // Now CustomColor can be used with systems that require Getteable
/// ```
///
/// ## Topics
///
/// ### Built-in Conformances
///
/// - `Bool`
/// - `Float`
/// - `CGFloat`
/// - `Vector3`
/// - `Vector4`
public protocol Getteable {}

/// Conformance for Boolean values.
extension Bool: Getteable {}

/// Conformance for single-precision floating point numbers.
extension Float: Getteable {}

/// Conformance for Core Graphics floating point numbers.
extension CGFloat: Getteable {}

/// Conformance for 3D vector types.
extension Vector3: Getteable {}

/// Conformance for 4D vector types.
extension Vector4: Getteable {}
