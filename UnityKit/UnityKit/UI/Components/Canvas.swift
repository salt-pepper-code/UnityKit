import SpriteKit

extension UI {
    public class Canvas: UIBehaviour {
        internal(set) public var worldSize: Size = .zero
        internal(set) public var pixelPerUnit: Float = 10

        /**
         Configurable block that passes and returns itself.

         - parameters:
            - configurationBlock: block that passes itself.

         - returns: itself
         */
        @discardableResult public func configure(_ configurationBlock: (Canvas) -> ()) -> Canvas {

            configurationBlock(self)
            return self
        }
    }
}
