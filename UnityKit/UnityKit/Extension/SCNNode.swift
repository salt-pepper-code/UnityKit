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
            if vertex.x < boundingBox.min.x { boundingBox.min.x = vertex.x }
            if vertex.y < boundingBox.min.y { boundingBox.min.y = vertex.y }
            if vertex.z < boundingBox.min.z { boundingBox.min.z = vertex.z }
            if vertex.x > boundingBox.max.x { boundingBox.max.x = vertex.x }
            if vertex.y > boundingBox.max.y { boundingBox.max.y = vertex.y }
            if vertex.z > boundingBox.max.z { boundingBox.max.z = vertex.z }
        })
        return boundingBox
    }
}

