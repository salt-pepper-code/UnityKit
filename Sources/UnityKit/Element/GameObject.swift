import Foundation
import SceneKit

/// A fundamental class representing interactive objects in a UnityKit scene.
///
/// ``GameObject`` is the base class for all entities in UnityKit scenes. GameObjects are containers that
/// can hold components which define their behavior and appearance. They exist in a hierarchical structure
/// where GameObjects can have parent-child relationships.
///
/// ## Overview
///
/// Every object in your scene is a GameObject, from cameras and lights to 3D models and UI elements.
/// GameObjects don't do much by themselves - they need ``Component``s to give them functionality.
/// For example:
/// - Add a ``Transform`` component to position the GameObject in 3D space (added automatically)
/// - Add a ``Renderer`` component to make it visible (added automatically when geometry is present)
/// - Add a ``Camera`` component to view the scene through it
/// - Add custom ``MonoBehaviour`` components to define custom behavior
///
/// ## Topics
///
/// ### Creating GameObjects
///
/// - ``init()``
/// - ``init(name:)``
/// - ``init(_:)``
/// - ``init(fileName:nodeName:bundle:)``
/// - ``init(modelPath:nodeName:bundle:)``
/// - ``init(modelUrl:nodeName:)``
/// - ``instantiate()``
///
/// ### Managing Components
///
/// - ``addComponent(_:)-5v71v``
/// - ``getComponent(_:)``
/// - ``getComponents(_:)``
/// - ``getComponentInChild(_:)``
/// - ``getComponentsInChild(_:)``
/// - ``removeComponent(_:)``
/// - ``removeComponentsOfType(_:)``
///
/// ### Managing the Hierarchy
///
/// - ``parent``
/// - ``children``
/// - ``scene``
/// - ``addChild(_:)``
/// - ``removeChild(_:)``
/// - ``getChildren()``
/// - ``getChild(_:)``
/// - ``removeFromParent()``
/// - ``addToScene(_:)``
///
/// ### Searching for GameObjects
///
/// - ``SearchType``
/// - ``find(_:in:)-type.method``
/// - ``find(_:in:)-5oqm4``
/// - ``findGameObjects(_:in:)-type.method``
/// - ``findGameObjects(_:in:)-72bi7``
///
/// ### Accessing Properties
///
/// - ``name``
/// - ``tag``
/// - ``layer``
/// - ``transform``
/// - ``renderer``
/// - ``node``
///
/// ### Managing Active State
///
/// - ``activeSelf``
/// - ``activeInHierarchy``
/// - ``enabled``
/// - ``setActive(_:)``
///
/// ### Lifecycle Methods
///
/// - ``awake()``
/// - ``start()``
/// - ``update()``
/// - ``preUpdate()``
/// - ``fixedUpdate()``
///
/// ### Bounds and Geometry
///
/// - ``boundingBox``
/// - ``boundingSphere``
///
/// ### Performance Optimization
///
/// - ``ignoreUpdates``
///
/// ## Example Usage
///
/// ```swift
/// // Create a new GameObject
/// let player = GameObject(name: "Player")
///
/// // Add it to a scene
/// player.addToScene(myScene)
///
/// // Add components
/// let meshFilter = player.addComponent(MeshFilter.self)
/// let customBehavior = player.addComponent(PlayerController.self)
///
/// // Organize in hierarchy
/// let weapon = GameObject(name: "Weapon")
/// player.addChild(weapon)
///
/// // Find GameObjects
/// if let enemy = GameObject.find(.tag(.custom("Enemy")), in: myScene) {
///     // Do something with enemy
/// }
/// ```
public class GameObject: Object {
    var task: DispatchWorkItem?

    /// The name of the GameObject.
    ///
    /// When set, automatically updates the underlying SceneKit node's name.
    /// Useful for identifying and searching for GameObjects in the scene hierarchy.
    ///
    /// ```swift
    /// let player = GameObject()
    /// player.name = "Player"
    ///
    /// // Find by name later
    /// if let found = GameObject.find(.name(.exact("Player")), in: scene) {
    ///     print("Found player!")
    /// }
    /// ```
    override public var name: String? {
        didSet {
            self.node.name = self.name
        }
    }

