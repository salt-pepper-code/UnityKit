import SceneKit

public extension GameObject {
    func runAction(_ action: SCNAction) {
        node.runAction(action)
    }

    func runAction(_ action: SCNAction, completionHandler block: (() -> Void)? = nil) {
        node.runAction(action, completionHandler: block)
    }

    func runAction(_ action: SCNAction, forKey key: String?) {
        node.runAction(action, forKey: key)
    }

    func runAction(_ action: SCNAction, forKey key: String?, completionHandler block: (() -> Void)? = nil) {
        node.runAction(action, forKey: key, completionHandler: block)
    }

    var hasActions: Bool {
        return node.hasActions
    }

    func action(forKey key: String) -> SCNAction? {
        return node.action(forKey: key)
    }

    func removeAction(forKey key: String) {
        node.removeAction(forKey: key)
    }

    func removeAllActions() {
        node.removeAllActions()
    }

    var actionKeys: [String] {
        return node.actionKeys
    }
}
