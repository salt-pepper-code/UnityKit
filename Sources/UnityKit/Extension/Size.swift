import UIKit

public struct Size {
    public let width: Float
    public let height: Float

    public static let zero = Size(0, 0)

    public init(_ width: Float, _ height: Float) {
        self.width = width
        self.height = height
    }

    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
}

public extension Size {
    func toCGSize() -> CGSize {
        return CGSize(width: self.width.toCGFloat(), height: self.height.toCGFloat())
    }
}

public extension CGSize {
    func toSize() -> Size {
        return Size(width: width.toFloat(), height: height.toFloat())
    }
}

extension Size: Equatable {
    public static func == (left: Size, right: Size) -> Bool {
        return left.width == right.width && left.height == right.height
    }
}

/// Multiplies the width and height fields of a Size with a scalar value
///
/// - Parameters:
///   - size: A size
///   - scalar: A float
/// - Returns: the result as a new Size.
public func * (size: Size, scalar: Float) -> Size {
    return Size(size.width * scalar, size.height * scalar)
}

/// Multiplies the width and height fields of a Size with a scalar value
///
/// - Parameters:
///   - scalar: A float
///   - size: A size
/// - Returns: the result as a new Size.
public func * (scalar: Float, size: Size) -> Size {
    return Size(size.width * scalar, size.height * scalar)
}
