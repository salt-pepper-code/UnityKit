import CoreGraphics
import Foundation

public extension CGFloat {
    /// Converts this CGFloat value to a Float.
    ///
    /// This is a convenience method for type conversion between CoreGraphics and standard
    /// floating-point types. Note that precision may be lost when converting from CGFloat
    /// to Float on 64-bit platforms where CGFloat is backed by Double.
    ///
    /// - Returns: The value as a Float.
    ///
    /// ## Example
    /// ```swift
    /// let cgValue: CGFloat = 3.14159
    /// let floatValue = cgValue.toFloat()  // Returns Float(3.14159)
    ///
    /// // Useful for interoperability
    /// let width: CGFloat = view.frame.width
    /// let floatWidth = width.toFloat()
    /// ```
    func toFloat() -> Float {
        return Float(self)
    }

    /// Converts this CGFloat value to a Double.
    ///
    /// This is a convenience method for type conversion. On 64-bit platforms, CGFloat
    /// is already backed by Double, so this conversion is lossless.
    ///
    /// - Returns: The value as a Double.
    ///
    /// ## Example
    /// ```swift
    /// let cgValue: CGFloat = 2.71828
    /// let doubleValue = cgValue.toDouble()  // Returns Double(2.71828)
    ///
    /// // Useful for mathematical operations requiring Double precision
    /// let height: CGFloat = view.frame.height
    /// let preciseHeight = height.toDouble()
    /// ```
    func toDouble() -> Double {
        return Double(self)
    }
}

public extension Float {
    /// Converts this Float value to a Double.
    ///
    /// This is a convenience method for type conversion. Converting from Float to Double
    /// is always safe and lossless as Double has greater precision than Float.
    ///
    /// - Returns: The value as a Double.
    ///
    /// ## Example
    /// ```swift
    /// let floatValue: Float = 1.23456
    /// let doubleValue = floatValue.toDouble()  // Returns Double(1.23456)
    ///
    /// // Useful for precision-critical calculations
    /// let temperature: Float = 98.6
    /// let preciseTemp = temperature.toDouble()
    /// ```
    func toDouble() -> Double {
        return Double(self)
    }

    /// Converts this Float value to a CGFloat.
    ///
    /// This is a convenience method for type conversion, commonly used when working with
    /// CoreGraphics and UIKit/AppKit APIs that require CGFloat values.
    ///
    /// - Returns: The value as a CGFloat.
    ///
    /// ## Example
    /// ```swift
    /// let floatValue: Float = 42.0
    /// let cgValue = floatValue.toCGFloat()  // Returns CGFloat(42.0)
    ///
    /// // Useful for UI layout calculations
    /// let spacing: Float = 10.0
    /// view.frame.origin.x = spacing.toCGFloat()
    /// ```
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

public extension Double {
    /// Converts this Double value to a Float.
    ///
    /// This is a convenience method for type conversion. Note that precision may be lost
    /// when converting from Double to Float, as Float has less precision than Double.
    ///
    /// - Returns: The value as a Float.
    ///
    /// ## Example
    /// ```swift
    /// let doubleValue: Double = 3.141592653589793
    /// let floatValue = doubleValue.toFloat()  // Returns Float(3.1415927) - precision loss
    ///
    /// // Useful when working with APIs that require Float
    /// let preciseValue: Double = calculatePreciseValue()
    /// let approximateValue = preciseValue.toFloat()
    /// ```
    func toFloat() -> Float {
        return Float(self)
    }
}
