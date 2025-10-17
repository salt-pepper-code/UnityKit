import Foundation
import SceneKit

/// A 4D vector type with x, y, z, and w components.
///
/// `Vector4` is a type alias for `SCNVector4` that represents a 4-dimensional vector.
/// It can be used for homogeneous coordinates, RGBA colors, or quaternion representations.
///
/// ## Example Usage
///
/// ```swift
/// let color = Vector4(1.0, 0.5, 0.0, 1.0) // RGBA
/// let homogeneous = Vector4(x, y, z, 1.0) // Homogeneous coordinate
/// ```
public typealias Vector4 = SCNVector4

/// A quaternion type representing rotations in 3D space.
///
/// `Quaternion` is a type alias for `SCNQuaternion` that provides Unity-style quaternion
/// operations for representing and manipulating 3D rotations.
///
/// ## Overview
///
/// Quaternions provide a robust way to represent rotations without gimbal lock.
/// They consist of four components (x, y, z, w) where w is the scalar component.
///
/// Key operations include:
/// - Euler angle conversion
/// - Spherical interpolation (Slerp)
/// - Look rotation construction
/// - Normalization
///
/// ## Example Usage
///
/// ```swift
/// // Create from Euler angles
/// let rotation = Quaternion.euler(45, 90, 0)
///
/// // Interpolate between rotations
/// let interpolated = Quaternion.Slerp(rotA, rotB, 0.5)
///
/// // Create look-at rotation
/// let lookRotation = Quaternion.LookRotation(targetDirection)
/// ```
public typealias Quaternion = SCNQuaternion

public extension Vector4 {
    /// A vector with all components set to zero (0, 0, 0, 0).
    ///
    /// ```swift
    /// let zero = Vector4.zero
    /// // zero = Vector4(0, 0, 0, 0)
    /// ```
    static var zero: Vector4 {
        SCNVector4Zero
    }
}

public extension Quaternion {
    /// Creates a quaternion from Euler angles in degrees.
    ///
    /// - Parameters:
    ///   - x: The rotation around the X-axis in degrees (pitch).
    ///   - y: The rotation around the Y-axis in degrees (yaw).
    ///   - z: The rotation around the Z-axis in degrees (roll).
    /// - Returns: A quaternion representing the combined rotation.
    ///
    /// ```swift
    /// let rotation = Quaternion.euler(45, 90, 0)
    /// // Creates a rotation of 45° pitch and 90° yaw
    /// ```
    static func euler(_ x: Degree, _ y: Degree, _ z: Degree) -> Quaternion {
        Vector3(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians).toQuaternion()
    }

    /// Returns a normalized copy of this quaternion with magnitude 1.
    ///
    /// Normalized quaternions are required for proper rotation representation.
    /// If the quaternion is already normalized, returns it unchanged.
    ///
    /// - Returns: A unit quaternion representing the same rotation.
    ///
    /// ```swift
    /// let quaternion = Quaternion(x, y, z, w)
    /// let normalized = quaternion.normalized()
    /// // normalized.magnitude = 1.0
    /// ```
    func normalized() -> Quaternion {
        let n = x * x + y * y + z * z + w * w

        if n == 1 {
            return self
        }

        return self * (1.0 / sqrt(n))
    }

    /// Converts this quaternion to Euler angles in radians.
    ///
    /// Returns a Vector3 containing the rotation around each axis:
    /// - x: pitch (rotation around X-axis)
    /// - y: yaw (rotation around Y-axis)
    /// - z: roll (rotation around Z-axis)
    ///
    /// - Returns: A Vector3 with Euler angles in radians.
    ///
    /// ```swift
    /// let rotation = Quaternion.euler(45, 90, 0)
    /// let eulerAngles = rotation.toEuler()
    /// let degrees = eulerAngles.radiansToDegrees()
    /// ```
    func toEuler() -> Vector3 {
        let d = 2.0 * (y * w - x * z)

        switch d {
        case 1.0:
            return Vector3(0, .pi / 2.0, -2.0 * atan2(x, w))

        case -1.0:
            return Vector3(0, .pi / -2.0, 2.0 * atan2(x, w))

        default:
            let sqw = w * w
            let sqx = x * x
            let sqy = y * y
            let sqz = z * z
            let result = Vector3(
                atan2(2.0 * (y * z + x * w), -sqx - sqy + sqz + sqw),
                asin(min(max(-1, d), 1)),
                atan2(2.0 * (x * y + z * w), sqx - sqy - sqz + sqw)
            )
            return result
        }
    }

