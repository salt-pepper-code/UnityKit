import CoreGraphics
import Foundation

/// A typealias for Float representing angular measurements in degrees.
///
/// Use `Degree` to clearly indicate that a floating-point value represents an angle in degrees
/// rather than radians or other units.
///
/// ## Example
/// ```swift
/// let rotation: Degree = 45.0
/// let fullCircle: Degree = 360.0
/// ```
public typealias Degree = Float

public extension Degree {
    /// Normalizes an angle to the range [0, 360) degrees.
    ///
    /// This method wraps angles that fall outside the standard 0-360 degree range
    /// back into the valid range by repeatedly adding or subtracting 360 degrees.
    ///
    /// - Parameter angle: The angle to clamp.
    /// - Returns: The normalized angle in the range [0, 360).
    ///
    /// ## Example
    /// ```swift
    /// let normalized1 = Degree.clamp(450.0)  // Returns 90.0
    /// let normalized2 = Degree.clamp(-90.0)  // Returns 270.0
    /// let normalized3 = Degree.clamp(720.0)  // Returns 0.0
    /// ```
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

    /// Normalizes this angle to the range [0, 360) degrees.
    ///
    /// This is a convenience method that calls ``Degree/clamp(_:)`` on the current value.
    ///
    /// - Returns: The normalized angle in the range [0, 360).
    ///
    /// ## Example
    /// ```swift
    /// let angle: Degree = 450.0
    /// let normalized = angle.clampDegree()  // Returns 90.0
    /// ```
    func clampDegree() -> Degree {
        return .clamp(self)
    }

    /// Calculates the shortest angular difference between two angles.
    ///
    /// This method computes the signed difference between two angles, always returning
    /// the shortest path between them (in the range [-180, 180]).
    ///
    /// - Parameters:
    ///   - x: The starting angle in degrees.
    ///   - y: The target angle in degrees.
    /// - Returns: The shortest signed difference from `x` to `y`, in the range [-180, 180].
    ///
    /// ## Example
    /// ```swift
    /// let diff1 = Degree.differenceAngle(x: 10, y: 350)   // Returns -20
    /// let diff2 = Degree.differenceAngle(x: 350, y: 10)   // Returns 20
    /// let diff3 = Degree.differenceAngle(x: 0, y: 180)    // Returns 180
    /// let diff4 = Degree.differenceAngle(x: 90, y: 270)   // Returns 180
    /// ```
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

    /// Calculates the shortest angular difference to another angle.
    ///
    /// This is a convenience method that calls ``Degree/differenceAngle(x:y:)``
    /// with the current value as the starting angle.
    ///
    /// - Parameter other: The target angle in degrees.
    /// - Returns: The shortest signed difference to the target angle, in the range [-180, 180].
    ///
    /// ## Example
    /// ```swift
    /// let currentAngle: Degree = 10
    /// let diff = currentAngle.differenceAngle(350)  // Returns -20
    /// ```
    func differenceAngle(_ other: Degree) -> Degree {
        return Degree.differenceAngle(x: self, y: other)
    }
}

public extension FloatingPoint {
    /// Returns the conversion factor from degrees to radians.
    ///
    /// - Returns: π / 180, the multiplier to convert degrees to radians.
    ///
    /// ## Example
    /// ```swift
    /// let factor = Double.degToRad()  // Returns ~0.017453
    /// ```
    static func degToRad() -> Self { return .pi / 180 }

    /// Returns the conversion factor from radians to degrees.
    ///
    /// - Returns: 180 / π, the multiplier to convert radians to degrees.
    ///
    /// ## Example
    /// ```swift
    /// let factor = Double.radToDeg()  // Returns ~57.29578
    /// ```
    static func radToDeg() -> Self { return 180 / .pi }

    /// Converts this value from degrees to radians.
    ///
    /// ## Example
    /// ```swift
    /// let degrees: Double = 180.0
    /// let radians = degrees.degreesToRadians  // Returns π (~3.14159)
    ///
    /// let angle: Float = 90.0
    /// let rad = angle.degreesToRadians  // Returns π/2 (~1.5708)
    /// ```
    var degreesToRadians: Self { return self * Self.degToRad() }

