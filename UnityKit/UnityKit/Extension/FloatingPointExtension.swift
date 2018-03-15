
import CoreGraphics
import Foundation

extension CGPoint {

    func toVector2() -> Vector2 {
        return Vector2(Float(x), Float(y))
    }
}

extension CGFloat {

    public func toFloat() -> Float {
        return Float(self)
    }

    public func toDouble() -> Double {
        return Double(self)
    }
}

extension Float {

    public func toDouble() -> Double {
        return Double(self)
    }

    public func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

extension Double {

    public func toFloat() -> Float {
        return Float(self)
    }
}
