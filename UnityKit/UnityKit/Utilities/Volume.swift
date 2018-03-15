
import SceneKit

typealias BoundingBox = (min: SCNVector3, max: SCNVector3)

internal class Volume {
    
    internal static func boundingSize(_ boundingBox: BoundingBox) -> SCNVector3 {
        return SCNVector3(abs(boundingBox.max.x - boundingBox.min.x), abs(boundingBox.max.y - boundingBox.min.y), abs(boundingBox.max.z - boundingBox.min.z))
    }
    
    internal static func boundingCenter(_ boundingBox: BoundingBox) -> SCNVector3 {
        let volumeSize = Volume.boundingSize(boundingBox)
        return SCNVector3(boundingBox.min.x + volumeSize.x / 2,
                          boundingBox.min.y + volumeSize.y / 2,
                          boundingBox.min.z + volumeSize.z / 2)
    }
}

internal func + (left: BoundingBox?, right: BoundingBox?) -> BoundingBox? {
    guard let left = left else {
        return right
    }
    guard let right = right else {
        return left
    }
    var add = left
    add.min.x = min(left.min.x, right.min.x)
    add.min.y = min(left.min.y, right.min.y)
    add.min.z = min(left.min.z, right.min.z)
    add.max.x = max(left.max.x, right.max.x)
    add.max.y = max(left.max.y, right.max.y)
    add.max.z = max(left.max.z, right.max.z)
    return add
}

internal func += (left: inout BoundingBox?, right: BoundingBox?) {
    left = left + right
}

internal func * (left: BoundingBox, right: SCNVector3) -> BoundingBox {
    return (min: left.min * right, max: left.max * right)
}