    /// The layer that this GameObject belongs to.
    ///
    /// Layers are used to organize GameObjects and control rendering, physics interactions,
    /// and other scene operations. When you set a GameObject's layer, all its children
    /// automatically inherit that layer unless they have a camera or light component.
    ///
    /// - Note: GameObjects with cameras or lights cannot have their layer changed.
    ///
    /// ```swift
    /// gameObject.layer = .player
    ///
    /// // Find all objects in a layer
    /// let enemies = GameObject.findGameObjects(.layer(.custom("Enemy")), in: scene)
    /// ```
    ///
    /// - SeeAlso: ``Layer``
    public var layer: Layer {
        get {
            return Layer(rawValue: self.node.categoryBitMask)
        }
        set {
            guard self.node.camera == nil,
                  self.node.light == nil
            else { return }

            self.node.categoryBitMask = newValue.rawValue
            let childrenCopy = self.children // Thread-safe read
            childrenCopy.forEach { $0.layer = newValue }
        }
    }

    /// The tag that identifies this GameObject.
    ///
    /// Tags are used to quickly identify GameObjects. You can use built-in tags like
    /// ``Tag/mainCamera`` or create custom tags using ``Tag/custom(_:)``.
    ///
    /// ```swift
    /// gameObject.tag = .mainCamera
    ///
    /// // Find by tag
    /// let camera = GameObject.find(.tag(.mainCamera), in: scene)
    /// ```
    ///
    /// - SeeAlso: ``Tag``
    public var tag: Tag = .untagged

    /// The underlying SceneKit node.
    ///
    /// This is the SCNNode that represents this GameObject in SceneKit's scene graph.
    /// Direct manipulation of the node is possible but should be done carefully to avoid
    /// breaking GameObject's internal state management.
    ///
    /// - Warning: Modifying the node directly may bypass GameObject's hierarchy and state management.
    public var node: SCNNode

    /// Specifies whether update calls should be cascaded to this GameObject and its children.
    ///
    /// When `true`, this GameObject and its children will not receive `update()`, `preUpdate()`,
    /// or `fixedUpdate()` calls, significantly improving performance for static objects.
    ///
    /// - Important: When set to `false`, automatically sets the parent's `ignoreUpdates` to `false`
    ///   to ensure update calls propagate down the hierarchy.
    ///
    /// ```swift
    /// // Optimize static objects
    /// staticBackground.ignoreUpdates = true
    ///
    /// // Make dynamic when needed
    /// movingPlatform.ignoreUpdates = false
    /// ```
    public var ignoreUpdates = true {
        didSet {
            if !self.ignoreUpdates {
                self.parent?.ignoreUpdates = false
            }
        }
    }

    /// The Transform component attached to this GameObject.
    ///
    /// Every GameObject has a Transform component that controls its position, rotation, and scale in 3D space.
    /// This component is automatically added during initialization and cannot be removed.
    ///
    /// ```swift
    /// gameObject.transform.position = Vector3(0, 5, 0)
    /// gameObject.transform.rotation = Quaternion(angle: .pi / 4, axis: Vector3(0, 1, 0))
    /// gameObject.transform.scale = Vector3(2, 2, 2)
    /// ```
    ///
    /// - SeeAlso: ``Transform``
    public private(set) var transform: Transform!

    /// The Renderer component attached to this GameObject, if any.
    ///
    /// A Renderer is automatically added when the GameObject is created with geometry.
    /// It controls how the GameObject is rendered in the scene, including materials and visibility.
    ///
    /// - Note: This will be `nil` for GameObjects without visual representation.
    ///
    /// - SeeAlso: ``Renderer``
    public private(set) var renderer: Renderer?

    private var _children = [GameObject]()
    private let childrenQueue = DispatchQueue(
        label: "com.unitykit.gameobject.children",
        qos: .userInitiated,
        attributes: .concurrent
    )

    /// The child GameObjects of this GameObject.
    ///
    /// This property provides thread-safe access to the GameObject's children.
    /// Use ``addChild(_:)`` and ``removeChild(_:)`` to modify the hierarchy.
    ///
    /// - Note: Direct modification of this property is not recommended. Use the hierarchy management methods instead.
    var children: [GameObject] {
        get {
            self.childrenQueue.sync { self._children }
        }
        set {
            self.childrenQueue.sync(flags: .barrier) { [weak self] in
                self?._children = newValue
            }
        }
    }

