import SceneKit

extension SCNNode {
    func deepClone(_ node: SCNNode? = nil) -> SCNNode {
        let refNode = (node ?? self)
        let clone = refNode.clone()
        if let geometry = clone.geometry?.copy() as? SCNGeometry {
            clone.geometry = geometry
        }
        let copy = clone.childNodes
        for item in copy {
            item.name = clone.name
            clone.addChildNode(self.deepClone(item))
            item.removeFromParentNode()
        }
        return clone
    }
}
