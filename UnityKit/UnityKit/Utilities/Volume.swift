
import SceneKit

public typealias BoundingBox = (min: Vector3, max: Vector3)
public typealias BoundingSphere = (center: Vector3, radius: Float)

public class Volume {
    
    public static func boundingSize(_ boundingBox: BoundingBox) -> Vector3 {
        return Vector3(abs(boundingBox.max.x - boundingBox.min.x), abs(boundingBox.max.y - boundingBox.min.y), abs(boundingBox.max.z - boundingBox.min.z))
    }
    
    public static func boundingCenter(_ boundingBox: BoundingBox) -> Vector3 {
        let volumeSize = Volume.boundingSize(boundingBox)
        return Vector3(boundingBox.min.x + volumeSize.x / 2,
                          boundingBox.min.y + volumeSize.y / 2,
                          boundingBox.min.z + volumeSize.z / 2)
    }

    public static func moveCenter(_ boundingBox: BoundingBox, center: Vector3Nullable) -> BoundingBox {
        let volumeSize = Volume.boundingSize(boundingBox)
        var volumeCenter = Volume.boundingCenter(boundingBox)
        if let x = center.x { volumeCenter.x = x }
        if let y = center.y { volumeCenter.y = y }
        if let z = center.z { volumeCenter.z = z }
        return (min: Vector3(volumeCenter.x - (volumeSize.x / 2), volumeCenter.y - (volumeSize.y / 2), volumeCenter.z - (volumeSize.z / 2)),
                max: Vector3(volumeCenter.x + (volumeSize.x / 2), volumeCenter.y + (volumeSize.y / 2), volumeCenter.z + (volumeSize.z / 2)))
    }
}

public func + (left: BoundingBox?, right: BoundingBox?) -> BoundingBox? {
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

public func += (left: inout BoundingBox?, right: BoundingBox?) {
    left = left + right
}

public func * (left: BoundingBox, right: Vector3) -> BoundingBox {
    return (min: left.min * right, max: left.max * right)
}

public func * (left: BoundingBox, right: Float) -> BoundingBox {
    return (min: left.min * right, max: left.max * right)
}

extension GameObject {

    public func boundingBoxFromBoundingSphere(relativeTo gameObject: GameObject? = nil) -> BoundingBox? {
        return node.boundingBoxFromBoundingSphere(relativeTo: gameObject?.node)
    }

    public func boundingBox(relativeTo gameObject: GameObject) -> BoundingBox? {
        return node.boundingBox(relativeTo: gameObject.node)
    }
}

extension SCNNode {

    func boundingBoxFromBoundingSphere(relativeTo node: SCNNode? = nil) -> BoundingBox? {

        guard let _ = geometry
            else { return nil }

        let node = node ?? self

        let boundingSphere = self.boundingSphere
        let relativeCenter = convertPosition(boundingSphere.center, to: node)
        
        return (min: relativeCenter - boundingSphere.radius, max: relativeCenter + boundingSphere.radius)
    }

    func boundingBox(relativeTo node: SCNNode) -> BoundingBox? {

        var boundingBox = childNodes
            .reduce(nil) { $0 + $1.boundingBox(relativeTo: node) }

        guard let geometry = geometry,
            let source = geometry.sources(for: SCNGeometrySource.Semantic.vertex).first
            else { return boundingBox }

        let vertices = SCNGeometry.vertices(source: source).map { convertPosition($0, to: node) }
        guard let first = vertices.first
            else { return boundingBox }

        boundingBox += vertices.reduce(into: (min: first, max: first), { boundingBox, vertex in
            boundingBox.min.x = min(boundingBox.min.x, vertex.x)
            boundingBox.min.y = min(boundingBox.min.y, vertex.y)
            boundingBox.min.z = min(boundingBox.min.z, vertex.z)
            boundingBox.max.x = max(boundingBox.max.x, vertex.x)
            boundingBox.max.y = max(boundingBox.max.y, vertex.y)
            boundingBox.max.z = max(boundingBox.max.z, vertex.z)
        })

        return boundingBox
    }
}
