public extension GameObject {
    enum Tag: Hashable {
        case untagged
        case mainCamera
        case custom(String)

        public var name: String {
            switch self {
            case .untagged:
                return "Untagged"
            case .mainCamera:
                return "MainCamera"
            case .custom(let name):
                return name
            }
        }

        public func hash(into hasher: inout Hasher) {
            switch self {
            case .untagged: hasher.combine(0)
            case .mainCamera: hasher.combine(1)
            case .custom(let name): hasher.combine(name)
            }
        }
    }
}
