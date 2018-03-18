
import SceneKit
import Foundation

public typealias Vector4 = SCNVector4
public typealias Quaternion = SCNQuaternion

extension Vector4 {
    
    public static var zero: Vector4 {
        return SCNVector4Zero
    }
}

extension Quaternion {

    public static func euler(_ x: Degree, _ y: Degree, _ z: Degree) -> Quaternion {
        return Vector3(x.degreesToRadians, y.degreesToRadians, z.degreesToRadians).toQuaternion()
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
            return Vector3(atan2(2.0 * (y * z + x * w), (-sqx - sqy + sqz + sqw)),
                           asin(min(max(-1, d), 1)),
                           atan2(2.0 * (x * y + z * w), (sqx - sqy - sqz + sqw)))
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
}

public func * (quaternion: Quaternion, scalar: Float) -> Quaternion {
    return Quaternion(quaternion.x * scalar, quaternion.y * scalar, quaternion.z * scalar, quaternion.w * scalar)
}
