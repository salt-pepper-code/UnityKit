import Foundation
import SceneKit

/// Options for loading scenes from file resources.
///
/// A type alias for SceneKit's loading options dictionary, used when loading scenes from files.
public typealias SceneLoadingOptions = [SCNSceneSource.LoadingOption: Any]

/// Container for game objects and scene management.
///
/// A Scene represents a collection of ``GameObject``s and manages their lifecycle, updates, and rendering.
/// It wraps SceneKit's SCNScene and provides Unity-style scene management with automatic camera setup,
/// shadow configuration, and object hierarchy management.
///
/// ## Overview
///
/// Scenes are the fundamental organizational unit in UnityKit. Each scene contains a hierarchy of GameObjects
/// and manages their update cycles. You can load scenes from files or create them programmatically.
///
/// Every scene has a ``rootGameObject`` that serves as the parent for all GameObjects in the scene. The framework
/// automatically manages update calls to all active GameObjects in the hierarchy.
///
/// ## Scene Allocation
///
/// Scenes can be created with two allocation modes:
/// - ``Allocation/singleton`` - Sets this scene as the shared instance accessible via ``shared``
/// - ``Allocation/instantiate`` - Creates an independent scene instance
///
/// ## Automatic Setup
///
/// When a scene is created, the framework automatically:
/// - Creates a root GameObject for the scene hierarchy
/// - Searches for or creates a main camera
/// - Configures shadow settings based on initialization parameters
/// - Sets up the update loop integration
///
/// ## Example
///
/// ```swift
/// // Load scene from file
/// if let scene = Scene(sceneName: "Level1", allocation: .singleton) {
///     // Scene is now loaded and set as the shared instance
///
///     // Add objects to the scene
///     let player = GameObject(name: "Player")
///     scene.addGameObject(player)
///
///     // Find objects in the scene
///     if let camera = scene.find(.mainCamera) {
///         camera.transform.position = Vector3(0, 5, 10)
///     }
/// }
///
/// // Create empty scene programmatically
/// let scene = Scene(allocation: .instantiate)
/// scene.addGameObject(GameObject(name: "CustomObject"))
/// ```
///
/// ## Topics
///
/// ### Creating Scenes
///
/// - ``init(sceneName:options:bundle:allocation:shadowCastingAllowed:)``
/// - ``init(scenePath:options:bundle:allocation:shadowCastingAllowed:)``
/// - ``init(sceneUrl:options:allocation:shadowCastingAllowed:)``
/// - ``init(_:allocation:shadowCastingAllowed:)``
/// - ``Allocation``
///
/// ### Scene Properties
///
/// - ``id``
/// - ``scnScene``
/// - ``rootGameObject``
/// - ``shadowCastingAllowed``
/// - ``shared``
///
/// ### Managing GameObjects
///
/// - ``addGameObject(_:)``
/// - ``find(_:)``
/// - ``findGameObjects(_:)``
/// - ``clearScene()``
///
/// ### Identification
///
/// - ``getInstanceID()``
open class Scene: Identifiable, Equatable {
    /// Defines how a scene is allocated in memory.
    ///
    /// The allocation mode determines whether the scene becomes the shared singleton instance
    /// or exists as an independent instance.
    public enum Allocation {
        /// Create an independent scene instance that does not affect ``Scene/shared``.
        case instantiate
        /// Set this scene as the shared singleton instance accessible via ``Scene/shared``.
        case singleton
    }

    private var gameObjectCount: Int = 0
    private var ignoreUpdatesCount: Int = 0
    private var lastTimeStamp: TimeInterval?

    /// The underlying SceneKit scene.
    ///
    /// Provides direct access to the SceneKit SCNScene that this Scene wraps. Use this when you need
    /// to access SceneKit-specific features or integrate with SceneKit APIs.
    public let scnScene: SCNScene

    /// The root ``GameObject`` of the scene hierarchy.
    ///
    /// All GameObjects in the scene are children of this root object. You can traverse the entire
    /// scene hierarchy by iterating through the children of this GameObject.
    public let rootGameObject: GameObject

