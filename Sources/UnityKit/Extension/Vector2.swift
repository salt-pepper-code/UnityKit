import UIKit

/// A 2D vector type representing position, direction, or velocity in 2D space.
///
/// `Vector2` provides 2D vector mathematics operations and utilities for working with
/// two-dimensional coordinates, commonly used in UI positioning, 2D physics, and more.
///
/// ## Overview
///
/// Vector2 provides operations for 2D vector mathematics including:
/// - Arithmetic operations (addition, subtraction, multiplication, division)
/// - Geometric operations (distance, length)
/// - Common constants (zero, one)
/// - Conversion utilities to and from CGPoint and CGSize
///
/// ## Example Usage
///
/// ```swift
/// // Create vectors
/// let position = Vector2(100, 200)
/// let velocity = Vector2(5, -3)
///
/// // Vector arithmetic
/// let newPosition = position + velocity
///
/// // Calculate distance
/// let distance = position.distance(Vector2.zero)
///
/// // Convert to CGPoint for UIKit
/// let point = position.toCGPoint()
/// ```
public struct Vector2 {
    /// The x component of the vector.
    public let x: Float

    /// The y component of the vector.
    public let y: Float

    /// Creates a 2D vector with specified components.
    ///
    /// - Parameters:
    ///   - x: The x component.
    ///   - y: The y component.
    public init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
}

public extension Vector2 {
    /// Converts this vector to a CGPoint.
    ///
    /// - Returns: A CGPoint with the same x and y values.
    ///
    /// ```swift
    /// let vector = Vector2(100, 200)
    /// let point = vector.toCGPoint()
    /// // point = CGPoint(x: 100, y: 200)
    /// ```
    func toCGPoint() -> CGPoint {
        return CGPoint(x: self.x.toCGFloat(), y: self.y.toCGFloat())
    }
}

public extension CGSize {
    /// Converts this CGSize to a Vector2.
    ///
    /// - Returns: A Vector2 with x=width and y=height.
    ///
    /// ```swift
    /// let size = CGSize(width: 320, height: 480)
    /// let vector = size.toVector2()
    /// // vector = Vector2(320, 480)
    /// ```
    func toVector2() -> Vector2 {
        return Vector2(self.width.toFloat(), self.height.toFloat())
    }
}

public extension CGPoint {
    /// Converts this CGPoint to a Vector2.
    ///
    /// - Returns: A Vector2 with the same x and y values.
    ///
    /// ```swift
    /// let point = CGPoint(x: 50, y: 75)
    /// let vector = point.toVector2()
    /// // vector = Vector2(50, 75)
    /// ```
    func toVector2() -> Vector2 {
        return Vector2(self.x.toFloat(), self.y.toFloat())
    }
}

extension Vector2: Equatable {
    /// Compares two Vector2 instances for equality.
    ///
    /// - Parameters:
    ///   - left: The first vector.
    ///   - right: The second vector.
    /// - Returns: `true` if both components are equal, `false` otherwise.
    public static func == (left: Vector2, right: Vector2) -> Bool {
        return left.x == right.x && left.y == right.y
    }
}

public extension Vector2 {
    /// A vector with all components set to zero (0, 0).
    ///
    /// Use this to represent the origin point or a null vector.
    ///
    /// ```swift
    /// let origin = Vector2.zero
    /// // origin = Vector2(0, 0)
    /// ```
    static var zero: Vector2 {
        return Vector2(0, 0)
    }

    /// A vector with all components set to one (1, 1).
    ///
    /// Useful for uniform scaling or as a basis vector.
    ///
    /// ```swift
    /// let scale = Vector2.one
    /// // scale = Vector2(1, 1)
    /// ```
    static var one: Vector2 {
        return Vector2(1, 1)
    }

    /// Returns the length (magnitude) of this vector.
    ///
    /// Calculates the Euclidean distance from the origin to this point.
    ///
    /// - Returns: The length of the vector as a Float.
    ///
    /// ```swift
    /// let vector = Vector2(3, 4)
    /// let length = vector.length()
    /// // length = 5.0
    /// ```
    func length() -> Float {
        return Vector2.length(self)
    }

    /// Calculates the length (magnitude) of a vector.
    ///
    /// - Parameter vector: The vector to measure.
    /// - Returns: The length of the vector.
    ///
    /// The length is calculated as: √(x² + y²)
    static func length(_ vector: Vector2) -> Float {
        return sqrtf(vector.x * vector.x + vector.y * vector.y)
    }

    /// Calculates the distance between this vector and another.
    ///
    /// - Parameter vector: The target vector.
    /// - Returns: The Euclidean distance between the two points.
    ///
    /// ```swift
    /// let pointA = Vector2(0, 0)
    /// let pointB = Vector2(3, 4)
    /// let distance = pointA.distance(pointB)
    /// // distance = 5.0
    /// ```
    func distance(_ vector: Vector2) -> Float {
        return Vector2.distance(self, vector)
    }

