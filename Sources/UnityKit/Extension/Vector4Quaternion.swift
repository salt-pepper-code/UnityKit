import SceneKit
import Foundation

public typealias Vector4 = SCNVector4
public typealias Quaternion = SCNQuaternion

extension Vector4 {
    public static var zero: Vector4 {
        SCNVector4Zero
    }
}

extension Quaternion {
    public static func euler(_ x: Degree, _ y: Degree, _ z: Degree) -> Quaternion {
        Vector3(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians).toQuaternion()
    }

    public func normalized() -> Quaternion {
        let n = x * x + y * y + z * z + w * w

        if n == 1 {
            return self
        }

        return self * (1.0 / sqrt(n))
    }

    public func toEuler() -> Vector3 {
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
            let result = Vector3(atan2(2.0 * (y * z + x * w), (-sqx - sqy + sqz + sqw)),
                           asin(min(max(-1, d), 1)),
                           atan2(2.0 * (x * y + z * w), (sqx - sqy - sqz + sqw)))
            return result
        }
     }

    public static func difference(from: Vector3, to: Vector3) -> Quaternion {
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

    /**
     * Spherically interpolates between two quaternions for smooth rotation
     */
    public static func Slerp(_ a: Quaternion, _ b: Quaternion, _ t: Float) -> Quaternion {
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

    /**
     * Creates a rotation that looks along forward with the head upwards along upwards
     */
    public static func LookRotation(_ forward: Vector3, _ up: Vector3 = Vector3.up) -> Quaternion {
        let forwardNorm = forward.normalized()

        // Handle case where forward and up are parallel
        if abs(forwardNorm.dot(up)) > 0.999 {
            // Use a different up vector
            let alternateUp = abs(up.y) > 0.999 ? Vector3.forward : Vector3.up
            return LookRotation(forward, alternateUp)
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
        } else if m00 > m11 && m00 > m22 {
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

    /**
     * Returns the identity quaternion (no rotation)
     */
    public static var identity: Quaternion {
        return Quaternion(0, 0, 0, 1)
    }
}

public func * (quaternion: Quaternion, scalar: Float) -> Quaternion {
    Quaternion(quaternion.x * scalar, quaternion.y * scalar, quaternion.z * scalar, quaternion.w * scalar)
}
