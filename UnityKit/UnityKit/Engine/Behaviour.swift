import UIKit

open class Behaviour: Component {

    public var enabled: Bool = true {
        didSet {
            if enabled {
                onEnable()
            } else {
                onDisable()
            }
        }
    }
    
    open func onEnable() {

    }

    open func onDisable() {

    }
}
