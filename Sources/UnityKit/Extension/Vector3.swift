import AVKit
import SceneKit

/// A 3D vector type representing position, direction, or velocity in 3D space.
///
/// `Vector3` is a type alias for `SCNVector3` that provides Unity-style vector operations
/// and utilities for 3D mathematics. It contains x, y, and z components.
///
/// ## Overview
///
/// Vector3 provides a comprehensive set of operations for 3D vector mathematics including:
/// - Arithmetic operations (addition, subtraction, multiplication, division)
/// - Geometric operations (dot product, cross product, projection)
/// - Utility functions (normalization, distance, lerping)
/// - Common direction constants (up, down, left, right, forward, back)
///
/// ## Example Usage
///
/// ```swift
/// // Create vectors
/// let position = Vector3(1, 2, 3)
/// let direction = Vector3.forward
///
/// // Vector arithmetic
/// let newPosition = position + direction * 5
///
/// // Calculate distance
/// let distance = position.distance(Vector3.zero)
///
/// // Normalize a vector
/// let normalized = direction.normalized()
/// ```
public typealias Vector3 = SCNVector3

/// A nullable variant of Vector3 that allows optional components.
///
/// Use this type when you need to represent a vector with potentially missing components,
/// such as when parsing incomplete data or handling optional updates to specific axes.
public struct Vector3Nullable {
    /// The x component, or nil if not specified.
    public let x: Float?

    /// The y component, or nil if not specified.
    public let y: Float?

    /// The z component, or nil if not specified.
    public let z: Float?

