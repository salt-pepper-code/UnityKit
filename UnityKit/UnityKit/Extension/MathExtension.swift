import Foundation

extension FloatingPoint {
    
    public static func degToRad() -> Self { return .pi / 180 }
    public static func radToDeg() -> Self { return 180 / .pi }
    
    public var degreesToRadians: Self { return self * Self.degToRad() }
    public var radiansToDegrees: Self { return self * Self.radToDeg() }
}

extension Double {
    
    public static func lerp(from v0: Double, to v1: Double, time t: TimeInterval) -> Double {
        return (1 - t) * v0 + t * v1
    }
}

extension Float {

    public static func lerp(from v0: Float, to v1: Float, time t: TimeInterval) -> Float {
        return Float(1 - t) * v0 + Float(t) * v1
    }
    
    public func toDouble() -> Double {
        return Double(self)
    }
}

extension CGFloat {

    public static func lerp(from v0: CGFloat, to v1: CGFloat, time t: TimeInterval) -> CGFloat {
        return CGFloat(1 - t) * v0 + CGFloat(t) * v1
    }

    public func toDouble() -> Double {
        return Double(self)
    }
}

public func normalize(_ value: Float, in range: ClosedRange<Float>) -> Float {
    return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
}

public func interpolate(from start: Float, to end: Float, alpha: Float) -> Float {
    return (1 - alpha) * start + alpha * end
}