    /// Whether shadow casting is enabled for objects in this scene.
    ///
    /// When `false`, all objects in the scene will have shadow casting disabled. This setting
    /// is applied during scene initialization.
    let shadowCastingAllowed: Bool

    /// The unique identifier for this scene.
    ///
    /// A UUID string that uniquely identifies this scene instance. Use ``getInstanceID()`` to
    /// retrieve this value.
    public let id: String

    /// The shared singleton scene instance.
    ///
    /// When a scene is created with ``Allocation/singleton``, it becomes accessible through this property.
    /// Only one scene can be the shared instance at a time. Creating a new singleton scene replaces the
    /// previous one.
    ///
    /// - Returns: The current shared scene, or `nil` if no singleton scene exists.
    public private(set) static var shared: Scene?

    /// Creates a scene by searching for a resource by name.
    ///
    /// Searches for a scene file with the specified name in the bundle. The search includes all
    /// common scene file extensions.
    ///
    /// - Parameters:
    ///   - sceneName: The name of the scene resource to load (without extension).
    ///   - options: Optional loading options to pass to SceneKit.
    ///   - bundle: The bundle to search in. Defaults to the main bundle.
    ///   - allocation: How the scene should be allocated (singleton or instance).
    ///   - shadowCastingAllowed: Whether objects in the scene should cast shadows. Defaults to `true`.
    ///
    /// - Returns: A new Scene instance, or `nil` if the resource could not be found or loaded.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let scene = Scene(sceneName: "Level1", allocation: .singleton) {
    ///     print("Scene loaded successfully")
    /// }
    /// ```
    public convenience init?(
        sceneName: String,
        options: SceneLoadingOptions? = nil,
        bundle: Bundle = Bundle.main,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        guard let sceneUrl = searchPathForResource(for: sceneName, extension: nil, bundle: bundle)
        else { return nil }

        self.init(
            sceneUrl: sceneUrl,
            options: options,
            allocation: allocation,
            shadowCastingAllowed: shadowCastingAllowed
        )
    }

    /// Creates a scene from a resource path.
    ///
    /// Loads a scene file using the specified path within the bundle. The path should include
    /// any subdirectories but not the file extension.
    ///
    /// - Parameters:
    ///   - scenePath: The path to the scene resource within the bundle (without extension).
    ///   - options: Optional loading options to pass to SceneKit.
    ///   - bundle: The bundle to search in. Defaults to the main bundle.
    ///   - allocation: How the scene should be allocated (singleton or instance).
    ///   - shadowCastingAllowed: Whether objects in the scene should cast shadows. Defaults to `true`.
    ///
    /// - Returns: A new Scene instance, or `nil` if the resource could not be found or loaded.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let scene = Scene(scenePath: "Scenes/Level1.scn", allocation: .instantiate) {
    ///     print("Scene loaded from path")
    /// }
    /// ```
    public convenience init?(
        scenePath: String,
        options: SceneLoadingOptions? = nil,
        bundle: Bundle = Bundle.main,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        guard let sceneUrl = bundle.url(forResource: scenePath, withExtension: nil)
        else { return nil }

        self.init(
            sceneUrl: sceneUrl,
            options: options,
            allocation: allocation,
            shadowCastingAllowed: shadowCastingAllowed
        )
    }

    /// Creates a scene from a URL.
    ///
    /// Loads a scene file from the specified file URL. This allows loading scenes from
    /// any location accessible via URL, including documents directory or downloaded files.
    ///
    /// - Parameters:
    ///   - sceneUrl: The URL of the scene file to load.
    ///   - options: Optional loading options to pass to SceneKit.
    ///   - allocation: How the scene should be allocated (singleton or instance).
    ///   - shadowCastingAllowed: Whether objects in the scene should cast shadows. Defaults to `true`.
    ///
    /// - Returns: A new Scene instance, or `nil` if the file could not be loaded.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    /// let sceneUrl = documentsUrl.appendingPathComponent("level.scn")
    ///
    /// if let scene = Scene(sceneUrl: sceneUrl, allocation: .singleton) {
    ///     print("Scene loaded from URL")
    /// }
    /// ```
    public convenience init?(
        sceneUrl: URL,
        options: SceneLoadingOptions? = nil,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        guard let scene = try? SCNScene(url: sceneUrl, options: options)
        else { return nil }

        self.init(
            scene,
            allocation: allocation,
            shadowCastingAllowed: shadowCastingAllowed
        )
    }

