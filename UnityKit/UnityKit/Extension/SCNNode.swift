import SceneKit

extension SCNNode {
    
    func deepClone(_ node: SCNNode? = nil) -> SCNNode {
        let refNode = (node ?? self)
        let clone = refNode.clone()
        if let geometry = clone.geometry?.copy() as? SCNGeometry {
            clone.geometry = geometry
        }
        let copy = clone.childNodes
        copy.forEach {
            $0.name = clone.name
            clone.addChildNode(deepClone($0))
            $0.removeFromParentNode()
        }
        return clone
    }

    func boundingBoxFromBoundingSphere(relativeTo node: SCNNode) -> BoundingBox? {
        guard let _ = geometry else {
            return nil
        }
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

