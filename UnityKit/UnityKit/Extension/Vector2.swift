import UIKit

public struct Vector2 {
    public let x: Float
    public let y: Float

    public init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
}

extension Vector2 {
    public func toCGPoint() -> CGPoint {
        return CGPoint(x: self.x.toCGFloat(), y: self.y.toCGFloat())
    }
}

extension CGSize {
    public func toVector2() -> Vector2 {
        return Vector2(self.width.toFloat(), self.height.toFloat())
    }
}

extension CGPoint {
    public func toVector2() -> Vector2 {
        return Vector2(self.x.toFloat(), self.y.toFloat())
    }
}

extension Vector2: Equatable {
    public static func == (left: Vector2, right: Vector2) -> Bool {
        return left.x == right.x && left.y == right.y
    }
}

extension Vector2 {
    public static var zero: Vector2 {
        return Vector2(0, 0)
    }

    public static var one: Vector2 {
        return Vector2(1, 1)
    }

    /**
     * Returns the length (magnitude) of the vector described by the Vector2
     */
    public func length() -> Float {
        return Vector2.length(self)
    }

    public static func length(_ vector: Vector2) -> Float {
        return sqrtf(vector.x * vector.x + vector.y * vector.y)
    }

    /**
     * Returns the distance between a and b.
     */
    public func distance(_ vector: Vector2) -> Float {
        return Vector2.distance(self, vector)
    }

    public static func distance(_ a: Vector2, _ b: Vector2) -> Float {
        return (b - a).length()
    }
}

/**
 * Adds two Vector2 vectors and returns the result as a new Vector2.
 */
public func + (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x + right.x, left.y + right.y)
}

/**
 * Increments a Vector2 with the value of another.
 */
public func += ( left: inout Vector2, right: Vector2) {
    left = left + right
}

/**
 * Subtracts two Vector2 vectors and returns the result as a new Vector2.
 */
public func - (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x - right.x, left.y - right.y)
}

/**
 * Decrements a Vector2 with the value of another.
 */
public func -= ( left: inout Vector2, right: Vector2) {
    left = left - right
}

/**
 * Multiplies two Vector2 vectors and returns the result as a new Vector2.
 */
public func * (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x * right.x, left.y * right.y)
}

/**
 * Multiplies a Vector2 with another.
 */
public func *= (left: inout Vector2, right: Vector2) {
    left = left * right
}

/**
 * Multiplies the x, y and z fields of a Vector2 with the same scalar value and
 * returns the result as a new Vector2.
 */
public func * (vector: Vector2, scalar: Float) -> Vector2 {
    return Vector2(vector.x * scalar, vector.y * scalar)
}
public func * (scalar: Float, vector: Vector2) -> Vector2 {
    return Vector2(vector.x * scalar, vector.y * scalar)
}

/**
 * Multiplies the x and y fields of a Vector2 with the same scalar value.
 */
public func *= (vector: inout Vector2, scalar: Float) {
    vector = vector * scalar
}

/**
 * Divides two Vector2 vectors abd returns the result as a new Vector2
 */
public func / (left: Vector2, right: Vector2) -> Vector2 {
    return Vector2(left.x / right.x, left.y / right.y)
}

/**
 * Divides a Vector2 by another.
 */
public func /= ( left: inout Vector2, right: Vector2) {
    left = left / right
}

/**
 * Divides the x, y and z fields of a Vector2 by the same scalar value and
 * returns the result as a new Vector2.
 */
public func / (vector: Vector2, scalar: Float) -> Vector2 {
    return Vector2(vector.x / scalar, vector.y / scalar)
}

/**
 * Divides the x, y and z of a Vector2 by the same scalar value.
 */
public func /= ( vector: inout Vector2, scalar: Float) {
    vector = vector / scalar
}
