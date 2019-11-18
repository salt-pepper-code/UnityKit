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
}