    /// Creates a scene from an existing SCNScene or creates an empty scene.
    ///
    /// This is the designated initializer for Scene. It wraps an existing SceneKit scene or creates
    /// a new empty scene if none is provided. The initializer performs automatic setup including
    /// camera configuration and shadow settings.
    ///
    /// - Parameters:
    ///   - scene: An existing SCNScene to wrap, or `nil` to create an empty scene.
    ///   - allocation: How the scene should be allocated (singleton or instance).
    ///   - shadowCastingAllowed: Whether objects in the scene should cast shadows. Defaults to `true`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create empty scene
    /// let emptyScene = Scene(allocation: .instantiate)
    ///
    /// // Wrap existing SCNScene
    /// let scnScene = SCNScene()
    /// let scene = Scene(scnScene, allocation: .singleton)
    /// ```
    public init(
        _ scene: SCNScene? = nil,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        self.shadowCastingAllowed = shadowCastingAllowed

        self.id = UUID().uuidString

        self.scnScene = scene ?? SCNScene()

        self.rootGameObject = GameObject(self.scnScene.rootNode)

        self.rootGameObject.setScene(self)

        if let camera = GameObject.find(.camera(.any), in: self) {
            camera.tag = .mainCamera
            camera.name = camera.tag.name
        }

        if Camera.main(in: self) == nil {
            let cameraObject = GameObject()

            cameraObject.tag = .mainCamera
            cameraObject.name = cameraObject.tag.name

            self.rootGameObject.addChild(cameraObject)

            let cameraComponent = cameraObject.addComponent(Camera.self)
            cameraObject.node.camera = cameraComponent.scnCamera

            cameraObject.transform.position = Vector3(0, 10, 20)
        }

        if shadowCastingAllowed == false {
            self.disableCastsShadow(gameObject: self.rootGameObject)
        }

        switch allocation {
        case .singleton:
            Scene.shared = self
        case .instantiate:
            Scene.shared = nil
        }
    }

    func disableCastsShadow(gameObject: GameObject) {
        for getChild in gameObject.getChildren() {
            getChild.node.castsShadow = false
            getChild.node.light?.castsShadow = false
            self.disableCastsShadow(gameObject: getChild)
        }
    }

    //

    /// Returns the unique instance identifier for this scene.
    ///
    /// Each scene has a unique UUID-based identifier that remains constant for the lifetime
    /// of the scene instance.
    ///
    /// - Returns: The unique identifier string for this scene.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let scene = Scene(allocation: .instantiate)
    /// let id = scene.getInstanceID()
    /// print("Scene ID: \(id)")
    /// ```
    public func getInstanceID() -> String {
        self.id
    }

    func preUpdate(updateAtTime time: TimeInterval) {
        guard let _ = lastTimeStamp else { return }

        self.rootGameObject.preUpdate()
    }

    func update(updateAtTime time: TimeInterval) {
        guard let lastTimeStamp else {
            self.lastTimeStamp = time
            self.rootGameObject.start()
            return
        }

        // Calculate unscaled delta time
        let realDelta = time - lastTimeStamp
        Time.unscaledDeltaTime = realDelta

        // Apply time scale and update scaled delta/time
        Time.deltaTime = realDelta * Time.timeScale
        Time.time += Time.deltaTime
        Time.frameCount += 1

        self.rootGameObject.update()
        self.rootGameObject.internalUpdate()
        self.lastTimeStamp = time
    }

    func fixedUpdate(updateAtTime time: TimeInterval) {
        guard let _ = lastTimeStamp else { return }
        self.rootGameObject.fixedUpdate()
    }

    //

