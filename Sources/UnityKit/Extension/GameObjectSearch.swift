extension GameObject {
    public enum SearchType {
        public enum Name {
            case contains(String)
            case startWith(String)
            case exact(String)
            case any
        }
        case name(Name)
        case tag(Tag)
        case layer(Layer)
        case nameAndTag(Name, Tag)
        case camera(Name)
        case light(Name)
    }

    private static func compare(_ compareType: SearchType.Name, to other: String) -> Bool {
        switch compareType {
        case let .contains(name):
            return other.contains(name)

        case let .startWith(name):
            return other.starts(with: name)

        case let .exact(name):
            return other == name

        case .any:
            return true
        }
    }

    private static func compare(_ type: SearchType, gameObject: GameObject) -> Bool {
        switch type {
        case let .name(compareType):
            guard let name = gameObject.name,
                GameObject.compare(compareType, to: name)
                else { break }

            return true

        case let .tag(tag) where gameObject.tag == tag:
            return true

        case let .nameAndTag(compareType, tag):

            guard let name = gameObject.name,
                GameObject.compare(compareType, to: name),
                gameObject.tag == tag
                else { break }

            return true

        case let .layer(layer) where gameObject.layer == layer:
            return true

        case let .camera(compareType):

            guard let _ = gameObject.node.camera,
                let name = gameObject.name,
                GameObject.compare(compareType, to: name)
                else { break }

            return true

        case let .light(compareType):

            guard let _ = gameObject.node.light,
                let name = gameObject.name,
                GameObject.compare(compareType, to: name)
                else { break }

            return true

        default:
            break
        }

        return false
    }

    public static func find(_ type: SearchType, in scene: Scene? = Scene.shared) -> GameObject? {
        guard let scene = scene else { return nil }
        return GameObject.find(type, in: scene.rootGameObject)
    }

    public static func find(_ type: SearchType, in gameObject: GameObject) -> GameObject? {
        for child in gameObject.getChildren() {
            if GameObject.compare(type, gameObject: child) {
                return child
            }
        }
        for child in gameObject.getChildren() {
            if let found = GameObject.find(type, in: child) {
                return found
            }
        }
        return nil
    }

    public static func findGameObjects(_ type: SearchType, in scene: Scene? = Scene.shared) -> [GameObject] {
        guard let scene = scene else { return [] }
        return GameObject.findGameObjects(type, in: scene.rootGameObject)
    }

    public static func findGameObjects(_ type: SearchType, in gameObject: GameObject) -> [GameObject] {
        return gameObject.getChildren()
            .map { (child) -> [GameObject] in
                if GameObject.compare(type, gameObject: child) {
                    return [child] + GameObject.findGameObjects(type, in: child)
                }
                return GameObject.findGameObjects(type, in: child)
            }
            .reduce([], { (current, next) -> [GameObject] in
                current + next
            })
    }

    public static func getComponents<T: Component>(_ type: T.Type, in scene: Scene? = Scene.shared) -> [T] {
        guard let scene = scene else { return [] }
        return GameObject.getComponents(type, in: scene.rootGameObject)
    }

    public static func getComponents<T: Component>(_ type: T.Type, in gameObject: GameObject) -> [T] {
        return gameObject.getChildren()
            .map { (child) -> [T] in
                return child.getComponents(type) + GameObject.getComponents(type, in: child)
            }.reduce([], { (current, next) -> [T] in
                current + next
            })
    }
}
