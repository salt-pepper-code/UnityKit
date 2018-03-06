
extension GameObject {

    public enum Tag: Hashable {

        case untagged
        case mainCamera
        case custom(String)

        public var name: String {
            switch self {
            case .untagged:
                return "Untagged"
            case .mainCamera:
                return "MainCamera"
            case let .custom(name):
                return name
            }
        }

        public var hashValue: Int {
            return self.toInt()
        }

        private func toInt() -> Int {

            switch self {
            case .untagged:
                return 0
            case .mainCamera:
                return 1
            case let .custom(name):
                return name.hashValue
            }
        }

        public static func ==(lhs: Tag, rhs: Tag) -> Bool {
            return lhs.toInt() == rhs.toInt()
        }
    }
}
