import UIKit

open class Behaviour: Component {

    public var enabled: Bool = false {
        didSet {
            guard enabled != oldValue
                else { return }

            if enabled {
                onEnable()
            } else {
                onDisable()
            }
        }
    }

    internal func enableChanged() {

    }
    
    open func onEnable() {

    }

    open func onDisable() {

    }
}
