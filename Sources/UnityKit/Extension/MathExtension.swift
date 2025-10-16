import CoreGraphics
import Foundation

public typealias Degree = Float

public extension Degree {
    static func clamp(_ angle: Degree) -> Degree {
        var angle = angle
        while angle >= 360 {
            angle -= 360
        }
        while angle < 0 {
            angle += 360
        }
        return angle
    }

    func clampDegree() -> Degree {
        return .clamp(self)
    }

    static func differenceAngle(x: Degree, y: Degree) -> Degree {
        var arg = fmod(y - x, 360)
        if arg < 0 {
            arg = arg + 360
        }
        if arg > 180 {
            arg = arg - 360
        }
        return -arg
    }

    func differenceAngle(_ other: Degree) -> Degree {
        return Degree.differenceAngle(x: self, y: other)
    }
}

public extension FloatingPoint {
    static func degToRad() -> Self { return .pi / 180 }
    static func radToDeg() -> Self { return 180 / .pi }

    var degreesToRadians: Self { return self * Self.degToRad() }
    var radiansToDegrees: Self { return self * Self.radToDeg() }

    mutating func clamp(_ range: ClosedRange<Self>) {
        self = Self.clamp(self, range: range)
    }

    static func clamp(_ value: Self, range: ClosedRange<Self>) -> Self {
        return max(min(value, range.upperBound), range.lowerBound)
    }

    func clamp01() -> Self {
        return Self.clamp(self, range: 0...1)
    }
}

public extension Double {
    static func lerp(from v0: Double, to v1: Double, time t: TimeInterval) -> Double {
        return (1 - t) * v0 + t * v1
    }
}

public extension Float {
    static func lerp(from v0: Float, to v1: Float, time t: TimeInterval) -> Float {
        return Float(1 - t) * v0 + Float(t) * v1
    }
}

public extension CGFloat {
    static func lerp(from v0: CGFloat, to v1: CGFloat, time t: TimeInterval) -> CGFloat {
        return CGFloat(1 - t) * v0 + CGFloat(t) * v1
    }
}

public extension Color {
    static func lerp(from v0: Color, to v1: Color, time t: TimeInterval) -> Color {
        let comp0 = v0.components
        let comp1 = v1.components
        return Color(
            red: .lerp(from: comp0.red, to: comp1.red, time: t),
            green: .lerp(from: comp0.green, to: comp1.green, time: t),
            blue: .lerp(from: comp0.blue, to: comp1.blue, time: t),
            alpha: .lerp(from: comp0.alpha, to: comp1.alpha, time: t)
        )
    }
}

public func normalize(_ value: Float, in range: ClosedRange<Float>) -> Float {
    return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
}

public func interpolate(from start: Float, to end: Float, alpha: Float) -> Float {
    return (1 - alpha) * start + alpha * end
}
