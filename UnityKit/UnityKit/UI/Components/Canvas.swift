import SpriteKit

extension UI {
    public class Canvas: UIBehaviour {
        internal(set) public var worldSize: Size = .zero
        internal(set) public var pixelPerUnit: Float = 10

        @discardableResult public func configure(_ completionBlock: (Canvas) -> Void) -> Canvas {
            completionBlock(self)
            return self
        }
    }
}