    /// Calculates the distance between two vectors.
    ///
    /// - Parameters:
    ///   - a: The first vector.
    ///   - b: The second vector.
    /// - Returns: The Euclidean distance between the two points.
    static func distance(_ a: Vector2, _ b: Vector2) -> Float {
        return (b - a).length()
    }
}

// MARK: - Vector2 Arithmetic Operators

/// Adds two Vector2 vectors component-wise.
///
/// - Parameters:
///   - left: The first vector.
///   - right: The second vector.
/// - Returns: A new vector with each component being the sum of the corresponding components.
///
/// ```swift
/// let a = Vector2(1, 2)
/// let b = Vector2(3, 4)
/// let sum = a + b
/// // sum = Vector2(4, 6)
/// ```
public func + (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x + right.x, left.y + right.y)
}

/// Adds a Vector2 to another in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The vector to add.
public func += (left: inout Vector2, right: Vector2) {
    left = left + right
}

/// Subtracts two Vector2 vectors component-wise.
///
/// - Parameters:
///   - left: The vector to subtract from.
///   - right: The vector to subtract.
/// - Returns: A new vector with each component being the difference of the corresponding components.
///
/// ```swift
/// let a = Vector2(5, 7)
/// let b = Vector2(2, 3)
/// let diff = a - b
/// // diff = Vector2(3, 4)
/// ```
public func - (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x - right.x, left.y - right.y)
}

/// Subtracts a Vector2 from another in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The vector to subtract.
public func -= (left: inout Vector2, right: Vector2) {
    left = left - right
}

/// Multiplies two Vector2 vectors component-wise.
///
/// - Parameters:
///   - left: The first vector.
///   - right: The second vector.
/// - Returns: A new vector with each component being the product of the corresponding components.
///
/// ```swift
/// let a = Vector2(2, 3)
/// let b = Vector2(4, 5)
/// let product = a * b
/// // product = Vector2(8, 15)
/// ```
public func * (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x * right.x, left.y * right.y)
}

/// Multiplies a Vector2 by another component-wise, in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The vector to multiply by.
public func *= (left: inout Vector2, right: Vector2) {
    left = left * right
}

/// Multiplies all components of a Vector2 by a scalar value.
///
/// - Parameters:
///   - vector: The vector.
///   - scalar: The scalar multiplier.
/// - Returns: A new vector with each component multiplied by the scalar.
///
/// ```swift
/// let velocity = Vector2(10, 5)
/// let doubled = velocity * 2.0
/// // doubled = Vector2(20, 10)
/// ```
public func * (vector: Vector2, scalar: Float) -> Vector2 {
    return Vector2(vector.x * scalar, vector.y * scalar)
}

/// Multiplies all components of a Vector2 by a scalar value.
///
/// - Parameters:
///   - scalar: The scalar multiplier.
///   - vector: The vector.
/// - Returns: A new vector with each component multiplied by the scalar.
public func * (scalar: Float, vector: Vector2) -> Vector2 {
    return Vector2(vector.x * scalar, vector.y * scalar)
}

/// Multiplies all components of a Vector2 by a scalar value, in place.
///
/// - Parameters:
///   - vector: The vector to modify.
///   - scalar: The scalar multiplier.
public func *= (vector: inout Vector2, scalar: Float) {
    vector = vector * scalar
}

/// Divides two Vector2 vectors component-wise.
///
/// - Parameters:
///   - left: The dividend vector.
///   - right: The divisor vector.
/// - Returns: A new vector with each component being the quotient of the corresponding components.
///
/// ```swift
/// let a = Vector2(10, 20)
/// let b = Vector2(2, 4)
/// let quotient = a / b
/// // quotient = Vector2(5, 5)
/// ```
public func / (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x / right.x, left.y / right.y)
}

/// Divides a Vector2 by another component-wise, in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The divisor vector.
public func /= (left: inout Vector2, right: Vector2) {
    left = left / right
}

/// Divides all components of a Vector2 by a scalar value.
///
/// - Parameters:
///   - vector: The vector.
///   - scalar: The scalar divisor.
/// - Returns: A new vector with each component divided by the scalar.
///
/// ```swift
/// let vector = Vector2(10, 20)
/// let halved = vector / 2.0
/// // halved = Vector2(5, 10)
/// ```
public func / (vector: Vector2, scalar: Float) -> Vector2 {
    return Vector2(vector.x / scalar, vector.y / scalar)
}

/// Divides all components of a Vector2 by a scalar value, in place.
///
/// - Parameters:
///   - vector: The vector to modify.
///   - scalar: The scalar divisor.
public func /= (vector: inout Vector2, scalar: Float) {
    vector = vector / scalar
}
