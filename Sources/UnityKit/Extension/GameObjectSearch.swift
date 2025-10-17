public extension GameObject {
    /// A type that defines search criteria for finding GameObjects in a scene hierarchy.
    ///
    /// Use `SearchType` to specify different criteria for searching GameObjects, including
    /// name matching, tags, layers, and component types.
    ///
    /// ## Topics
    /// ### Name Matching
    /// - ``Name``
    ///
    /// ### Search Criteria
    /// - ``name(_:)``
    /// - ``tag(_:)``
    /// - ``layer(_:)``
    /// - ``nameAndTag(_:_:)``
    /// - ``camera(_:)``
    /// - ``light(_:)``
    enum SearchType {
        /// Name matching strategies for GameObject searches.
        ///
        /// Use these cases to define how GameObject names should be matched during searches.
        ///
        /// ## Example
        /// ```swift
        /// // Find by exact name
        /// let exactMatch = GameObject.find(.name(.exact("Player")))
        ///
        /// // Find names containing a substring
        /// let containsMatch = GameObject.find(.name(.contains("Enemy")))
        ///
        /// // Find names starting with a prefix
        /// let prefixMatch = GameObject.find(.name(.startWith("Item_")))
        /// ```
        public enum Name {
            /// Matches GameObjects whose name contains the specified string.
            case contains(String)

            /// Matches GameObjects whose name starts with the specified string.
            case startWith(String)

            /// Matches GameObjects whose name exactly equals the specified string.
            case exact(String)

            /// Matches any GameObject regardless of name.
            case any
        }

        /// Search for GameObjects by name.
        case name(Name)

        /// Search for GameObjects by tag.
        case tag(Tag)

        /// Search for GameObjects by layer.
        case layer(Layer)

        /// Search for GameObjects by both name and tag.
        case nameAndTag(Name, Tag)

        /// Search for GameObjects with a camera component.
        case camera(Name)

        /// Search for GameObjects with a light component.
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

    /// Finds the first GameObject matching the specified search criteria in a scene.
    ///
    /// This method performs a breadth-first search through the scene hierarchy,
    /// returning the first GameObject that matches the search criteria.
    ///
    /// - Parameters:
    ///   - type: The search criteria to use for matching GameObjects.
    ///   - scene: The scene to search in. Defaults to `Scene.shared`.
    ///
    /// - Returns: The first matching GameObject, or `nil` if no match is found.
    ///
    /// ## Example
    /// ```swift
    /// // Find a specific player GameObject
    /// if let player = GameObject.find(.name(.exact("Player"))) {
    ///     print("Found player at position: \(player.transform.position)")
    /// }
    ///
    /// // Find the main camera
    /// if let camera = GameObject.find(.camera(.exact("Main Camera"))) {
    ///     print("Main camera found")
    /// }
    ///
    /// // Find by tag
    /// if let enemy = GameObject.find(.tag(.enemy)) {
    ///     print("Found enemy: \(enemy.name ?? "unnamed")")
    /// }
    /// ```
    static func find(_ type: SearchType, in scene: Scene? = Scene.shared) -> GameObject? {
        guard let scene else { return nil }
        return GameObject.find(type, in: scene.rootGameObject)
    }

    /// Finds the first GameObject matching the specified search criteria within a GameObject hierarchy.
    ///
    /// This method recursively searches through the GameObject and all its descendants,
    /// returning the first GameObject that matches the search criteria.
    ///
    /// - Parameters:
    ///   - type: The search criteria to use for matching GameObjects.
    ///   - gameObject: The root GameObject to start the search from.
    ///
    /// - Returns: The first matching GameObject, or `nil` if no match is found.
    ///
    /// ## Example
    /// ```swift
    /// // Find within a specific parent
    /// let enemyFolder = GameObject.find(.name(.exact("Enemies")))
    /// if let boss = GameObject.find(.name(.contains("Boss")), in: enemyFolder) {
    ///     print("Found boss enemy")
    /// }
    /// ```
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

    /// Finds all GameObjects matching the specified search criteria in a scene.
    ///
    /// This method recursively searches through the scene hierarchy and returns
    /// all GameObjects that match the specified criteria.
    ///
    /// - Parameters:
    ///   - type: The search criteria to use for matching GameObjects.
    ///   - scene: The scene to search in. Defaults to `Scene.shared`.
    ///
    /// - Returns: An array of all matching GameObjects. Returns an empty array if no matches are found.
    ///
    /// ## Example
    /// ```swift
    /// // Find all enemies in the scene
    /// let enemies = GameObject.findGameObjects(.tag(.enemy))
    /// print("Found \(enemies.count) enemies")
    ///
    /// // Find all objects with names containing "Coin"
    /// let coins = GameObject.findGameObjects(.name(.contains("Coin")))
    /// for coin in coins {
    ///     coin.setColor(.yellow)
    /// }
    ///
    /// // Find all lights in the scene
    /// let lights = GameObject.findGameObjects(.light(.any))
    /// lights.forEach { $0.setActive(false) }
    /// ```
    static func findGameObjects(_ type: SearchType, in scene: Scene? = Scene.shared) -> [GameObject] {
        guard let scene else { return [] }
        return GameObject.findGameObjects(type, in: scene.rootGameObject)
    }

    /// Finds all GameObjects matching the specified search criteria within a GameObject hierarchy.
    ///
    /// This method recursively searches through the GameObject and all its descendants,
    /// returning all GameObjects that match the search criteria.
    ///
    /// - Parameters:
    ///   - type: The search criteria to use for matching GameObjects.
    ///   - gameObject: The root GameObject to start the search from.
    ///
    /// - Returns: An array of all matching GameObjects. Returns an empty array if no matches are found.
    ///
    /// ## Example
    /// ```swift
    /// // Find all power-ups within a level
    /// if let level = GameObject.find(.name(.exact("Level1"))) {
    ///     let powerUps = GameObject.findGameObjects(.tag(.powerUp), in: level)
    ///     print("Level 1 has \(powerUps.count) power-ups")
    /// }
    /// ```
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

    /// Finds all components of a specified type across all GameObjects in a scene.
    ///
    /// This method recursively searches through the scene hierarchy and collects
    /// all components of the specified type from every GameObject.
    ///
    /// - Parameters:
    ///   - type: The component type to search for.
    ///   - scene: The scene to search in. Defaults to `Scene.shared`.
    ///
    /// - Returns: An array of all components of the specified type found in the scene.
    ///
    /// ## Example
    /// ```swift
    /// // Find all Rigidbody components in the scene
    /// let rigidbodies = GameObject.getComponents(Rigidbody.self)
    /// for rb in rigidbodies {
    ///     rb.velocity = .zero
    /// }
    ///
    /// // Find all AudioSource components and stop them
    /// let audioSources = GameObject.getComponents(AudioSource.self)
    /// audioSources.forEach { $0.stop() }
    ///
    /// // Count all colliders in the scene
    /// let colliders = GameObject.getComponents(BoxCollider.self)
    /// print("Scene contains \(colliders.count) box colliders")
    /// ```
    static func getComponents<T: Component>(_ type: T.Type, in scene: Scene? = Scene.shared) -> [T] {
        guard let scene else { return [] }
        return GameObject.getComponents(type, in: scene.rootGameObject)
    }

    /// Finds all components of a specified type within a GameObject hierarchy.
    ///
    /// This method recursively searches through the GameObject and all its descendants,
    /// collecting all components of the specified type.
    ///
    /// - Parameters:
    ///   - type: The component type to search for.
    ///   - gameObject: The root GameObject to start the search from.
    ///
    /// - Returns: An array of all components of the specified type found in the hierarchy.
    ///
    /// ## Example
    /// ```swift
    /// // Find all MeshRenderer components under a parent object
    /// if let vehicle = GameObject.find(.name(.exact("Vehicle"))) {
    ///     let renderers = GameObject.getComponents(MeshRenderer.self, in: vehicle)
    ///     renderers.forEach { $0.enabled = false }
    /// }
    /// ```
    static func getComponents<T: Component>(_ type: T.Type, in gameObject: GameObject) -> [T] {
        return gameObject.getChildren()
            .map { child -> [T] in
                return child.getComponents(type) + GameObject.getComponents(type, in: child)
            }.reduce([]) { current, next -> [T] in
                current + next
            }
    }
}
