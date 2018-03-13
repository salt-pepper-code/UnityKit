
import CoreGraphics

extension CGPoint {

    func toVector2() -> Vector2 {
        return Vector2(Float(x), Float(y))
    }
}

extension CGFloat {

    public func toFloat() -> Float {
        return Float(self)
    }
}