    /// Removes all GameObjects from the scene.
    ///
    /// Destroys all child GameObjects of the ``rootGameObject``, effectively clearing the scene.
    /// The root GameObject itself remains intact and can be used to add new objects.
    ///
    /// - Note: This operation cannot be undone. Make sure to save any important state before calling.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let scene = Scene.shared
    /// scene?.clearScene()  // All GameObjects are now destroyed
    ///
    /// // Add new objects
    /// let newObject = GameObject(name: "NewObject")
    /// scene?.addGameObject(newObject)
    /// ```
    public func clearScene() {
        let copy = self.rootGameObject.getChildren()
        copy.forEach { destroy($0) }
    }

    /// Adds a ``GameObject`` to this scene.
    ///
    /// Adds the specified GameObject as a child of the ``rootGameObject`` and configures it
    /// according to the scene's settings. If shadow casting is disabled for this scene,
    /// the GameObject's shadow casting will also be disabled.
    ///
    /// - Parameter gameObject: The GameObject to add to the scene.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let scene = Scene(allocation: .singleton)
    /// let player = GameObject(name: "Player")
    /// scene.addGameObject(player)
    ///
    /// // Player is now part of the scene hierarchy
    /// print("Player added to scene: \(player.scene === scene)")  // true
    /// ```
    public func addGameObject(_ gameObject: GameObject) {
        gameObject.addToScene(self)
        if self.shadowCastingAllowed == false {
            gameObject.node.castsShadow = false
        }
    }

    /// Finds the first ``GameObject`` matching the specified search criteria.
    ///
    /// Searches the scene hierarchy for a GameObject that matches the given search type.
    /// This is a convenience method that calls ``GameObject/find(_:in:)``.
    ///
    /// - Parameter type: The search criteria to match (by name, tag, component, etc.).
    /// - Returns: The first matching GameObject, or `nil` if none is found.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Find by tag
    /// if let mainCamera = scene.find(.mainCamera) {
    ///     print("Found main camera")
    /// }
    ///
    /// // Find by name
    /// if let player = scene.find(.name("Player")) {
    ///     player.transform.position = Vector3.zero
    /// }
    /// ```
    public func find(_ type: GameObject.SearchType) -> GameObject? {
        return GameObject.find(type, in: self)
    }

    /// Finds all GameObjects matching the specified search criteria.
    ///
    /// Searches the scene hierarchy for all GameObjects that match the given search type.
    /// This is a convenience method that calls ``GameObject/findGameObjects(_:in:)``.
    ///
    /// - Parameter type: The search criteria to match (by name, tag, component, etc.).
    /// - Returns: An array of all matching GameObjects, or an empty array if none are found.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Find all objects with a specific tag
    /// let enemies = scene.findGameObjects(.tag(.enemy))
    /// enemies.forEach { enemy in
    ///     enemy.destroy()
    /// }
    ///
    /// // Find all objects with a Rigidbody component
    /// let physicsObjects = scene.findGameObjects(.component(Rigidbody.self))
    /// print("Found \(physicsObjects.count) physics objects")
    /// ```
    public func findGameObjects(_ type: GameObject.SearchType) -> [GameObject] {
        return GameObject.findGameObjects(type, in: self)
    }
}

// Debug
extension Scene {
    public func printGameObjectsIgnoreUpdates() {
        self.gameObjectCount = 0
        self.ignoreUpdatesCount = 0
        self.printGameObjectsIgnoreUpdates(for: self.rootGameObject)
        Debug.info("ignoreUpdates count: \(self.ignoreUpdatesCount) / \(self.gameObjectCount)")
    }

    private func printGameObjectsIgnoreUpdates(for gameObject: GameObject) {
        for getChild in gameObject.getChildren() {
            self.gameObjectCount += 1
            if getChild.ignoreUpdates {
                self.ignoreUpdatesCount += 1
            }
            Debug.info("\(getChild.name ?? "No name") -> ignoreUpdates: \(getChild.ignoreUpdates)")
            self.printGameObjectsIgnoreUpdates(for: getChild)
        }
    }
}