    /// Calculates the rotation needed to rotate from one direction to another.
    ///
    /// Computes the quaternion that rotates the `from` vector to align with the `to` vector.
    /// Handles special cases including parallel and antiparallel vectors.
    ///
    /// - Parameters:
    ///   - from: The starting direction vector.
    ///   - to: The target direction vector.
    /// - Returns: A quaternion representing the rotation from `from` to `to`.
    ///
    /// ```swift
    /// let currentDir = Vector3.forward
    /// let targetDir = Vector3.right
    /// let rotation = Quaternion.difference(from: currentDir, to: targetDir)
    /// ```
    static func difference(from: Vector3, to: Vector3) -> Quaternion {
        let v0 = from.normalized()
        let v1 = to.normalized()

        let d = v0.dot(v1)

        switch d {
        case let d where d >= 1.0:
            return Quaternion(0, 0, 0, 1)

        case let d where d <= -1.0:
            var axis = Vector3(1, 0, 0).cross(v0)
            if axis.length() == 0 {
                axis = Vector3(0, 1, 0).cross(v0)
            }
            return Quaternion(axis.x, axis.y, axis.z, 0).normalized()

        default:
            let s = sqrtf((1 + d) * 2)
            let invs = 1 / s
            let c = v0.cross(v1) * invs
            return Quaternion(c.x, c.y, c.z, s * 0.5).normalized()
        }
    }

    /// Spherically interpolates between two quaternions for smooth rotation.
    ///
    /// Slerp (Spherical Linear Interpolation) provides smooth interpolation between
    /// two rotations, maintaining constant angular velocity. This is the preferred
    /// method for interpolating rotations as it avoids the artifacts of linear interpolation.
    ///
    /// - Parameters:
    ///   - a: The starting quaternion rotation.
    ///   - b: The ending quaternion rotation.
    ///   - t: The interpolation parameter (clamped to 0-1).
    /// - Returns: The interpolated quaternion.
    ///
    /// ```swift
    /// let startRot = Quaternion.euler(0, 0, 0)
    /// let endRot = Quaternion.euler(90, 0, 0)
    /// let halfwayRot = Quaternion.Slerp(startRot, endRot, 0.5)
    /// // Smoothly rotates halfway between the two orientations
    /// ```
    static func Slerp(_ a: Quaternion, _ b: Quaternion, _ t: Float) -> Quaternion {
        let clampedT = max(0, min(1, t))

        var cosHalfTheta = a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w

        // If dot product is negative, slerp won't take the shorter path
        var b2 = b
        if cosHalfTheta < 0 {
            b2 = Quaternion(-b.x, -b.y, -b.z, -b.w)
            cosHalfTheta = -cosHalfTheta
        }

        // If quaternions are very close, use linear interpolation
        if cosHalfTheta >= 1.0 {
            return a
        }

        let halfTheta = acos(cosHalfTheta)
        let sinHalfTheta = sqrt(1.0 - cosHalfTheta * cosHalfTheta)

        // If theta is 180 degrees, result is not fully defined
        if abs(sinHalfTheta) < 0.001 {
            return Quaternion(
                a.x * 0.5 + b2.x * 0.5,
                a.y * 0.5 + b2.y * 0.5,
                a.z * 0.5 + b2.z * 0.5,
                a.w * 0.5 + b2.w * 0.5
            )
        }

        let ratioA = sin((1 - clampedT) * halfTheta) / sinHalfTheta
        let ratioB = sin(clampedT * halfTheta) / sinHalfTheta

        return Quaternion(
            a.x * ratioA + b2.x * ratioB,
            a.y * ratioA + b2.y * ratioB,
            a.z * ratioA + b2.z * ratioB,
            a.w * ratioA + b2.w * ratioB
        )
    }