    /// Converts this value from radians to degrees.
    ///
    /// ## Example
    /// ```swift
    /// let radians: Double = .pi
    /// let degrees = radians.radiansToDegrees  // Returns 180.0
    ///
    /// let angle: Float = .pi / 2
    /// let deg = angle.radiansToDegrees  // Returns 90.0
    /// ```
    var radiansToDegrees: Self { return self * Self.radToDeg() }

    /// Clamps this value to the specified range in place.
    ///
    /// This method mutates the current value, constraining it to fall within the given range.
    ///
    /// - Parameter range: The closed range to clamp to.
    ///
    /// ## Example
    /// ```swift
    /// var value: Double = 150.0
    /// value.clamp(0...100)  // value is now 100.0
    ///
    /// var temperature: Float = -10.0
    /// temperature.clamp(0...100)  // temperature is now 0.0
    /// ```
    mutating func clamp(_ range: ClosedRange<Self>) {
        self = Self.clamp(self, range: range)
    }

    /// Returns a value clamped to the specified range.
    ///
    /// This method constrains a value to fall within the given range without mutating it.
    ///
    /// - Parameters:
    ///   - value: The value to clamp.
    ///   - range: The closed range to clamp to.
    /// - Returns: The clamped value.
    ///
    /// ## Example
    /// ```swift
    /// let clamped1 = Double.clamp(150.0, range: 0...100)   // Returns 100.0
    /// let clamped2 = Float.clamp(-10.0, range: 0...100)    // Returns 0.0
    /// let clamped3 = Double.clamp(50.0, range: 0...100)    // Returns 50.0
    /// ```
    static func clamp(_ value: Self, range: ClosedRange<Self>) -> Self {
        return max(min(value, range.upperBound), range.lowerBound)
    }

    /// Returns this value clamped to the range [0, 1].
    ///
    /// This is a convenience method commonly used for normalizing values to a unit range.
    ///
    /// - Returns: The value clamped between 0 and 1.
    ///
    /// ## Example
    /// ```swift
    /// let value1: Double = 1.5
    /// let normalized1 = value1.clamp01()  // Returns 1.0
    ///
    /// let value2: Float = -0.5
    /// let normalized2 = value2.clamp01()  // Returns 0.0
    ///
    /// let value3: Double = 0.75
    /// let normalized3 = value3.clamp01()  // Returns 0.75
    /// ```
    func clamp01() -> Self {
        return Self.clamp(self, range: 0...1)
    }
}

public extension Double {
    /// Linearly interpolates between two Double values.
    ///
    /// Linear interpolation (lerp) calculates a value between two endpoints based on a time parameter.
    /// When `t` is 0, returns `v0`. When `t` is 1, returns `v1`. Values between 0 and 1 return
    /// proportional intermediate values.
    ///
    /// - Parameters:
    ///   - v0: The starting value.
    ///   - v1: The ending value.
    ///   - t: The interpolation parameter, typically in the range [0, 1].
    /// - Returns: The interpolated value.
    ///
    /// ## Example
    /// ```swift
    /// let start: Double = 0.0
    /// let end: Double = 100.0
    ///
    /// let value1 = Double.lerp(from: start, to: end, time: 0.0)   // Returns 0.0
    /// let value2 = Double.lerp(from: start, to: end, time: 0.5)   // Returns 50.0
    /// let value3 = Double.lerp(from: start, to: end, time: 1.0)   // Returns 100.0
    /// let value4 = Double.lerp(from: start, to: end, time: 0.25)  // Returns 25.0
    /// ```
    static func lerp(from v0: Double, to v1: Double, time t: TimeInterval) -> Double {
        return (1 - t) * v0 + t * v1
    }
}

public extension Float {
    /// Linearly interpolates between two Float values.
    ///
    /// Linear interpolation (lerp) calculates a value between two endpoints based on a time parameter.
    /// When `t` is 0, returns `v0`. When `t` is 1, returns `v1`. Values between 0 and 1 return
    /// proportional intermediate values.
    ///
    /// - Parameters:
    ///   - v0: The starting value.
    ///   - v1: The ending value.
    ///   - t: The interpolation parameter, typically in the range [0, 1].
    /// - Returns: The interpolated value.
    ///
    /// ## Example
    /// ```swift
    /// let start: Float = 0.0
    /// let end: Float = 100.0
    ///
    /// let value1 = Float.lerp(from: start, to: end, time: 0.0)   // Returns 0.0
    /// let value2 = Float.lerp(from: start, to: end, time: 0.5)   // Returns 50.0
    /// let value3 = Float.lerp(from: start, to: end, time: 1.0)   // Returns 100.0
    /// ```
    static func lerp(from v0: Float, to v1: Float, time t: TimeInterval) -> Float {
        return Float(1 - t) * v0 + Float(t) * v1
    }
}

