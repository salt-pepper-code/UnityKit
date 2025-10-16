public extension GameObject {
    enum SearchType {
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
        case .contains(let name):
            return other.contains(name)

        case .startWith(let name):
            return other.starts(with: name)

        case .exact(let name):
            return other == name

        case .any:
            return true
        }
    }

    private static func compare(_ type: SearchType, gameObject: GameObject) -> Bool {
        switch type {
        case .name(let compareType):
            guard let name = gameObject.name,
                  GameObject.compare(compareType, to: name)
            else { break }

            return true

        case .tag(let tag) where gameObject.tag == tag:
            return true

        case .nameAndTag(let compareType, let tag):
            guard let name = gameObject.name,
                  GameObject.compare(compareType, to: name),
                  gameObject.tag == tag
            else { break }

            return true

        case .layer(let layerMask) where layerMask.contains(gameObject.layer):
            return true

        case .camera(let compareType):
            guard let _ = gameObject.node.camera,
                  let name = gameObject.name,
                  GameObject.compare(compareType, to: name)
            else { break }

            return true

        case .light(let compareType):
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

    static func find(_ type: SearchType, in scene: Scene? = Scene.shared) -> GameObject? {
        guard let scene else { return nil }
        return GameObject.find(type, in: scene.rootGameObject)
    }

    static func find(_ type: SearchType, in gameObject: GameObject) -> GameObject? {
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

    static func findGameObjects(_ type: SearchType, in scene: Scene? = Scene.shared) -> [GameObject] {
        guard let scene else { return [] }
        return GameObject.findGameObjects(type, in: scene.rootGameObject)
    }

    static func findGameObjects(_ type: SearchType, in gameObject: GameObject) -> [GameObject] {
        return gameObject.getChildren()
            .map { child -> [GameObject] in
                if GameObject.compare(type, gameObject: child) {
                    return [child] + GameObject.findGameObjects(type, in: child)
                }
                return GameObject.findGameObjects(type, in: child)
            }
            .reduce([]) { current, next -> [GameObject] in
                current + next
            }
    }

    static func getComponents<T: Component>(_ type: T.Type, in scene: Scene? = Scene.shared) -> [T] {
        guard let scene else { return [] }
        return GameObject.getComponents(type, in: scene.rootGameObject)
    }

    static func getComponents<T: Component>(_ type: T.Type, in gameObject: GameObject) -> [T] {
        return gameObject.getChildren()
            .map { child -> [T] in
                return child.getComponents(type) + GameObject.getComponents(type, in: child)
            }.reduce([]) { current, next -> [T] in
                current + next
            }
    }
}
