import AVKit
import SceneKit

public typealias Vector3 = SCNVector3

public struct Vector3Nullable {
    public let x: Float?
    public let y: Float?
    public let z: Float?

    public init(_ x: Float?, _ y: Float?, _ z: Float?) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public extension Vector3 {
    static var zero: Vector3 {
        return SCNVector3Zero
    }

    static var one: Vector3 {
        return Vector3(1, 1, 1)
    }

    static var back: Vector3 {
        return Vector3(0, 0, -1)
    }

    static var down: Vector3 {
        return Vector3(0, -1, 0)
    }

    static var forward: Vector3 {
        return Vector3(0, 0, 1)
    }

    static var left: Vector3 {
        return Vector3(-1, 0, 0)
    }

    static var right: Vector3 {
        return Vector3(1, 0, 0)
    }

    static var up: Vector3 {
        return Vector3(0, 1, 0)
    }

    /**
     * Negates the vector described by Vector3 and returns
     * the result as a new Vector3.
     */
    func negated() -> Vector3 {
        return self * -1
    }

    /**
     * Negates the vector described by Vector3
     */
    mutating func negate() {
        self = self.negated()
    }

    /**
     * Returns the length (magnitude) of the vector described by the Vector3
     */
    func length() -> Float {
        return Vector3.length(self)
    }

    static func length(_ vector: Vector3) -> Float {
        return sqrtf(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
    }

    func magnitude() -> Float {
        return Vector3.length(self)
    }

    /**
     * Normalizes the vector described by the Vector3 to length 1.0 and returns
     * the result as a new Vector3.
     */
    func normalized() -> Vector3 {
        return Vector3.normalized(self)
    }

    static func normalized(_ vector: Vector3) -> Vector3 {
        let lenght = vector.length()
        guard lenght != 0
        else { return .zero }
        return vector / lenght
    }

    mutating func normalize() {
        self = self.normalized()
    }

    /**
     * Returns the distance between a and b.
     */
    func distance(_ vector: Vector3) -> Float {
        return Vector3.distance(self, vector)
    }

    static func distance(_ a: Vector3, _ b: Vector3) -> Float {
        return (b - a).length()
    }

    /**
     * Calculates the dot product between two Vector3.
     */
    func dot(_ vector: Vector3) -> Float {
        return Vector3.dot(self, vector)
    }

    static func dot(_ a: Vector3, _ b: Vector3) -> Float {
        return (a.x * b.x) + (a.y * b.y) + (a.z * b.z)
    }

    /**
     * Projects a vector onto another vector.
     */
    func project(_ normal: Vector3) -> Vector3 {
        return Vector3.project(self, normal)
    }

    static func project(_ vector: Vector3, _ onNormal: Vector3) -> Vector3 {
        return Vector3.scale(Vector3.dot(vector, onNormal) / Vector3.dot(onNormal, onNormal), onNormal)
    }

    /**
     * Cross Product of two vectors.
     */
    func cross(_ vector: Vector3) -> Vector3 {
        return Vector3.cross(self, vector)
    }

    static func cross(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
    }

    func degreesToRadians() -> Vector3 {
        return Vector3(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians)
    }

    func radiansToDegrees() -> Vector3 {
        return Vector3(x.radiansToDegrees, y.radiansToDegrees, z.radiansToDegrees)
    }

    func angleClamp() -> Vector3 {
        return Vector3(x.clampDegree(), y.clampDegree(), z.clampDegree())
    }

    /**
     * Multiplies two vectors component-wise.
     */
    static func scale(_ factor: Float, _ vector: Vector3) -> Vector3 {
        return factor * vector
    }

    /**
     * Calculates the SCNVector from lerping between two Vector3 vectors
     */
    static func lerp(from v0: Vector3, to v1: Vector3, time t: TimeInterval) -> Vector3 {
        return Float(1 - t) * v0 + Float(t) * v1
    }

    /**
     * Linearly interpolates between two vectors (Unity-style API)
     */
    static func Lerp(_ a: Vector3, _ b: Vector3, _ t: Float) -> Vector3 {
        let clampedT = max(0, min(1, t))
        return a + (b - a) * clampedT
    }

    /**
     * Calculates the angle in degrees between two vectors
     */
    static func Angle(_ from: Vector3, _ to: Vector3) -> Float {
        let denominator = sqrt(from.length() * from.length() * to.length() * to.length())
        if denominator < 1e-15 {
            return 0
        }

        let dotProduct = Vector3.dot(from, to)
        let clampedDot = max(-1, min(1, dotProduct / denominator))
        return acos(clampedDot) * (180.0 / .pi)
    }

    /**
     * Moves a point current towards target by maxDistanceDelta
     */
    static func MoveTowards(_ current: Vector3, _ target: Vector3, _ maxDistanceDelta: Float) -> Vector3 {
        let direction = target - current
        let distance = direction.length()

        if distance <= maxDistanceDelta || distance < 1e-15 {
            return target
        }

        return current + direction / distance * maxDistanceDelta
    }

    /**
     * Returns a vector with the smallest components of the two vectors
     */
    static func Min(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(
            min(a.x, b.x),
            min(a.y, b.y),
            min(a.z, b.z)
        )
    }

    /**
     * Returns a vector with the largest components of the two vectors
     */
    static func Max(_ a: Vector3, _ b: Vector3) -> Vector3 {
        return Vector3(
            max(a.x, b.x),
            max(a.y, b.y),
            max(a.z, b.z)
        )
    }

    /**
     * Returns a copy of vector with its magnitude clamped to maxLength
     */
    static func ClampMagnitude(_ vector: Vector3, _ maxLength: Float) -> Vector3 {
        let length = vector.length()
        if length > maxLength {
            return vector.normalized() * maxLength
        }
        return vector
    }

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

    internal func toAVAudio3DPoint() -> AVAudio3DPoint {
        return AVAudio3DPoint(x: x, y: y, z: z)
    }
}

extension Vector3: @retroactive Equatable {
    public static func == (left: Vector3, right: Vector3) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }

    public static func != (left: Vector3, right: Vector3) -> Bool {
        return !(left == right)
    }
}

/**
 * Adds two Vector3 vectors and returns the result as a new Vector3.
 */
public func + (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
 * Increments a Vector3 with the value of another.
 */
public func += (left: inout Vector3, right: Vector3) {
    left = left + right
}

/**
 * Subtracts two Vector3 vectors and returns the result as a new Vector3.
 */
public func - (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
 * Decrements a Vector3 with the value of another.
 */
public func -= (left: inout Vector3, right: Vector3) {
    left = left - right
}

public func + (left: Vector3, right: Float) -> Vector3 {
    return Vector3(left.x + right, left.y + right, left.z + right)
}

public func += (left: inout Vector3, right: Float) {
    left = left + right
}

public func - (left: Vector3, right: Float) -> Vector3 {
    return Vector3(left.x - right, left.y - right, left.z - right)
}

public func -= (left: inout Vector3, right: Float) {
    left = left - right
}

/**
 * Multiplies two Vector3 vectors and returns the result as a new Vector3.
 */
public func * (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
 * Multiplies a Vector3 with another.
 */
public func *= (left: inout Vector3, right: Vector3) {
    left = left * right
}

/**
 * Multiplies the x, y and z fields of a Vector3 with the same scalar value and
 * returns the result as a new Vector3.
 */
public func * (vector: Vector3, scalar: Float) -> Vector3 {
    return Vector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

public func * (scalar: Float, vector: Vector3) -> Vector3 {
    return Vector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

/**
 * Multiplies the x and y fields of a Vector3 with the same scalar value.
 */
public func *= (vector: inout Vector3, scalar: Float) {
    vector = vector * scalar
}

/**
 * Divides two Vector3 vectors abd returns the result as a new Vector3
 */
public func / (left: Vector3, right: Vector3) -> Vector3 {
    return Vector3(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
 * Divides a Vector3 by another.
 */
public func /= (left: inout Vector3, right: Vector3) {
    left = left / right
}

/**
 * Divides the x, y and z fields of a Vector3 by the same scalar value and
 * returns the result as a new Vector3.
 */
public func / (vector: Vector3, scalar: Float) -> Vector3 {
    return Vector3(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

/**
 * Divides the x, y and z of a Vector3 by the same scalar value.
 */
public func /= (vector: inout Vector3, scalar: Float) {
    vector = vector / scalar
}