    /// The parent GameObject in the hierarchy.
    ///
    /// This property is automatically set when using ``addChild(_:)`` or ``addToScene(_:)``.
    /// A GameObject can only have one parent at a time.
    ///
    /// ```swift
    /// if let parent = gameObject.parent {
    ///     print("Parent is: \(parent.name ?? "unnamed")")
    /// }
    /// ```
    public private(set) weak var parent: GameObject?

    /// The scene this GameObject belongs to.
    ///
    /// This property is automatically set when the GameObject is added to a scene.
    /// When the scene changes, ``movedToScene()`` is called on all components.
    ///
    /// - SeeAlso: ``addToScene(_:)``
    public private(set) weak var scene: Scene? {
        didSet {
            guard oldValue != self.scene
            else { return }

            if let parent, let rootGameObject = oldValue?.rootGameObject, parent == rootGameObject {
                self.scene?.rootGameObject.addChild(self)
            }

            self.movedToScene()
        }
    }

    private var didAwake: Bool = false
    private var didStart: Bool = false
    private var waitNextUpdate: Bool = true {
        didSet {
            let childrenCopy = self.children // Thread-safe read
            childrenCopy.forEach { $0.waitNextUpdate = self.waitNextUpdate }
        }
    }

    /// Whether this GameObject is active in the scene hierarchy.
    ///
    /// A GameObject is considered active in hierarchy if both it and all its ancestors are active.
    /// This is a read-only property that reflects the GameObject's effective active state.
    ///
    /// ```swift
    /// if gameObject.activeInHierarchy {
    ///     // GameObject and all parents are active
    ///     // This GameObject will receive updates
    /// }
    /// ```
    ///
    /// - SeeAlso: ``activeSelf``, ``setActive(_:)``
    public var activeInHierarchy: Bool {
        if let parent {
            return self.activeSelf && parent.activeInHierarchy
        }
        return self.activeSelf
    }

    /// The local active state of this GameObject.
    ///
    /// This indicates whether the GameObject itself is active, regardless of its parent's state.
    /// When set to `false`, the GameObject and all its children stop receiving updates and become hidden.
    /// Setting it to `true` enables/disables all ``Behaviour`` components on this GameObject.
    ///
    /// - Note: Use ``setActive(_:)`` to modify this value.
    ///
    /// - SeeAlso: ``activeInHierarchy``, ``setActive(_:)``
    public private(set) var activeSelf: Bool {
        get {
            return !self.node.isHidden
        }
        set {
            self.node.isHidden = !newValue

            for component in components {
                guard let behaviour = component as? Behaviour
                else { continue }

                behaviour.enabled = newValue
            }
        }
    }

    /// Alias for ``activeSelf``.
    ///
    /// Provides a convenient property name for enabling/disabling GameObjects.
    ///
    /// - SeeAlso: ``activeSelf``, ``setActive(_:)``
    public var enabled: Bool {
        get {
            return self.activeSelf
        }
        set {
            self.activeSelf = newValue
        }
    }

    /// The axis-aligned bounding box of this GameObject.
    ///
    /// Returns the minimum and maximum points that define a box containing the GameObject's geometry.
    /// Useful for collision detection, frustum culling, and spatial calculations.
    ///
    /// ```swift
    /// let bbox = gameObject.boundingBox
    /// let size = bbox.max - bbox.min
    /// print("Object dimensions: \(size)")
    /// ```
    public var boundingBox: BoundingBox {
        return self.node.boundingBox
    }

    /// The bounding sphere of this GameObject.
    ///
    /// Returns the center point and radius of a sphere that contains the GameObject's geometry.
    /// Often more efficient than bounding boxes for certain calculations.
    ///
    /// ```swift
    /// let sphere = gameObject.boundingSphere
    /// print("Radius: \(sphere.radius)")
    /// ```
    public var boundingSphere: BoundingSphere {
        return self.node.boundingSphere
    }