    /// Creates a rotation that looks in the specified direction.
    ///
    /// Constructs a quaternion that rotates the forward vector to point in the
    /// specified direction while keeping the up vector aligned as closely as possible
    /// with the provided up direction.
    ///
    /// - Parameters:
    ///   - forward: The direction to look at. Will be normalized internally.
    ///   - up: The upward direction (default: Vector3.up). Used to determine roll.
    /// - Returns: A quaternion representing the look rotation.
    ///
    /// ```swift
    /// let targetDir = (target.position - camera.position).normalized()
    /// let lookRotation = Quaternion.LookRotation(targetDir)
    /// // Creates a rotation that faces the target
    /// ```
    ///
    /// - Note: If forward and up are parallel, an alternate up vector is automatically chosen.
    static func LookRotation(_ forward: Vector3, _ up: Vector3 = Vector3.up) -> Quaternion {
        let forwardNorm = forward.normalized()

        // Handle case where forward and up are parallel
        if abs(forwardNorm.dot(up)) > 0.999 {
            // Use a different up vector
            let alternateUp = abs(up.y) > 0.999 ? Vector3.forward : Vector3.up
            return self.LookRotation(forward, alternateUp)
        }

        let right = up.cross(forwardNorm).normalized()
        let upNorm = forwardNorm.cross(right)

        // Build rotation matrix
        let m00 = right.x
        let m01 = right.y
        let m02 = right.z
        let m10 = upNorm.x
        let m11 = upNorm.y
        let m12 = upNorm.z
        let m20 = forwardNorm.x
        let m21 = forwardNorm.y
        let m22 = forwardNorm.z

        // Convert rotation matrix to quaternion
        let trace = m00 + m11 + m22

        if trace > 0 {
            let s = sqrt(trace + 1.0) * 2
            return Quaternion(
                (m21 - m12) / s,
                (m02 - m20) / s,
                (m10 - m01) / s,
                0.25 * s
            ).normalized()
        } else if m00 > m11, m00 > m22 {
            let s = sqrt(1.0 + m00 - m11 - m22) * 2
            return Quaternion(
                0.25 * s,
                (m01 + m10) / s,
                (m02 + m20) / s,
                (m21 - m12) / s
            ).normalized()
        } else if m11 > m22 {
            let s = sqrt(1.0 + m11 - m00 - m22) * 2
            return Quaternion(
                (m01 + m10) / s,
                0.25 * s,
                (m12 + m21) / s,
                (m02 - m20) / s
            ).normalized()
        } else {
            let s = sqrt(1.0 + m22 - m00 - m11) * 2
            return Quaternion(
                (m02 + m20) / s,
                (m12 + m21) / s,
                0.25 * s,
                (m10 - m01) / s
            ).normalized()
        }
    }

    /// The identity quaternion representing no rotation.
    ///
    /// This quaternion (0, 0, 0, 1) represents zero rotation, equivalent to
    /// Euler angles of (0, 0, 0).
    ///
    /// ```swift
    /// let noRotation = Quaternion.identity
    /// // Equivalent to no rotation applied
    /// ```
    static var identity: Quaternion {
        return Quaternion(0, 0, 0, 1)
    }
}

// MARK: - Quaternion Operators

/// Multiplies all components of a quaternion by a scalar value.
///
/// This operation is typically used internally for normalization but can
/// be useful for scaling quaternion components.
///
/// - Parameters:
///   - quaternion: The quaternion.
///   - scalar: The scalar multiplier.
/// - Returns: A new quaternion with all components scaled.
///
/// ```swift
/// let quat = Quaternion(0.5, 0.5, 0.5, 0.5)
/// let scaled = quat * 2.0
/// // scaled = Quaternion(1.0, 1.0, 1.0, 1.0)
/// ```
public func * (quaternion: Quaternion, scalar: Float) -> Quaternion {
    Quaternion(quaternion.x * scalar, quaternion.y * scalar, quaternion.z * scalar, quaternion.w * scalar)
}
