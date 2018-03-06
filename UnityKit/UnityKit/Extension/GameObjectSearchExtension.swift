extension GameObject {
    
    public enum SearchType {
        case name(String)
        case tag(Tag)
        case layer(Layer)
        case nameAndTag(String, Tag)
        case any
    }
    
    public static func find(_ type: SearchType, in scene: Scene? = Scene.sharedInstance) -> GameObject? {
        guard let scene = scene
            else { return nil }

        return GameObject.find(type, in: scene.rootGameObject)
    }
    
    public static func find(_ type: SearchType, in gameObject: GameObject) -> GameObject? {

        switch type {
        case let .name(name) where gameObject.name == name:
            return gameObject
        case let .tag(tag) where gameObject.tag == tag:
            return gameObject
        case let .nameAndTag(name, tag) where gameObject.name == name && gameObject.tag == tag:
            return gameObject
        case let .layer(layer) where gameObject.layer == layer:
            return gameObject
        case .any:
            return gameObject.getChilds().first
        default:
            break
        }

        for child in gameObject.getChilds() {
            if let found = GameObject.find(type, in: child) {
                return found
            }
        }
        return nil
    }
    
    public static func findGameObjects(_ type: SearchType, in scene: Scene? = Scene.sharedInstance) -> [GameObject] {
        guard let scene = scene
            else { return [] }

        return GameObject.findGameObjects(type, in: scene.rootGameObject)
    }
    
    public static func findGameObjects(_ type: SearchType, in gameObject: GameObject) -> [GameObject] {
        
        var list = [GameObject]()
        
        switch type {
        case let .name(name) where gameObject.name == name:
            list.append(gameObject)
        case let .tag(tag) where gameObject.tag == tag:
            list.append(gameObject)
        case let .nameAndTag(name, tag) where gameObject.name == name && gameObject.tag == tag:
            list.append(gameObject)
        case let .layer(layer) where gameObject.layer == layer:
            list.append(gameObject)
        case .any:
            list.append(gameObject)
        default:
            break
        }

        list.append(contentsOf: gameObject.getChilds().flatMap {
            GameObject.findGameObjects(type, in: $0)
        })
        return list
    }
}