    /// Creates a vector with optional components.
    ///
    /// - Parameters:
    ///   - x: The optional x component.
    ///   - y: The optional y component.
    ///   - z: The optional z component.
    public init(_ x: Float?, _ y: Float?, _ z: Float?) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public extension Vector3 {
    /// A vector with all components set to zero (0, 0, 0).
    ///
    /// Use this to represent the origin point or a null vector.
    ///
    /// ```swift
    /// let origin = Vector3.zero
    /// // origin = Vector3(0, 0, 0)
    /// ```
    static var zero: Vector3 {
        return SCNVector3Zero
    }

    /// A vector with all components set to one (1, 1, 1).
    ///
    /// Useful for uniform scaling or as a basis vector.
    ///
    /// ```swift
    /// let scale = Vector3.one
    /// // scale = Vector3(1, 1, 1)
    /// ```
    static var one: Vector3 {
        return Vector3(1, 1, 1)
    }

    /// A unit vector pointing backwards (0, 0, -1).
    ///
    /// Represents the negative Z-axis direction.
    ///
    /// ```swift
    /// let backward = Vector3.back
    /// // backward = Vector3(0, 0, -1)
    /// ```
    static var back: Vector3 {
        return Vector3(0, 0, -1)
    }

    /// A unit vector pointing down (0, -1, 0).
    ///
    /// Represents the negative Y-axis direction.
    ///
    /// ```swift
    /// let gravity = Vector3.down * 9.8
    /// ```
    static var down: Vector3 {
        return Vector3(0, -1, 0)
    }

    /// A unit vector pointing forward (0, 0, 1).
    ///
    /// Represents the positive Z-axis direction. This is the default forward
    /// direction in Unity and SceneKit.
    ///
    /// ```swift
    /// let moveForward = Vector3.forward * speed
    /// ```
    static var forward: Vector3 {
        return Vector3(0, 0, 1)
    }

    /// A unit vector pointing left (-1, 0, 0).
    ///
    /// Represents the negative X-axis direction.
    ///
    /// ```swift
    /// let strafeLeft = Vector3.left * speed
    /// ```
    static var left: Vector3 {
        return Vector3(-1, 0, 0)
    }

    /// A unit vector pointing right (1, 0, 0).
    ///
    /// Represents the positive X-axis direction.
    ///
    /// ```swift
    /// let strafeRight = Vector3.right * speed
    /// ```
    static var right: Vector3 {
        return Vector3(1, 0, 0)
    }

    /// A unit vector pointing up (0, 1, 0).
    ///
    /// Represents the positive Y-axis direction. This is the default up
    /// direction in Unity and SceneKit.
    ///
    /// ```swift
    /// let jump = Vector3.up * jumpForce
    /// ```
    static var up: Vector3 {
        return Vector3(0, 1, 0)
    }

    /// Returns the negation of this vector.
    ///
    /// Creates a new vector pointing in the opposite direction with the same magnitude.
    ///
    /// - Returns: A new vector with all components negated.
    ///
    /// ```swift
    /// let forward = Vector3(0, 0, 1)
    /// let backward = forward.negated()
    /// // backward = Vector3(0, 0, -1)
    /// ```
    func negated() -> Vector3 {
        return self * -1
    }

    /// Negates this vector in place.
    ///
    /// Flips the direction of this vector while maintaining its magnitude.
    ///
    /// ```swift
    /// var direction = Vector3(1, 2, 3)
    /// direction.negate()
    /// // direction = Vector3(-1, -2, -3)
    /// ```
    mutating func negate() {
        self = self.negated()
    }

    /// Returns the length (magnitude) of this vector.
    ///
    /// Calculates the Euclidean distance from the origin to this point.
    ///
    /// - Returns: The length of the vector as a Float.
    ///
    /// ```swift
    /// let vector = Vector3(3, 4, 0)
    /// let length = vector.length()
    /// // length = 5.0
    /// ```
    func length() -> Float {
        return Vector3.length(self)
    }

    /// Calculates the length (magnitude) of a vector.
    ///
    /// - Parameter vector: The vector to measure.
    /// - Returns: The length of the vector.
    ///
    /// The length is calculated as: √(x² + y² + z²)
    static func length(_ vector: Vector3) -> Float {
        return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    }

    /// Returns the magnitude (length) of this vector.
    ///
    /// This is an alias for `length()`.
    ///
    /// - Returns: The magnitude of the vector as a Float.
    func magnitude() -> Float {
        return Vector3.length(self)
    }

    /// Returns a normalized copy of this vector with length 1.0.
    ///
    /// Preserves the direction but scales to unit length. Returns zero vector
    /// if the original length is zero.
    ///
    /// - Returns: A unit vector in the same direction, or zero if length is zero.
    ///
    /// ```swift
    /// let vector = Vector3(3, 4, 0)
    /// let unit = vector.normalized()
    /// // unit = Vector3(0.6, 0.8, 0)
    /// // unit.length() = 1.0
    /// ```
    func normalized() -> Vector3 {
        return Vector3.normalized(self)
    }

    /// Returns a normalized copy of a vector with length 1.0.
    ///
    /// - Parameter vector: The vector to normalize.
    /// - Returns: A unit vector in the same direction, or zero if length is zero.
    static func normalized(_ vector: Vector3) -> Vector3 {
        let lenght = vector.length()
        guard lenght != 0
        else { return .zero }
        return vector / lenght
    }

    /// Normalizes this vector in place to length 1.0.
    ///
    /// Converts this vector to a unit vector while maintaining direction.
    ///
    /// ```swift
    /// var vector = Vector3(0, 5, 0)
    /// vector.normalize()
    /// // vector = Vector3(0, 1, 0)
    /// ```
    mutating func normalize() {
        self = self.normalized()
    }

    /// Calculates the distance between this vector and another.
    ///
    /// - Parameter vector: The target vector.
    /// - Returns: The Euclidean distance between the two points.
    ///
    /// ```swift
    /// let pointA = Vector3(0, 0, 0)
    /// let pointB = Vector3(3, 4, 0)
    /// let distance = pointA.distance(pointB)
    /// // distance = 5.0
    /// ```
    func distance(_ vector: Vector3) -> Float {
        return Vector3.distance(self, vector)
    }

    /// Calculates the distance between two vectors.
    ///
    /// - Parameters:
    ///   - a: The first vector.
    ///   - b: The second vector.
    /// - Returns: The Euclidean distance between the two points.
    static func distance(_ a: Vector3, _ b: Vector3) -> Float {
        return (b - a).length()
    }

    /// Calculates the dot product between this vector and another.
    ///
    /// The dot product represents the cosine of the angle between vectors
    /// (when normalized) and is useful for determining how aligned two vectors are.
    ///
    /// - Parameter vector: The other vector.
    /// - Returns: The dot product as a Float.
    ///
    /// ```swift
    /// let a = Vector3(1, 0, 0)
    /// let b = Vector3(0, 1, 0)
    /// let dot = a.dot(b)
    /// // dot = 0.0 (perpendicular)
    /// ```
    func dot(_ vector: Vector3) -> Float {
        return Vector3.dot(self, vector)
    }

    /// Calculates the dot product between two vectors.
    ///
    /// - Parameters:
    ///   - a: The first vector.
    ///   - b: The second vector.
    /// - Returns: The dot product: (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
    ///
    /// ```swift
    /// let dot = Vector3.dot(Vector3.forward, Vector3.back)
    /// // dot = -1.0 (opposite directions)
    /// ```
    static func dot(_ a: Vector3, _ b: Vector3) -> Float {
        return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
    }

    /// Projects this vector onto a normal vector.
    ///
    /// Finds the component of this vector that lies along the normal direction.
    ///
    /// - Parameter normal: The normal vector to project onto.
    /// - Returns: The projected vector along the normal.
    ///
    /// ```swift
    /// let velocity = Vector3(5, 5, 0)
    /// let surfaceNormal = Vector3(0, 1, 0)
    /// let verticalComponent = velocity.project(surfaceNormal)
    /// // verticalComponent = Vector3(0, 5, 0)
    /// ```
    func project(_ normal: Vector3) -> Vector3 {
        return Vector3.project(self, normal)
    }

    /// Projects a vector onto another vector.
    ///
    /// - Parameters:
    ///   - vector: The vector to project.
    ///   - onNormal: The normal vector to project onto.
    /// - Returns: The projection of vector onto onNormal.
    static func project(_ vector: Vector3, _ onNormal: Vector3) -> Vector3 {
        return Vector3.scale(Vector3.dot(vector, onNormal) / Vector3.dot(onNormal, onNormal), onNormal)
    }

    /// Calculates the cross product between this vector and another.
    ///
    /// The cross product produces a vector perpendicular to both input vectors,
    /// following the right-hand rule. Useful for calculating surface normals.
    ///
    /// - Parameter vector: The other vector.
    /// - Returns: A vector perpendicular to both input vectors.
    ///
    /// ```swift
    /// let right = Vector3.right
    /// let up = Vector3.up
    /// let forward = right.cross(up)
    /// // forward points in the forward direction
    /// ```
    func cross(_ vector: Vector3) -> Vector3 {
        return Vector3.cross(self, vector)
    }

    /// Calculates the cross product between two vectors.
    ///
    /// - Parameters:
    ///   - a: The first vector.
    ///   - b: The second vector.
    /// - Returns: A vector perpendicular to both a and b.
    ///
    /// The magnitude equals |a| * |b| * sin(θ), where θ is the angle between vectors.
    static func cross(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
    }

    /// Converts each component from degrees to radians.
    ///
    /// Useful for converting Euler angles from degrees to radians.
    ///
    /// - Returns: A new vector with each component converted to radians.
    ///
    /// ```swift
    /// let eulerDegrees = Vector3(90, 180, 45)
    /// let eulerRadians = eulerDegrees.degreesToRadians()
    /// ```
    func degreesToRadians() -> Vector3 {
        return Vector3(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians)
    }

    /// Converts each component from radians to degrees.
    ///
    /// Useful for converting Euler angles from radians to degrees.
    ///
    /// - Returns: A new vector with each component converted to degrees.
    ///
    /// ```swift
    /// let eulerRadians = Vector3(.pi/2, .pi, .pi/4)
    /// let eulerDegrees = eulerRadians.radiansToDegrees()
    /// // eulerDegrees = Vector3(90, 180, 45)
    /// ```
    func radiansToDegrees() -> Vector3 {
        return Vector3(x.radiansToDegrees, y.radiansToDegrees, z.radiansToDegrees)
    }

    /// Clamps each component to the range [0, 360] degrees.
    ///
    /// Useful for normalizing Euler angles.
    ///
    /// - Returns: A new vector with each component clamped to valid degree range.
    func angleClamp() -> Vector3 {
        return Vector3(x.clampDegree(), y.clampDegree(), z.clampDegree())
    }

    /// Scales a vector by a scalar factor.
    ///
    /// - Parameters:
    ///   - factor: The scale factor.
    ///   - vector: The vector to scale.
    /// - Returns: The scaled vector.
    ///
    /// ```swift
    /// let scaled = Vector3.scale(2.5, Vector3(1, 2, 3))
    /// // scaled = Vector3(2.5, 5.0, 7.5)
    /// ```
    static func scale(_ factor: Float, _ vector: Vector3) -> Vector3 {
        return factor * vector
    }

    /// Linearly interpolates between two vectors over time.
    ///
    /// - Parameters:
    ///   - v0: The starting vector.
    ///   - v1: The ending vector.
    ///   - t: The interpolation time (0.0 to 1.0).
    /// - Returns: The interpolated vector.
    ///
    /// ```swift
    /// let start = Vector3.zero
    /// let end = Vector3(10, 10, 10)
    /// let midpoint = Vector3.lerp(from: start, to: end, time: 0.5)
    /// // midpoint = Vector3(5, 5, 5)
    /// ```
    static func lerp(from v0: Vector3, to v1: Vector3, time t: TimeInterval) -> Vector3 {
        return Float(1 - t) * v0 + Float(t) * v1
    }

    /// Linearly interpolates between two vectors (Unity-style API).
    ///
    /// Clamps the interpolation parameter to [0, 1] range.
    ///
    /// - Parameters:
    ///   - a: The start vector.
    ///   - b: The end vector.
    ///   - t: The interpolation parameter (clamped to 0-1).
    /// - Returns: The interpolated vector.
    ///
    /// ```swift
    /// let result = Vector3.Lerp(Vector3.zero, Vector3.one, 0.75)
    /// // result = Vector3(0.75, 0.75, 0.75)
    /// ```
    static func Lerp(_ a: Vector3, _ b: Vector3, _ t: Float) -> Vector3 {
        let clampedT = max(0, min(1, t))
        return a + (b - a) * clampedT
    }

    /// Calculates the angle in degrees between two vectors.
    ///
    /// Returns the unsigned angle between the two vectors. The result is
    /// always positive and ranges from 0 to 180 degrees.
    ///
    /// - Parameters:
    ///   - from: The first vector.
    ///   - to: The second vector.
    /// - Returns: The angle in degrees between the vectors.
    ///
    /// ```swift
    /// let angle = Vector3.Angle(Vector3.up, Vector3.forward)
    /// // angle = 90.0
    /// ```
    static func Angle(_ from: Vector3, _ to: Vector3) -> Float {
        let denominator = sqrt(from.length() * from.length() * to.length() * to.length())
        if denominator < 1e-15 {
            return 0
        }

        let dotProduct = Vector3.dot(from, to)
        let clampedDot = max(-1, min(1, dotProduct / denominator))
        return acos(clampedDot) * (180.0 / .pi)
    }

    /// Moves a point towards a target by a maximum distance.
    ///
    /// Useful for smooth movement that doesn't overshoot the target.
    ///
    /// - Parameters:
    ///   - current: The current position.
    ///   - target: The target position.
    ///   - maxDistanceDelta: The maximum distance to move.
    /// - Returns: The new position.
    ///
    /// ```swift
    /// let current = Vector3(0, 0, 0)
    /// let target = Vector3(10, 0, 0)
    /// let newPos = Vector3.MoveTowards(current, target, 2.0)
    /// // newPos = Vector3(2, 0, 0)
    /// ```
    static func MoveTowards(_ current: Vector3, _ target: Vector3, _ maxDistanceDelta: Float) -> Vector3 {
        let direction = target - current
        let distance = direction.length()

        if distance <= maxDistanceDelta || distance < 1e-15 {
            return target
        }

        return current + direction / distance * maxDistanceDelta
    }

    /// Returns a vector with the smallest components from two vectors.
    ///
    /// Compares each component independently and selects the minimum.
    ///
    /// - Parameters:
    ///   - a: The first vector.
    ///   - b: The second vector.
    /// - Returns: A vector containing the minimum of each component.
    ///
    /// ```swift
    /// let min = Vector3.Min(Vector3(5, 2, 8), Vector3(3, 7, 4))
    /// // min = Vector3(3, 2, 4)
    /// ```
    static func Min(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(
            min(a.x, b.x),
            min(a.y, b.y),
            min(a.z, b.z)
        )
    }

    /// Returns a vector with the largest components from two vectors.
    ///
    /// Compares each component independently and selects the maximum.
    ///
    /// - Parameters:
    ///   - a: The first vector.
    ///   - b: The second vector.
    /// - Returns: A vector containing the maximum of each component.
    ///
    /// ```swift
    /// let max = Vector3.Max(Vector3(5, 2, 8), Vector3(3, 7, 4))
    /// // max = Vector3(5, 7, 8)
    /// ```
    static func Max(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(
            max(a.x, b.x),
            max(a.y, b.y),
            max(a.z, b.z)
        )
    }

    /// Returns a copy of the vector with its magnitude clamped to maxLength.
    ///
    /// If the vector's length exceeds maxLength, it is scaled down to maxLength
    /// while preserving direction.
    ///
    /// - Parameters:
    ///   - vector: The vector to clamp.
    ///   - maxLength: The maximum allowed length.
    /// - Returns: The clamped vector.
    ///
    /// ```swift
    /// let velocity = Vector3(10, 0, 0)
    /// let clamped = Vector3.ClampMagnitude(velocity, 5.0)
    /// // clamped = Vector3(5, 0, 0)
    /// ```
    static func ClampMagnitude(_ vector: Vector3, _ maxLength: Float) -> Vector3 {
        let length = vector.length()
        if length > maxLength {
            return vector.normalized() * maxLength
        }
        return vector
    }

    /// Converts this Euler angle vector to a quaternion rotation.
    ///
    /// Interprets this vector as Euler angles in radians (x=pitch, y=yaw, z=roll)
    /// and converts to a quaternion representation.
    ///
    /// - Returns: A normalized quaternion representing the same rotation.
    ///
    /// ```swift
    /// let eulerAngles = Vector3(.pi/4, .pi/2, 0)
    /// let rotation = eulerAngles.toQuaternion()
    /// ```
    func toQuaternion() -> Quaternion {
        var angle: Float = 0

        angle = x * 0.5
        let sr = sin(angle)
        let cr = cos(angle)

        angle = y * 0.5
        let sp = sin(angle)
        let cp = cos(angle)

        angle = z * 0.5
        let sy = sin(angle)
        let cy = cos(angle)

        let cpcy = cp * cy
        let spcy = sp * cy
        let cpsy = cp * sy
        let spsy = sp * sy

        return Quaternion(sr * cpcy - cr * spsy, cr * spcy + sr * cpsy, cr * cpsy - sr * spcy, cr * cpcy + sr * spsy)
            .normalized()
    }

    /// Converts this vector to an AVAudio3DPoint for spatial audio.
    ///
    /// - Returns: An AVAudio3DPoint with the same x, y, z components.
    internal func toAVAudio3DPoint() -> AVAudio3DPoint {
        return AVAudio3DPoint(x: x, y: y, z: z)
    }
}

extension Vector3: @retroactive Equatable {
    /// Compares two Vector3 instances for equality.
    ///
    /// - Parameters:
    ///   - left: The first vector.
    ///   - right: The second vector.
    /// - Returns: `true` if all components are equal, `false` otherwise.
    public static func == (left: Vector3, right: Vector3) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }

    /// Compares two Vector3 instances for inequality.
    ///
    /// - Parameters:
    ///   - left: The first vector.
    ///   - right: The second vector.
    /// - Returns: `true` if any component differs, `false` otherwise.
    public static func != (left: Vector3, right: Vector3) -> Bool {
        return !(left == right)
    }
}

// MARK: - Vector3 Arithmetic Operators

/// Adds two Vector3 vectors component-wise.
///
/// - Parameters:
///   - left: The first vector.
///   - right: The second vector.
/// - Returns: A new vector with each component being the sum of the corresponding components.
///
/// ```swift
/// let a = Vector3(1, 2, 3)
/// let b = Vector3(4, 5, 6)
/// let sum = a + b
/// // sum = Vector3(5, 7, 9)
/// ```
public func + (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

/// Adds a Vector3 to another in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The vector to add.
public func += (left: inout Vector3, right: Vector3) {
    left = left + right
}

/// Subtracts two Vector3 vectors component-wise.
///
/// - Parameters:
///   - left: The vector to subtract from.
///   - right: The vector to subtract.
/// - Returns: A new vector with each component being the difference of the corresponding components.
///
/// ```swift
/// let a = Vector3(5, 7, 9)
/// let b = Vector3(1, 2, 3)
/// let diff = a - b
/// // diff = Vector3(4, 5, 6)
/// ```
public func - (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x - right.x, left.y - right.y, left.z - right.z)
}

