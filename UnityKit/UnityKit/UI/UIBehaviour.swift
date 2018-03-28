
import SpriteKit

extension UI {

    public class UIBehaviour: Behaviour {

        public var canvasObject: CanvasObject!

        public var skScene: SKScene {
            return canvasObject.skScene
        }

        public override func awake() {

            var canvasFound = false
            var parent = gameObject
            while parent != nil {
                if parent is CanvasObject {
                    canvasObject = parent as! CanvasObject
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
