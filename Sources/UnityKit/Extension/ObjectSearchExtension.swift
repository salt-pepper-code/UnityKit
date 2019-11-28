import UIKit

extension Object {
    public static func findObjectOfType<T: Component>(_ type: T.Type, in scene: Scene? = Scene.shared) -> T? {
        guard let scene = scene
            else { return nil }

        if let component = scene.rootGameObject.getComponent(type) { return component }
        if let component = scene.rootGameObject.getComponentInChild(type) { return component }
        return nil
    }

    public static func findObjectsOfType<T: Component>(_ type: T.Type, in scene: Scene? = Scene.shared) -> [T] {
        guard let scene = scene
            else { return [] }
        if let cache = Object.cache(type) {
            return cache
        }
        return scene.rootGameObject.getComponents(type) + scene.rootGameObject.getComponentsInChild(type)
    }
}