/// Subtracts a Vector3 from another in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The vector to subtract.
public func -= (left: inout Vector3, right: Vector3) {
    left = left - right
}

/// Adds a scalar value to all components of a Vector3.
///
/// - Parameters:
///   - left: The vector.
///   - right: The scalar to add to each component.
/// - Returns: A new vector with the scalar added to each component.
public func + (left: Vector3, right: Float) -> Vector3 {
    return Vector3(left.x + right, left.y + right, left.z + right)
}

/// Adds a scalar value to all components of a Vector3 in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The scalar to add.
public func += (left: inout Vector3, right: Float) {
    left = left + right
}

/// Subtracts a scalar value from all components of a Vector3.
///
/// - Parameters:
///   - left: The vector.
///   - right: The scalar to subtract from each component.
/// - Returns: A new vector with the scalar subtracted from each component.
public func - (left: Vector3, right: Float) -> Vector3 {
    return Vector3(left.x - right, left.y - right, left.z - right)
}

/// Subtracts a scalar value from all components of a Vector3 in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The scalar to subtract.
public func -= (left: inout Vector3, right: Float) {
    left = left - right
}

/// Multiplies two Vector3 vectors component-wise.
///
/// - Parameters:
///   - left: The first vector.
///   - right: The second vector.
/// - Returns: A new vector with each component being the product of the corresponding components.
///
/// ```swift
/// let a = Vector3(2, 3, 4)
/// let b = Vector3(5, 6, 7)
/// let product = a * b
/// // product = Vector3(10, 18, 28)
/// ```
public func * (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x * right.x, left.y * right.y, left.z * right.z)
}

