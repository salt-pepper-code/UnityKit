
import Foundation

open class MonoBehaviour: Behaviour, Instantiable {

    open func instantiate(gameObject: GameObject) -> Self {
        return type(of: self).init()
    }

    open override func onEnable() {

    }

    open override func onDisable() {

    }

    open func onCollisionEnter(_ collision: Collision) {

    }

    open func onCollisionExit(_ collision: Collision) {

    }

    open func onTriggerEnter(_ collider: Collider) {

    }

    open func onTriggerExit(_ collider: Collider) {

    }
}
