import UIKit

open class Behaviour: Component {

    public var enabled: Bool = true
    
    public var isActiveAndEnabled: Bool {
        get {
            return self.enabled
        }
    }
}
