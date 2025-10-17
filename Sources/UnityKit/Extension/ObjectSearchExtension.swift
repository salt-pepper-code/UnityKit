import UIKit

public extension Object {
    /// Finds the first component of the specified type in the scene.
    ///
    /// Searches the scene hierarchy for a component of the given type, starting from the root GameObject
    /// and traversing through all children. Returns the first matching component found.
    ///
    /// - Parameters:
    ///   - type: The type of component to search for
    ///   - scene: The scene to search in. Defaults to the shared scene if not specified.
    /// - Returns: The first component of the specified type, or nil if none found
    ///
    /// ## Use Cases
    ///
    /// - Finding singleton-like components (Camera, AudioListener, etc.)
    /// - Locating unique manager or controller components
    /// - Quick access to components when only one instance exists
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Find the main camera in the scene
    /// if let camera = Object.findObjectOfType(Camera.self) {
    ///     camera.fieldOfView = 60
    /// }
    ///
    /// // Find a custom controller component
    /// class GameController: MonoBehaviour {
    ///     func startGame() { }
    /// }
    ///
    /// if let controller = Object.findObjectOfType(GameController.self) {
    ///     controller.startGame()
    /// }
    ///
    /// // Search in a specific scene
    /// let menuScene = Scene()
    /// if let menuManager = Object.findObjectOfType(MenuManager.self, in: menuScene) {
    ///     menuManager.showMainMenu()
    /// }
    /// ```
    ///
    /// - Note: This method stops searching after finding the first match. Use ``findObjectsOfType(_:in:)``
    ///   if you need to find all instances of a component type.
    static func findObjectOfType<T: Component>(_ type: T.Type, in scene: Scene? = Scene.shared) -> T? {
        guard let scene
        else { return nil }

        if let component = scene.rootGameObject.getComponent(type) { return component }
        if let component = scene.rootGameObject.getComponentInChild(type) { return component }
        return nil
    }

    /// Finds all components of the specified type in the scene.
    ///
    /// Searches the entire scene hierarchy and returns an array of all components matching
    /// the specified type. This method uses caching for improved performance on repeated searches.
    ///
    /// - Parameters:
    ///   - type: The type of component to search for
    ///   - scene: The scene to search in. Defaults to the shared scene if not specified.
    /// - Returns: An array of all components of the specified type (may be empty if none found)
    ///
    /// ## Use Cases
    ///
    /// - Finding all instances of a component type (e.g., all enemies, all lights)
    /// - Batch operations on multiple components
    /// - Collecting statistics or performing analysis across multiple objects
    /// - Managing groups of related components
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Find all lights in the scene and adjust their intensity
    /// let lights = Object.findObjectsOfType(Light.self)
    /// for light in lights {
    ///     light.intensity *= 1.5
    /// }
    ///
    /// // Find all enemy components and count them
    /// class Enemy: MonoBehaviour {
    ///     var health: Float = 100
    /// }
    ///
    /// let enemies = Object.findObjectsOfType(Enemy.self)
    /// print("There are \(enemies.count) enemies in the scene")
    ///
    /// // Process all components of a type
    /// let audioSources = Object.findObjectsOfType(AudioSource.self)
    /// audioSources.forEach { $0.volume = 0.5 }
    ///
    /// // Search in a specific scene
    /// let battleScene = Scene()
    /// let players = Object.findObjectsOfType(PlayerController.self, in: battleScene)
    /// ```
    ///
    /// ## Performance
    ///
    /// This method uses an internal cache to improve performance for repeated searches of the same type.
    /// The first search may take longer as it traverses the hierarchy, but subsequent searches will be faster.
    ///
    /// - Note: If you only need the first component, use ``findObjectOfType(_:in:)`` for better performance.
    static func findObjectsOfType<T: Component>(_ type: T.Type, in scene: Scene? = Scene.shared) -> [T] {
        guard let scene
        else { return [] }
        if let cache = Object.cache(type) {
            return cache
        }
        return scene.rootGameObject.getComponents(type) + scene.rootGameObject.getComponentsInChild(type)
    }
}
