import SpriteKit

public extension UI {
    class Canvas: UIBehaviour {
        public internal(set) var worldSize: Size = .zero
        public internal(set) var pixelPerUnit: Float = 10

        /**
         Configurable block that passes and returns itself.

         - parameters:
            - configurationBlock: block that passes itself.

         - returns: itself
         */
        @discardableResult public func configure(_ configurationBlock: (Canvas) -> Void) -> Canvas {
            configurationBlock(self)
            return self
        }
    }
}