public extension CGFloat {
    /// Linearly interpolates between two CGFloat values.
    ///
    /// Linear interpolation (lerp) calculates a value between two endpoints based on a time parameter.
    /// When `t` is 0, returns `v0`. When `t` is 1, returns `v1`. Values between 0 and 1 return
    /// proportional intermediate values.
    ///
    /// - Parameters:
    ///   - v0: The starting value.
    ///   - v1: The ending value.
    ///   - t: The interpolation parameter, typically in the range [0, 1].
    /// - Returns: The interpolated value.
    ///
    /// ## Example
    /// ```swift
    /// let start: CGFloat = 0.0
    /// let end: CGFloat = 200.0
    ///
    /// let value1 = CGFloat.lerp(from: start, to: end, time: 0.0)   // Returns 0.0
    /// let value2 = CGFloat.lerp(from: start, to: end, time: 0.5)   // Returns 100.0
    /// let value3 = CGFloat.lerp(from: start, to: end, time: 1.0)   // Returns 200.0
    /// ```
    static func lerp(from v0: CGFloat, to v1: CGFloat, time t: TimeInterval) -> CGFloat {
        return CGFloat(1 - t) * v0 + CGFloat(t) * v1
    }
}

public extension Color {
    /// Linearly interpolates between two colors.
    ///
    /// This method performs component-wise linear interpolation on the red, green, blue, and alpha
    /// channels of two colors. When `t` is 0, returns `v0`. When `t` is 1, returns `v1`.
    ///
    /// - Parameters:
    ///   - v0: The starting color.
    ///   - v1: The ending color.
    ///   - t: The interpolation parameter, typically in the range [0, 1].
    /// - Returns: The interpolated color.
    ///
    /// ## Example
    /// ```swift
    /// let red = Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    /// let blue = Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
    ///
    /// let purple = Color.lerp(from: red, to: blue, time: 0.5)
    /// // Returns a color halfway between red and blue
    ///
    /// let almostBlue = Color.lerp(from: red, to: blue, time: 0.9)
    /// // Returns a color very close to blue
    /// ```
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

/// Normalizes a value to the range [0, 1] based on a given range.
///
/// This function maps a value from an arbitrary range to a normalized 0-1 range.
/// The result represents where the value falls within the given range as a percentage.
///
/// - Parameters:
///   - value: The value to normalize.
///   - range: The range that the value falls within.
/// - Returns: A value in the range [0, 1] representing the position of `value` within `range`.
///
/// ## Example
/// ```swift
/// let normalized1 = normalize(50, in: 0...100)    // Returns 0.5
/// let normalized2 = normalize(25, in: 0...100)    // Returns 0.25
/// let normalized3 = normalize(75, in: 50...100)   // Returns 0.5
/// let normalized4 = normalize(100, in: 0...200)   // Returns 0.5
/// ```
public func normalize(_ value: Float, in range: ClosedRange<Float>) -> Float {
    return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
}

/// Linearly interpolates between two Float values using an alpha parameter.
///
/// This function is similar to ``Float/lerp(from:to:time:)`` but uses an `alpha` parameter
/// name instead of `time` for clarity in contexts where the parameter doesn't represent time.
///
/// - Parameters:
///   - start: The starting value.
///   - end: The ending value.
///   - alpha: The interpolation parameter, typically in the range [0, 1].
/// - Returns: The interpolated value.
///
/// ## Example
/// ```swift
/// let result1 = interpolate(from: 0, to: 100, alpha: 0.0)    // Returns 0.0
/// let result2 = interpolate(from: 0, to: 100, alpha: 0.5)    // Returns 50.0
/// let result3 = interpolate(from: 0, to: 100, alpha: 1.0)    // Returns 100.0
/// let result4 = interpolate(from: 20, to: 80, alpha: 0.25)   // Returns 35.0
/// ```
public func interpolate(from start: Float, to end: Float, alpha: Float) -> Float {
    return (1 - alpha) * start + alpha * end
}
