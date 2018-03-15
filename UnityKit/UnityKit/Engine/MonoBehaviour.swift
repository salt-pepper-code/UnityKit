import Foundation

open class MonoBehaviour: Behaviour, Instantiable {

    open func instantiate(gameObject: GameObject) -> Self {
        return type(of: self).init()
    }

    open override func onEnable() {

    }

    open override func onDisable() {

    }
}
