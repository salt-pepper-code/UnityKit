import UIKit

extension Object {

    public static func findObjectOfType<T: Component>(_ type: T.Type, inScene scene: Scene) -> T? {

        if let component = scene.rootGameObject.getComponent(type) { return component }

        if let component = scene.rootGameObject.getComponentInChild(type) { return component }

        return nil
    }
    
    public static func findObjectsOfType<T: Component>(_ type: T.Type, inScene scene: Scene) -> [T]? {
        
        return scene.rootGameObject.getComponents(type) + scene.rootGameObject.getComponentsInChild(type)
    }
}