    /// Creates a GameObject from a model file by searching for it in the bundle.
    ///
    /// This convenience initializer searches for a model file and optionally extracts a specific node from it.
    ///
    /// - Parameters:
    ///   - fileName: The name of the model file to load (without extension)
    ///   - nodeName: Optional name of a specific node to extract from the model. If `nil`, uses the root node
    ///   - bundle: The bundle to search in. Defaults to the main bundle
    ///
    /// - Returns: A new GameObject instance, or `nil` if the file or node cannot be found
    ///
    /// ```swift
    /// if let player = GameObject(fileName: "character", nodeName: "PlayerMesh") {
    ///     scene.addChild(player)
    /// }
    /// ```
    public convenience init?(
        fileName: String,
        nodeName: String?,
        bundle: Bundle = Bundle.main
    ) {
        guard let modelUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
        else { return nil }

        self.init(modelUrl: modelUrl, nodeName: nodeName)
    }

    /// Creates a GameObject from a model file at a specific path.
    ///
    /// - Parameters:
    ///   - modelPath: The resource path to the model file
    ///   - nodeName: Optional name of a specific node to extract from the model. If `nil`, uses the root node
    ///   - bundle: The bundle containing the model. Defaults to the main bundle
    ///
    /// - Returns: A new GameObject instance, or `nil` if the file or node cannot be found
    ///
    /// ```swift
    /// if let prop = GameObject(modelPath: "Models/tree.scn", nodeName: nil) {
    ///     scene.addChild(prop)
    /// }
    /// ```
    public convenience init?(
        modelPath: String,
        nodeName: String?,
        bundle: Bundle = Bundle.main
    ) {
        guard let modelUrl = bundle.url(forResource: modelPath, withExtension: nil)
        else { return nil }

        self.init(modelUrl: modelUrl, nodeName: nodeName)
    }

    /// Creates a GameObject from a model file URL.
    ///
    /// Loads a SceneKit reference node from the specified URL and optionally extracts a specific child node.
    ///
    /// - Parameters:
    ///   - modelUrl: The URL to the model file
    ///   - nodeName: Optional name of a specific node to extract. If `nil`, uses the entire reference node
    ///
    /// - Returns: A new GameObject instance, or `nil` if the model cannot be loaded or the node is not found
    ///
    /// ```swift
    /// let modelURL = Bundle.main.url(forResource: "vehicle", withExtension: "scn")!
    /// if let car = GameObject(modelUrl: modelURL, nodeName: "CarBody") {
    ///     scene.addChild(car)
    /// }
    /// ```
    public convenience init?(modelUrl: URL, nodeName: String?) {
        guard let referenceNode = SCNReferenceNode(url: modelUrl)
        else { return nil }

        referenceNode.load()

        if let nodeName {
            guard let node = referenceNode.childNodes.filter({ $0.name == nodeName }).first
            else { return nil }

            self.init(node)
        } else {
            self.init(referenceNode)
        }
    }

    /// Creates a GameObject with a specified name.
    ///
    /// This is the most common way to create a new GameObject. The GameObject will have no geometry
    /// but will have a ``Transform`` component automatically attached.
    ///
    /// - Parameter name: The name for the GameObject
    ///
    /// ```swift
    /// let container = GameObject(name: "Container")
    /// let player = GameObject(name: "Player")
    /// container.addChild(player)
    /// ```
    public convenience init(name: String) {
        let node = SCNNode()
        node.name = name
        self.init(node)
    }

    /// Creates a GameObject from an existing SceneKit node.
    ///
    /// This initializer wraps an existing `SCNNode` in a GameObject, automatically:
    /// - Adding a ``Transform`` component
    /// - Adding a ``MeshFilter`` and ``Renderer`` if geometry is present
    /// - Adding a ``Camera`` component if a camera is attached
    /// - Adding a ``Light`` component if a light is attached
    /// - Converting all child nodes to GameObjects
    ///
    /// - Parameter node: The SceneKit node to wrap
    ///
    /// ```swift
    /// let scnNode = SCNNode()
    /// scnNode.geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
    /// let cube = GameObject(scnNode)
    /// ```
    public init(_ node: SCNNode) {
        self.node = node
        super.init()
        self.initialize()
        Debug.debug("GameObject[\(self.name ?? "unnamed")].init(_:)")
        self.awake()
    }

