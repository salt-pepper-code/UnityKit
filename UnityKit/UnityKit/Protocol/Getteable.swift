
public protocol Getteable {
    static var defaultValue: Self { get }
}

extension Bool: Getteable {
    public static var defaultValue: Bool {
        return false
    }
}

extension Float: Getteable {
    public static var defaultValue: Float {
        return 0
    }
}

extension Vector3: Getteable {
    public static var defaultValue: Vector3 {
        return .zero
    }
}

extension Vector4: Getteable {
    public static var defaultValue: Vector4 {
        return .zero
    }
}
