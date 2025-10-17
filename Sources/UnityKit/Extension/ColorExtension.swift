import UIKit

/// A typealias for UIColor, providing a platform-agnostic color type.
///
/// Use `Color` instead of `UIColor` to make code more portable and semantically clearer
/// in cross-platform contexts.
///
/// ## Example
/// ```swift
/// let red: Color = .red
/// let custom = Color(red: 0.5, green: 0.2, blue: 0.8, alpha: 1.0)
/// ```
public typealias Color = UIColor

public extension Color {
    /// Extracts the red, green, blue, and alpha components of this color.
    ///
    /// Returns a tuple containing the RGBA components as CGFloat values in the range [0, 1].
    /// If the color components cannot be extracted, returns white (1, 1, 1, 1) as a fallback.
    ///
    /// ## Example
    /// ```swift
    /// let purple = Color(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
    /// let components = purple.components
    /// print(components.red)    // 0.5
    /// print(components.green)  // 0.0
    /// print(components.blue)   // 0.5
    /// print(components.alpha)  // 1.0
    ///
    /// // Use in calculations
    /// let brighterRed = components.red * 1.5
    /// ```
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        guard let c = self.cgColor.components
        else { return (red: 1, green: 1, blue: 1, alpha: 1) }

        return (red: c[0], green: c[1], blue: c[2], alpha: c[3])
    }

    /// Creates a color from a hexadecimal string.
    ///
    /// Supports both 6-character RGB and 8-character RGBA hex strings.
    /// The string must be prefixed with "#". If the string is invalid,
    /// returns red as a fallback color.
    ///
    /// - Parameter hex: A hexadecimal color string in the format "#RRGGBB" or "#RRGGBBAA".
    ///
    /// ## Example
    /// ```swift
    /// // RGB format (6 characters)
    /// let red = Color(hex: "#FF0000")
    /// let blue = Color(hex: "#0000FF")
    /// let green = Color(hex: "#00FF00")
    ///
    /// // RGBA format (8 characters) with alpha
    /// let semiTransparentRed = Color(hex: "#FF000080")  // 50% opacity
    /// let fullyOpaque = Color(hex: "#00FF00FF")
    ///
    /// // Common colors
    /// let white = Color(hex: "#FFFFFF")
    /// let black = Color(hex: "#000000")
    /// let gray = Color(hex: "#808080")
    /// ```
    convenience init(hex: String) {
        let r, g, b, a: CGFloat

        guard hex.hasPrefix("#") else {
            self.init(red: 1, green: 0, blue: 0, alpha: 1)
            return
        }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        guard scanner.scanHexInt64(&hexNumber) else {
            self.init(red: 1, green: 0, blue: 0, alpha: 1)
            return
        }

        r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
        a = hexColor.count == 8 ? CGFloat(hexNumber & 0x0000_00FF) / 255 : 1

        self.init(red: r, green: g, blue: b, alpha: a)
        return
    }

    /// Converts this color to a hexadecimal string representation.
    ///
    /// Returns a 6-character hex string in the format "#RRGGBB". The alpha component
    /// is not included in the output.
    ///
    /// - Returns: A hexadecimal color string in the format "#RRGGBB".
    ///
    /// ## Example
    /// ```swift
    /// let red = Color(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    /// let hexString = red.toHexString()  // Returns "#ff0000"
    ///
    /// let purple = Color(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
    /// let purpleHex = purple.toHexString()  // Returns "#7f007f"
    ///
    /// let white = Color.white
    /// let whiteHex = white.toHexString()  // Returns "#ffffff"
    ///
    /// // Useful for saving color preferences
    /// UserDefaults.standard.set(themeColor.toHexString(), forKey: "themeColor")
    /// ```
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255) << 0
        return String(format: "#%06x", rgb)
    }
}
