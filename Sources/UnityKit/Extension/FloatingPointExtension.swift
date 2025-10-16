import CoreGraphics
import Foundation

public extension CGFloat {
    func toFloat() -> Float {
        return Float(self)
    }

    func toDouble() -> Double {
        return Double(self)
    }
}

public extension Float {
    func toDouble() -> Double {
        return Double(self)
    }

    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

public extension Double {
    func toFloat() -> Float {
        return Float(self)
    }
}
