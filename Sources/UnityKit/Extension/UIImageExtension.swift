import UIKit

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))

        guard let result = UIGraphicsGetImageFromCurrentImageContext()
        else { return self }

        return result
    }

    func replaceColor(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)

        guard let c = UIGraphicsGetCurrentContext()
        else { return self }

        draw(in: rect)

        c.setFillColor(color.cgColor)
        c.setBlendMode(.sourceIn)
        c.fill(rect)

        guard let result = UIGraphicsGetImageFromCurrentImageContext()
        else { return self }

        return result
    }

    func fill(
        fromAngle: Degree,
        toAngle: Degree,
        fillOrigin: UI.Image.FillOrigin,
        clockwise: Bool
    ) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)

        guard let ctx = UIGraphicsGetCurrentContext()
        else { return self }

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let nextPoint: CGPoint

        var from = fromAngle
        var to = toAngle

        switch fillOrigin {
        case .right:
            nextPoint = CGPoint(x: size.width, y: center.y)
        case .bottom:
            nextPoint = CGPoint(x: center.x, y: 0)
            from += 90
            to += 90
        case .left:
            nextPoint = CGPoint(x: 0, y: center.y)
            from += 180
            to += 180
        case .top:
            nextPoint = CGPoint(x: center.x, y: size.height)
            from += 270
            to += 270
        }

        let path = CGMutablePath()
        path.move(to: center)
        path.addLine(to: nextPoint)
        path.addArc(
            center: center, radius: size.height / 2,
            startAngle: from.toCGFloat().degreesToRadians,
            endAngle: to.toCGFloat().degreesToRadians,
            clockwise: clockwise
        )
        path.addLine(to: center)

        ctx.addPath(path)
        ctx.closePath()
        ctx.clip()

        draw(in: rect)

        guard let result = UIGraphicsGetImageFromCurrentImageContext()
        else { return self }

        return result
    }
}
