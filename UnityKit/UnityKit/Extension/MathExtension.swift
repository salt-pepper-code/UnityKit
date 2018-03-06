import Foundation

extension FloatingPoint {
    
    public static func deg2Rad() -> Self { return .pi / 180 }
    public static func rad2Deg() -> Self { return 180 / .pi }
    
    public var degreesToRadians: Self { return self * Self.deg2Rad() }
    public var radiansToDegrees: Self { return self * Self.rad2Deg() }
}

extension Double {
    
    public func lerp(_ v0: Double, _ v1: Double, _ t: TimeInterval) -> Double {
        return (1 - t) * v0 + t * v1
    }
}

extension Float {
    
    public func lerp(_ v0: Float, _ v1: Float, _ t: TimeInterval) -> Float {
        return Float(1 - t) * v0 + Float(t) * v1
    }
    
    public func toDouble() -> Double {
        return Double(self)
    }
}

extension CGFloat {

    public func lerp(_ v0: CGFloat, _ v1: CGFloat, _ t: TimeInterval) -> CGFloat {
        return CGFloat(1 - t) * v0 + CGFloat(t) * v1
    }

    public func toDouble() -> Double {
        return Double(self)
    }
}

internal func normalize(_ value: Float, in range: ClosedRange<Float>) -> Float {
    return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
}

internal func interpolate(from start: Float, to end: Float, alpha: Float) -> Float {
    return (1 - alpha) * start + alpha * end
}
