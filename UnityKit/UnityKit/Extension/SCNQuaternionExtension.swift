import Foundation
import SceneKit

public typealias Quaternion = SCNQuaternion

extension Quaternion {
    
    public static var zero: Quaternion {
        return SCNQuaternion.zero
    }
}