    func initialize() {
        self.name = self.node.name ?? "No name"
        self.layer = .default
        self.transform = self.addComponent(external: false, type: Transform.self)

        if let geometry = node.geometry {
            let meshFilter = self.addComponent(external: false, type: MeshFilter.self)
            meshFilter.mesh = Mesh(geometry)

            self.renderer = self.addComponent(external: false, type: Renderer.self)

            self.renderer?.materials = geometry.materials.map { Material($0) }
        }

        if let camera = node.camera {
            self.addComponent(external: false, type: Camera.self).scnCamera = camera
        }

        if let light = node.light {
            self.addComponent(external: false, type: Light.self).scnLight = light
        }

        GameObject.convertAllChildToGameObjects(self)
    }

    /// Creates an empty GameObject.
    ///
    /// This is the default initializer that creates a GameObject with:
    /// - An empty SceneKit node
    /// - A ``Transform`` component
    /// - No geometry or visual representation
    ///
    /// ```swift
    /// let empty = GameObject()
    /// empty.name = "Container"
    /// ```
    public required init() {
        self.node = SCNNode()
        super.init()
        self.transform = self.addComponent(external: false, type: Transform.self)
        Debug.debug("GameObject[\(self.name ?? "unnamed")].init()")
        self.awake()
    }

    /// Destroys this GameObject, removing it from its parent.
    ///
    /// This method cleans up the GameObject by calling the base `destroy()` implementation
    /// and removing it from its parent in the hierarchy.
    ///
    /// ```swift
    /// gameObject.destroy()
    /// ```
    ///
    /// - Note: After destruction, the GameObject should not be used.
    override public func destroy() {
        super.destroy()
        self.parent?.removeChild(self)
    }

    /// Creates a deep copy of this GameObject.
    ///
    /// This method clones the GameObject including:
    /// - Its SceneKit node and all child nodes
    /// - Its tag and layer settings
    /// - All ``Instantiable`` components (components that conform to the Instantiable protocol)
    ///
    /// The cloned GameObject will have " Clone" appended to its name.
    ///
    /// - Returns: A new GameObject instance that is a copy of this one
    ///
    /// ```swift
    /// let original = GameObject(name: "Enemy")
    /// let copy = original.instantiate()
    /// print(copy.name) // "Enemy Clone"
    /// ```
    ///
    /// - Note: Only components that conform to the `Instantiable` protocol will be copied.
    public func instantiate() -> GameObject {
        let cloneNode = self.node.deepClone()
        let clone = GameObject(cloneNode)

        if let name {
            clone.name = "\(name) Clone"
        }

        clone.tag = self.tag
        clone.layer = self.layer

        for item in components {
            if let component = item as? Component & Instantiable {
                clone.addComponent(component.instantiate(gameObject: clone), gameObject: clone)
            }
        }
        return clone
    }

    func shouldIgnoreUpdates() -> Bool {
        return components.first(where: { !$0.ignoreUpdates }) == nil
    }

    func setScene(_ scene: Scene) {
        self.scene = scene
        let childrenCopy = self.children // Thread-safe read
        childrenCopy.forEach { $0.setScene(scene) }
    }

    override func movedToScene() {
        components.forEach { $0.movedToScene() }
    }

    /// Sets the active state of this GameObject.
    ///
    /// This is the primary method for enabling or disabling a GameObject. When set to `false`,
    /// the GameObject stops receiving updates and becomes hidden. All ``Behaviour`` components
    /// are also disabled.
    ///
    /// - Parameter active: `true` to activate, `false` to deactivate
    ///
    /// ```swift
    /// // Hide and disable an object
    /// gameObject.setActive(false)
    ///
    /// // Show and enable it later
    /// gameObject.setActive(true)
    /// ```
    ///
    /// - SeeAlso: ``activeSelf``, ``activeInHierarchy``
    public func setActive(_ active: Bool) {
        self.activeSelf = active
    }

    // MARK: - Lifecycle Methods

    /// Called when the GameObject is first initialized.
    ///
    /// This method is called once when the GameObject is created, before ``start()``.
    /// It's used to initialize components and set up initial state. The `awake()` call
    /// cascades to all components and children.
    ///
    /// ```swift
    /// class MyBehavior: MonoBehaviour {
    ///     override func awake() {
    ///         super.awake()
    ///         // Initialize components, get references, etc.
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This method is called automatically. You typically override it in custom ``MonoBehaviour`` classes.
    ///
    /// - SeeAlso: ``start()``, ``update()``
    override public func awake() {
        guard !self.didAwake
        else { return }

        self.didAwake = true
        components.forEach { $0.awake() }
        let childrenCopy = self.children // Thread-safe read
        childrenCopy.forEach { $0.awake() }
    }

