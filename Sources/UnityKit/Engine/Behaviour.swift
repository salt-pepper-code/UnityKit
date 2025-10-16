import Foundation

open class Behaviour: Component {
    public var enabled: Bool = false {
        didSet {
            guard self.enabled != oldValue else { return }

            if self.enabled {
                self.onEnable()
            } else {
                self.onDisable()
            }
        }
    }

    func enableChanged() {}

    open func onEnable() {}

    open func onDisable() {}
}
