
import SceneKit
import Foundation

public typealias Vector4 = SCNVector4
public typealias Quaternion = SCNQuaternion

extension Vector4 {
    
    public static var zero: Vector4 {
        return SCNQuaternion.zero
    }
}

extension Quaternion {

    public static func euler(_ x: Degree, _ y: Degree, _ z: Degree) -> Quaternion {

        let sx = sin(x.degreesToRadians / 2)
        let sy = sin(y.degreesToRadians / 2)
        let sz = sin(z.degreesToRadians / 2)
        let cx = cos(x.degreesToRadians / 2)
        let cy = cos(y.degreesToRadians / 2)
        let cz = cos(z.degreesToRadians / 2)

        return Quaternion((cx*cy*cz) - (sx*sy*sz),
                          (sx*cy*cz) + (cx*sy*sz),
                          (cx*sy*cz) - (sx*cy*sz),
                          (cx*cy*sz) + (sx*sy*cz))
    }
}
