import UIKit

open class Behaviour: Component {

    public var enabled: Bool = true {
        didSet {
            if enabled {
                onEnable()
            } else {
                onDisable()
            }
            enableChanged()
        }
    }

    internal func enableChanged() {

    }
    
    open func onEnable() {

    }

    open func onDisable() {

    }
}