    /// Called before the first frame update, after ``awake()``.
    ///
    /// This method is called once, after `awake()` and before the first `update()` call,
    /// but only if the GameObject is active. It's used for initialization that depends on
    /// other objects being awake and ready.
    ///
    /// ```swift
    /// class MyBehavior: MonoBehaviour {
    ///     var target: GameObject?
    ///
    ///     override func start() {
    ///         super.start()
    ///         // Find references to other objects
    ///         target = GameObject.find(.tag(.custom("Target")), in: scene)
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This method is called automatically. Override it in custom ``MonoBehaviour`` classes for setup logic.
    ///
    /// - SeeAlso: ``awake()``, ``update()``
    override public func start() {
        guard self.didAwake,
              !self.didStart,
              self.activeSelf
        else { return }

        guard !self.waitNextUpdate else {
            self.waitNextUpdate = false
            return
        }

        self.didStart = true
        components.forEach { $0.start() }
        let childrenCopy = self.children // Thread-safe read
        childrenCopy.forEach { $0.start() }
        self.setActive(true)
    }

    override func internalUpdate() {
        guard self.didAwake,
              self.didStart,
              self.activeSelf
        else { return }

        components
            .compactMap { $0 as? MonoBehaviour }
            .filter(\.enabled)
            .forEach { $0.internalUpdate() }

        let childrenCopy = self.children // Thread-safe read
        childrenCopy
            .filter { !$0.ignoreUpdates }
            .forEach { $0.internalUpdate() }
    }

    /// Called before the regular update cycle.
    ///
    /// This method is called every frame before ``update()``, but only if the GameObject is active
    /// and has started. It's used for operations that need to happen before the main update logic.
    ///
    /// - Note: Only components that implement `preUpdate()` and are enabled will receive this call.
    ///
    /// ```swift
    /// class MyBehavior: MonoBehaviour {
    ///     override func preUpdate() {
    ///         // Prepare state before update
    ///     }
    /// }
    /// ```
    ///
    /// - SeeAlso: ``update()``, ``fixedUpdate()``
    override public func preUpdate() {
        guard self.didAwake,
              self.didStart,
              self.activeSelf
        else { return }

        components
            .filter {
                if !$0.implementsPreUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.preUpdate() }

        let childrenCopy = self.children // Thread-safe read
        childrenCopy
            .filter { !$0.ignoreUpdates }
            .forEach { $0.preUpdate() }
    }

