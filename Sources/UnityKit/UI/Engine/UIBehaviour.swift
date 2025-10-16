import SpriteKit

public extension UI {
    class UIBehaviour: Behaviour {
        public var canvasObject: CanvasObject!

        public var skScene: SKScene {
            self.canvasObject.skScene
        }

        override public func awake() {
            var canvasFound = false
            var parent = gameObject
            while parent != nil {
                if let object = parent as? CanvasObject {
                    self.canvasObject = object
                    canvasFound = true
                    break
                }
                parent = parent?.parent
            }
            guard canvasFound
            else { fatalError("any subclass of UIBehaviour must be inside a Canvas") }
        }
    }
}