/// Multiplies a Vector3 by another component-wise, in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The vector to multiply by.
public func *= (left: inout Vector3, right: Vector3) {
    left = left * right
}

/// Multiplies all components of a Vector3 by a scalar value.
///
/// - Parameters:
///   - vector: The vector.
///   - scalar: The scalar multiplier.
/// - Returns: A new vector with each component multiplied by the scalar.
///
/// ```swift
/// let direction = Vector3.forward
/// let scaled = direction * 10.0
/// // scaled = Vector3(0, 0, 10)
/// ```
public func * (vector: Vector3, scalar: Float) -> Vector3 {
    return Vector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

/// Multiplies all components of a Vector3 by a scalar value.
///
/// - Parameters:
///   - scalar: The scalar multiplier.
///   - vector: The vector.
/// - Returns: A new vector with each component multiplied by the scalar.
public func * (scalar: Float, vector: Vector3) -> Vector3 {
    return Vector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

/// Multiplies all components of a Vector3 by a scalar value, in place.
///
/// - Parameters:
///   - vector: The vector to modify.
///   - scalar: The scalar multiplier.
public func *= (vector: inout Vector3, scalar: Float) {
    vector = vector * scalar
}

/// Divides two Vector3 vectors component-wise.
///
/// - Parameters:
///   - left: The dividend vector.
///   - right: The divisor vector.
/// - Returns: A new vector with each component being the quotient of the corresponding components.
///
/// ```swift
/// let a = Vector3(10, 20, 30)
/// let b = Vector3(2, 4, 5)
/// let quotient = a / b
/// // quotient = Vector3(5, 5, 6)
/// ```
public func / (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x / right.x, left.y / right.y, left.z / right.z)
}

/// Divides a Vector3 by another component-wise, in place.
///
/// - Parameters:
///   - left: The vector to modify.
///   - right: The divisor vector.
public func /= (left: inout Vector3, right: Vector3) {
    left = left / right
}

/// Divides all components of a Vector3 by a scalar value.
///
/// - Parameters:
///   - vector: The vector.
///   - scalar: The scalar divisor.
/// - Returns: A new vector with each component divided by the scalar.
///
/// ```swift
/// let vector = Vector3(10, 20, 30)
/// let halved = vector / 2.0
/// // halved = Vector3(5, 10, 15)
/// ```
public func / (vector: Vector3, scalar: Float) -> Vector3 {
    return Vector3(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

/// Divides all components of a Vector3 by a scalar value, in place.
///
/// - Parameters:
///   - vector: The vector to modify.
///   - scalar: The scalar divisor.
public func /= (vector: inout Vector3, scalar: Float) {
    vector = vector / scalar
}