    /// Called once per frame.
    ///
    /// This is the main update method called every frame for active GameObjects. Use this for
    /// frame-by-frame logic like moving objects, checking input, or updating state.
    ///
    /// The update cascades to all enabled components and children that don't have ``ignoreUpdates`` set.
    ///
    /// ```swift
    /// class PlayerController: MonoBehaviour {
    ///     override func update() {
    ///         // Handle input, move player, etc.
    ///         let movement = Input.getAxis("Horizontal")
    ///         gameObject.transform.position.x += movement * Time.deltaTime
    ///     }
    /// }
    /// ```
    ///
    /// - Note: For physics-related updates, use ``fixedUpdate()`` instead.
    ///
    /// - SeeAlso: ``preUpdate()``, ``fixedUpdate()``, ``start()``
    override public func update() {
        guard self.didAwake,
              self.activeSelf
        else { return }

        guard self.didStart else {
            self.start()
            return
        }

        let filtered = components
            .filter {
                if !$0.implementsUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
        
        filtered
            .forEach { $0.update() }

        let childrenCopy = self.children // Thread-safe read
        let childrenFiltered = childrenCopy
            .filter { !$0.ignoreUpdates || !$0.didStart }
        
        childrenFiltered
            .forEach { $0.update() }
    }

    /// Called at fixed intervals for physics and time-based updates.
    ///
    /// This method is called at a fixed rate (usually 50 times per second) regardless of frame rate,
    /// making it ideal for physics calculations and other operations that need consistent timing.
    ///
    /// ```swift
    /// class PhysicsObject: MonoBehaviour {
    ///     override func fixedUpdate() {
    ///         // Apply physics forces
    ///         let force = Vector3(0, -9.8, 0) * Time.fixedDeltaTime
    ///         gameObject.transform.position += force
    ///     }
    /// }
    /// ```
    ///
    /// - Note: Use this instead of ``update()`` for physics-related code to ensure consistent behavior.
    ///
    /// - SeeAlso: ``update()``, ``preUpdate()``
    override public func fixedUpdate() {
        guard self.didAwake,
              self.didStart,
              self.activeSelf
        else { return }

        components
            .filter {
                if !$0.implementsFixedUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.fixedUpdate() }

        let childrenCopy = self.children // Thread-safe read
        childrenCopy
            .filter { !$0.ignoreUpdates }
            .forEach { $0.fixedUpdate() }
    }

    /// Removes this GameObject from its parent.
    ///
    /// This method detaches the GameObject from its parent in the hierarchy without destroying it.
    /// The GameObject can be re-added to another parent later.
    ///
    /// ```swift
    /// gameObject.removeFromParent()
    /// otherParent.addChild(gameObject)
    /// ```
    ///
    /// - SeeAlso: ``addChild(_:)``, ``removeChild(_:)``
    public func removeFromParent() {
        self.parent?.removeChild(self)
    }

    // MARK: - Component Management

    @discardableResult override func addComponent<T: Component>(
        _ component: T,
        gameObject: GameObject?
    ) -> T {
        let result = super.addComponent(component, gameObject: gameObject)

        // If GameObject has already started, call start() on the new component
        if self.didStart, self.activeSelf {
            component.start()
        }

        return result
    }

    /// Adds a component of the specified type to this GameObject.
    ///
    /// This is the primary method for adding components to a GameObject. The component is
    /// created and attached, and if the GameObject has already started, the component's
    /// `start()` method is called immediately.
    ///
    /// - Parameter type: The type of component to add (e.g., `Rigidbody.self`)
    ///
    /// - Returns: The newly created component instance
    ///
    /// ```swift
    /// let rigidbody = gameObject.addComponent(Rigidbody.self)
    /// rigidbody.mass = 2.0
    ///
    /// let customScript = gameObject.addComponent(PlayerController.self)
    /// ```
    ///
    /// - Note: Automatically updates ``ignoreUpdates`` based on whether components need updates.
    ///
    /// - SeeAlso: ``getComponent(_:)``, ``removeComponent(_:)``
    @discardableResult override public func addComponent<T: Component>(_ type: T.Type) -> T {
        let component = super.addComponent(external: true, type: type, gameObject: self)
        self.ignoreUpdates = self.shouldIgnoreUpdates()
        return component
    }

    @discardableResult override func addComponent<T: Component>(
        external: Bool = true,
        type: T.Type,
        gameObject: GameObject? = nil
    ) -> T {
        return super.addComponent(external: external, type: type, gameObject: gameObject ?? self)
    }

    /// Finds a component of the specified type in this GameObject's children.
    ///
    /// Searches through the immediate children first, then recursively searches deeper children
    /// until a component of the specified type is found.
    ///
    /// - Parameter type: The type of component to find
    ///
    /// - Returns: The first component found, or `nil` if none exists
    ///
    /// ```swift
    /// // Find a Camera in any child
    /// if let camera = gameObject.getComponentInChild(Camera.self) {
    ///     print("Found camera in child: \(camera.gameObject.name)")
    /// }
    /// ```
    ///
    /// - SeeAlso: ``getComponent(_:)``, ``getComponentsInChild(_:)``
    public func getComponentInChild<T: Component>(_ type: T.Type) -> T? {
        for child in self.children {
            if let component = child.getComponent(type) {
                return component
            }
        }
        for child in self.children {
            if let component = child.getComponentInChild(type) {
                return component
            }
        }
        return nil
    }

    /// Finds all components of the specified type in this GameObject's children.
    ///
    /// Recursively searches through all children and returns all components of the specified type.
    ///
    /// - Parameter type: The type of component to find
    ///
    /// - Returns: An array of all matching components found in children
    ///
    /// ```swift
    /// // Get all Renderer components in children
    /// let renderers = gameObject.getComponentsInChild(Renderer.self)
    /// renderers.forEach { $0.enabled = false }
    /// ```
    ///
    /// - SeeAlso: ``getComponents(_:)``, ``getComponentInChild(_:)``
    public func getComponentsInChild<T: Component>(_ type: T.Type) -> [T] {
        return self.children.flatMap { child -> [T] in
            child.getComponents(type) + child.getComponentsInChild(type)
        }
    }

    // MARK: - Hierarchy Management

    /// Adds this GameObject to a scene.
    ///
    /// This method adds the GameObject to the specified scene's root GameObject and sets
    /// the scene reference. All children will also have their scene set.
    ///
    /// - Parameter scene: The scene to add this GameObject to
    ///
    /// ```swift
    /// let newObject = GameObject(name: "WorldObject")
    /// newObject.addToScene(myScene)
    /// ```
    ///
    /// - SeeAlso: ``scene``, ``addChild(_:)``
    public func addToScene(_ scene: Scene) {
        self.setScene(scene)
        self.parent = scene.rootGameObject

        scene.rootGameObject.addChild(self)
    }

    /// Adds a child GameObject to this GameObject's hierarchy.
    ///
    /// This method establishes a parent-child relationship. The child's scene is set to match
    /// the parent's scene, and its transform becomes relative to the parent's transform.
    ///
    /// - Parameter child: The GameObject to add as a child
    ///
    /// ```swift
    /// let parent = GameObject(name: "Parent")
    /// let child = GameObject(name: "Child")
    /// parent.addChild(child)
    ///
    /// // Child's position is now relative to parent
    /// child.transform.position = Vector3(0, 1, 0)
    /// ```
    ///
    /// - Note: If the child requires updates, the parent's ``ignoreUpdates`` is automatically set to `false`.
    ///
    /// - SeeAlso: ``removeChild(_:)``, ``getChildren()``, ``parent``
    public func addChild(_ child: GameObject) {
        if let scene {
            child.setScene(scene)
        }
        child.parent = self
        if !child.ignoreUpdates {
            self.ignoreUpdates = false
        }

        self.childrenQueue.sync(flags: .barrier) {
            if self._children.first(where: { $0 == child }) == nil {
                self._children.append(child)
            }
        }

        if child.node.parent != self.node {
            self.node.addChildNode(child.node)
        }
    }

    /// Returns all child GameObjects.
    ///
    /// This method provides thread-safe access to the children array.
    ///
    /// - Returns: An array of all child GameObjects
    ///
    /// ```swift
    /// let children = gameObject.getChildren()
    /// for child in children {
    ///     print(child.name ?? "unnamed")
    /// }
    /// ```
    ///
    /// - SeeAlso: ``getChild(_:)``, ``addChild(_:)``
    public func getChildren() -> [GameObject] {
        return self.childrenQueue.sync { self._children }
    }

    func getChildNodes() -> [SCNNode] {
        return self.node.childNodes
    }

    /// Gets a child GameObject by index.
    ///
    /// - Parameter index: The index of the child to retrieve
    ///
    /// - Returns: The child GameObject at the specified index, or `nil` if the index is out of bounds
    ///
    /// ```swift
    /// if let firstChild = gameObject.getChild(0) {
    ///     print("First child: \(firstChild.name ?? "unnamed")")
    /// }
    /// ```
    ///
    /// - SeeAlso: ``getChildren()``, ``addChild(_:)``
    public func getChild(_ index: Int) -> GameObject? {
        return self.childrenQueue.sync {
            guard index < self._children.count else { return nil }
            return self._children[index]
        }
    }

    /// Removes a child GameObject from this GameObject's hierarchy.
    ///
    /// This method breaks the parent-child relationship and removes the child's SceneKit node
    /// from the parent's node. The child GameObject is not destroyed and can be re-added elsewhere.
    ///
    /// - Parameter child: The child GameObject to remove
    ///
    /// ```swift
    /// parent.removeChild(childObject)
    /// // childObject still exists but is no longer in the hierarchy
    /// ```
    ///
    /// - SeeAlso: ``addChild(_:)``, ``removeFromParent()``
    public func removeChild(_ child: GameObject) {
        self.childrenQueue.sync(flags: .barrier) {
            if let index = _children.firstIndex(where: { $0 == child }) {
                let gameObject = self._children[index]
                gameObject.node.removeFromParentNode()
                self._children.remove(at: index)
            }
        }
    }
}
