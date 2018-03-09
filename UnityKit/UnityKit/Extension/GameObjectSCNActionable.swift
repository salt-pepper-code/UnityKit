import SceneKit

extension GameObject {

    public func runAction(_ action: SCNAction) {
        node.runAction(action)
    }

    public func runAction(_ action: SCNAction, completionHandler block: (() -> Void)? = nil) {
        node.runAction(action, completionHandler: block)
    }

    public func runAction(_ action: SCNAction, forKey key: String?) {
        node.runAction(action, forKey: key)
    }

    public func runAction(_ action: SCNAction, forKey key: String?, completionHandler block: (() -> Void)? = nil) {
        node.runAction(action, forKey: key, completionHandler: block)
    }

    public var hasActions: Bool {
        return node.hasActions
    }

    public func action(forKey key: String) -> SCNAction? {
        return node.action(forKey: key)
    }

    public func removeAction(forKey key: String) {
        node.removeAction(forKey: key)
    }

    public func removeAllActions() {
        node.removeAllActions()
    }

    public var actionKeys: [String] {
        return node.actionKeys
    }
}
