public extension GameObject {
    /// A type that identifies GameObjects for categorization and quick lookup.
    ///
    /// Tags provide a way to mark and identify GameObjects without having to reference them directly.
    /// They are commonly used for identifying specific GameObjects in your scene, such as the main camera,
    /// player character, or other important objects that need to be found at runtime.
    ///
    /// ## Topics
    ///
    /// ### Predefined Tags
    /// - ``untagged``
    /// - ``mainCamera``
    ///
    /// ### Custom Tags
    /// - ``custom(_:)``
    ///
    /// ### Tag Properties
    /// - ``name``
    ///
    /// ## Example Usage
    ///
    /// ### Finding GameObjects by Tag
    /// ```swift
    /// // Find the main camera in the scene
    /// if let camera = scene.findGameObject(tag: .mainCamera) {
    ///     print("Found main camera: \(camera.name)")
    /// }
    ///
    /// // Find all objects with a custom tag
    /// let enemies = scene.findGameObjects(tag: .custom("Enemy"))
    /// print("Found \(enemies.count) enemies")
    /// ```
    ///
    /// ### Assigning Tags to GameObjects
    /// ```swift
    /// // Create a GameObject with a predefined tag
    /// let camera = GameObject(name: "Main Camera")
    /// camera.tag = .mainCamera
    ///
    /// // Create a GameObject with a custom tag
    /// let enemy = GameObject(name: "Zombie")
    /// enemy.tag = .custom("Enemy")
    /// ```
    ///
    /// ### Comparing Tags
    /// ```swift
    /// if gameObject.tag == .mainCamera {
    ///     print("This is the main camera")
    /// }
    ///
    /// // Check for custom tags
    /// if case .custom(let tagName) = gameObject.tag, tagName == "Enemy" {
    ///     print("Found an enemy!")
    /// }
    /// ```
    enum Tag: Hashable {
        /// The default tag for GameObjects that haven't been assigned a specific tag.
        ///
        /// All GameObjects are created with the `.untagged` tag by default unless explicitly assigned another tag.
        case untagged

        /// A predefined tag typically used to identify the primary camera in the scene.
        ///
        /// This tag is conventionally used to mark the main camera GameObject, making it easy to find
        /// and reference the primary camera for rendering operations.
        ///
        /// ## Example
        /// ```swift
        /// let mainCamera = GameObject(name: "Main Camera")
        /// mainCamera.tag = .mainCamera
        ///
        /// // Later, find the main camera
        /// if let camera = scene.findGameObject(tag: .mainCamera) {
        ///     // Configure camera settings
        ///     camera.transform.position = Vector3(0, 10, -10)
        /// }
        /// ```
        case mainCamera

        /// A custom tag with a user-defined name for specialized GameObject identification.
        ///
        /// Use custom tags to create your own categorization system for GameObjects. Custom tags are useful
        /// for identifying groups of objects like enemies, collectibles, obstacles, or any other game-specific categories.
        ///
        /// - Parameter name: The custom name for this tag.
        ///
        /// ## Example
        /// ```swift
        /// // Tag enemies for easy identification
        /// let zombie = GameObject(name: "Zombie")
        /// zombie.tag = .custom("Enemy")
        ///
        /// let skeleton = GameObject(name: "Skeleton")
        /// skeleton.tag = .custom("Enemy")
        ///
        /// // Tag collectible items
        /// let coin = GameObject(name: "Coin")
        /// coin.tag = .custom("Collectible")
        ///
        /// // Find all enemies in the scene
        /// let enemies = scene.findGameObjects(tag: .custom("Enemy"))
        /// for enemy in enemies {
        ///     // Apply damage or trigger AI behavior
        /// }
        /// ```
        case custom(String)

        /// The string representation of the tag.
        ///
        /// Returns the human-readable name of the tag:
        /// - `.untagged` returns `"Untagged"`
        /// - `.mainCamera` returns `"MainCamera"`
        /// - `.custom(name)` returns the custom name
        ///
        /// ## Example
        /// ```swift
        /// let tag1 = GameObject.Tag.mainCamera
        /// print(tag1.name) // Prints "MainCamera"
        ///
        /// let tag2 = GameObject.Tag.custom("Enemy")
        /// print(tag2.name) // Prints "Enemy"
        /// ```
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
