import UIKit

public typealias Color = UIColor

public extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        guard let c = self.cgColor.components
        else { return (red: 1, green: 1, blue: 1, alpha: 1) }

        return (red: c[0], green: c[1], blue: c[2], alpha: c[3])
    }

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
