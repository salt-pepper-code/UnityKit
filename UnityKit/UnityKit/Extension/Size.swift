
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

extension Size {

    public func toCGSize() -> CGSize {
        return CGSize(width: width.toCGFloat(), height: height.toCGFloat())
    }
}

/**
 * Multiplies the x, y and z fields of a Vector2 with the same scalar value and
 * returns the result as a new Vector2.
 */
public func * (vector: Size, scalar: Float) -> Size {
    return Size(vector.width * scalar, vector.height * scalar)
}

public func * (scalar: Float, vector: Size) -> Size {
    return Size(vector.width * scalar, vector.height * scalar)
}
