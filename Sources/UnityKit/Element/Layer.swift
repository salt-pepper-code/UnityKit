public extension GameObject {
    /// A bitmask-based system for organizing GameObjects into layers for selective rendering, physics, and raycasting.
    ///
    /// Layers provide a powerful way to control how GameObjects interact with different systems in your game.
    /// They use an `OptionSet` implementation, allowing you to combine multiple layers using set operations.
    /// This is particularly useful for physics filtering, camera culling, and raycast targeting.
    ///
    /// ## Topics
    ///
    /// ### Predefined Layers
    /// - ``default``
    /// - ``ground``
    /// - ``player``
    /// - ``environment``
    /// - ``projectile``
    ///
    /// ### Layer Operations
    /// - ``all``
    /// - ``layer(for:)``
    /// - ``name(for:)``
    /// - ``addLayer(with:)``
    /// - ``isPart(of:)``
    ///
    /// ## Example Usage
    ///
    /// ### Basic Layer Assignment
    /// ```swift
    /// let player = GameObject(name: "Player")
    /// player.layer = .player
    ///
    /// let floor = GameObject(name: "Floor")
    /// floor.layer = .ground
    /// ```
    ///
    /// ### Physics Layer Filtering
    /// ```swift
    /// // Configure a raycast to only hit ground and environment layers
    /// let raycastMask: GameObject.Layer = [.ground, .environment]
    ///
    /// if let hit = physics.raycast(from: origin, direction: direction, layerMask: raycastMask) {
    ///     print("Hit object on layer: \(GameObject.Layer.name(for: hit.gameObject.layer))")
    /// }
    ///
    /// // Exclude player layer from collision detection
    /// let collisionMask: GameObject.Layer = [.ground, .environment, .projectile]
    /// physics.setCollisionMask(for: .player, mask: collisionMask)
    /// ```
    ///
    /// ### Camera Culling Masks
    /// ```swift
    /// // Main camera renders everything except UI layer
    /// let mainCamera = GameObject(name: "Main Camera")
    /// mainCamera.camera?.cullingMask = [.default, .ground, .player, .environment]
    ///
    /// // Minimap camera only renders ground and player
    /// let minimapCamera = GameObject(name: "Minimap Camera")
    /// minimapCamera.camera?.cullingMask = [.ground, .player]
    /// ```
    ///
    /// ### Custom Layers
    /// ```swift
    /// // Add a custom layer at runtime
    /// let enemyLayer = GameObject.Layer.addLayer(with: "Enemy")
    ///
    /// let zombie = GameObject(name: "Zombie")
    /// zombie.layer = enemyLayer
    ///
    /// // Retrieve layer by name
    /// let retrievedLayer = GameObject.Layer.layer(for: "Enemy")
    /// print("Enemy layer: \(GameObject.Layer.name(for: retrievedLayer))")
    /// ```
    ///
    /// ### Combining Multiple Layers
    /// ```swift
    /// // Create a mask for multiple layers
    /// let characterLayers: GameObject.Layer = [.player, .custom("NPC"), .custom("Enemy")]
    ///
    /// // Check if a layer is part of a mask
    /// if player.layer.isPart(of: characterLayers.rawValue) {
    ///     print("This is a character layer")
    /// }
    ///
    /// // Use all layers
    /// let allLayers = GameObject.Layer.all
    /// camera.cullingMask = allLayers
    /// ```
    struct Layer: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// The default layer for GameObjects.
        ///
        /// This is the standard layer assigned to GameObjects that don't require special layer assignment.
        /// Most basic objects in a scene typically use this layer.
        ///
        /// ## Example
        /// ```swift
        /// let genericObject = GameObject(name: "Box")
        /// genericObject.layer = .default
        /// ```
        public static let `default` = Layer(rawValue: 1 << 0)

        /// A layer typically used for ground, floor, and terrain objects.
        ///
        /// Use this layer for surfaces that characters walk on or objects collide with as ground.
        /// This is useful for physics systems to distinguish between ground and other collision types.
        ///
        /// ## Example
        /// ```swift
        /// let terrain = GameObject(name: "Terrain")
        /// terrain.layer = .ground
        ///
        /// // Check if player is grounded by raycasting against ground layer
        /// let isGrounded = physics.raycast(from: playerPosition, direction: .down, layerMask: .ground)
        /// ```
        public static let ground = Layer(rawValue: 1 << 1)

        /// A layer for the player character or player-controlled objects.
        ///
        /// This layer is typically used to identify player GameObjects and can be useful for
        /// excluding the player from certain raycasts or collision checks.
        ///
        /// ## Example
        /// ```swift
        /// let playerCharacter = GameObject(name: "Player")
        /// playerCharacter.layer = .player
        ///
        /// // Raycast that ignores the player layer
        /// let enemyVisionMask: GameObject.Layer = [.ground, .environment]
        /// let canSeeTarget = physics.raycast(from: enemy.position, to: target.position, layerMask: enemyVisionMask)
        /// ```
        public static let player = Layer(rawValue: 1 << 2)

        /// A layer for environmental objects like buildings, walls, and obstacles.
        ///
        /// Use this layer for static or semi-static objects in the environment that provide
        /// collision and visual blocking but aren't interactive game objects.
        ///
        /// ## Example
        /// ```swift
        /// let wall = GameObject(name: "Wall")
        /// wall.layer = .environment
        ///
        /// let tree = GameObject(name: "Tree")
        /// tree.layer = .environment
        /// ```
        public static let environment = Layer(rawValue: 1 << 3)

        /// A layer for projectiles like bullets, arrows, and thrown objects.
        ///
        /// This layer is useful for managing projectile physics and collisions separately from
        /// other game objects, allowing for optimized collision detection and special handling.
        ///
        /// ## Example
        /// ```swift
        /// let bullet = GameObject(name: "Bullet")
        /// bullet.layer = .projectile
        ///
        /// // Configure projectiles to only collide with enemies and environment
        /// let projectileCollisionMask: GameObject.Layer = [.custom("Enemy"), .environment]
        /// physics.setCollisionMask(for: .projectile, mask: projectileCollisionMask)
        /// ```
        public static let projectile = Layer(rawValue: 1 << 4)

        /// A layer mask containing all registered layers.
        ///
        /// Returns a combined layer mask with all currently registered layers, including both
        /// predefined and custom layers added at runtime.
        ///
        /// ## Example
        /// ```swift
        /// // Render all layers with the main camera
        /// mainCamera.cullingMask = GameObject.Layer.all
        ///
        /// // Create a raycast that can hit any layer
        /// let hit = physics.raycast(from: origin, direction: direction, layerMask: .all)
        /// ```
        public static var all: Layer {
            return layers.values.reduce(Layer(rawValue: 0)) { prev, layer in
                [prev, layer]
            }
        }

        /// A dictionary mapping layer names to their corresponding layer values.
        ///
        /// This dictionary contains all registered layers, both predefined and custom.
        /// It can be used to look up layers by name or iterate through all available layers.
        ///
        /// The dictionary is publicly readable but can only be modified through the ``addLayer(with:)`` method.
        public private(set) static var layers = [
            "default": `default`,
            "ground": ground,
            "player": player,
            "environment": environment,
            "projectile": projectile,
        ]

        /// Retrieves a layer by its name.
        ///
        /// Returns the layer associated with the given name, or the default layer if the name is not found.
        ///
        /// - Parameter name: The name of the layer to retrieve.
        /// - Returns: The layer with the specified name, or `.default` if not found.
        ///
        /// ## Example
        /// ```swift
        /// // Retrieve a predefined layer
        /// let playerLayer = GameObject.Layer.layer(for: "player")
        ///
        /// // Retrieve a custom layer
        /// let enemyLayer = GameObject.Layer.layer(for: "Enemy")
        ///
        /// // Unknown layers return .default
        /// let unknownLayer = GameObject.Layer.layer(for: "NonExistent") // Returns .default
        /// ```
        public static func layer(for name: String) -> Layer {
            return self.layers[name] ?? self.default
        }

        /// Returns the name of a given layer.
        ///
        /// Performs a reverse lookup in the layers dictionary to find the name associated with the layer.
        /// If the layer is not found in the dictionary, an empty string is returned.
        ///
        /// - Parameter layer: The layer to look up.
        /// - Returns: The name of the layer, or an empty string if not found.
        ///
        /// ## Example
        /// ```swift
        /// let playerLayer = GameObject.Layer.player
        /// let name = GameObject.Layer.name(for: playerLayer)
        /// print(name) // Prints "player"
        ///
        /// // Works with custom layers too
        /// let customLayer = GameObject.Layer.addLayer(with: "Enemy")
        /// let customName = GameObject.Layer.name(for: customLayer)
        /// print(customName) // Prints "Enemy"
        /// ```
        public static func name(for layer: Layer) -> String {
            guard let index = layers.firstIndex(where: { _, value -> Bool in value == layer }) else { return "" }
            return self.layers.keys[index]
        }

        /// Creates and registers a new custom layer with the specified name.
        ///
        /// If a layer with the given name already exists, it returns the existing layer.
        /// Otherwise, it creates a new layer with a unique bit value and adds it to the layers dictionary.
        ///
        /// The layer's raw value is calculated as `1 << layerCount`, ensuring each layer has a unique bit position.
        ///
        /// - Parameter name: The name for the new layer.
        /// - Returns: The newly created layer, or the existing layer if one with the same name already exists.
        ///
        /// ## Example
        /// ```swift
        /// // Add custom layers for game-specific needs
        /// let enemyLayer = GameObject.Layer.addLayer(with: "Enemy")
        /// let npcLayer = GameObject.Layer.addLayer(with: "NPC")
        /// let pickupLayer = GameObject.Layer.addLayer(with: "Pickup")
        ///
        /// // Assign custom layers to GameObjects
        /// let zombie = GameObject(name: "Zombie")
        /// zombie.layer = enemyLayer
        ///
        /// // Configure interactions between layers
        /// let combatMask: GameObject.Layer = [enemyLayer, .player]
        /// weapon.raycastMask = combatMask
        ///
        /// // Adding a layer with an existing name returns the existing layer
        /// let duplicateLayer = GameObject.Layer.addLayer(with: "Enemy")
        /// print(duplicateLayer == enemyLayer) // Prints true
        /// ```
        @discardableResult static func addLayer(with name: String) -> Layer {
            if let layer = layers[name] {
                return layer
            }

            let rawValue = 1 << self.layers.count
            let layer = Layer(rawValue: rawValue)
            self.layers[name] = layer

            return layer
        }

        /// Checks whether this layer is included in a given bitmask.
        ///
        /// This method is useful for determining if a layer matches a layer mask used in physics
        /// queries, camera culling, or other layer-based filtering operations.
        ///
        /// - Parameter bitMaskRawValue: The raw integer value of a layer bitmask to check against.
        /// - Returns: `true` if this layer is part of the bitmask, `false` otherwise.
        ///
        /// ## Example
        /// ```swift
        /// let playerLayer = GameObject.Layer.player
        /// let groundLayer = GameObject.Layer.ground
        ///
        /// // Create a mask containing player and ground layers
        /// let mask: GameObject.Layer = [.player, .ground]
        ///
        /// // Check if individual layers are part of the mask
        /// print(playerLayer.isPart(of: mask.rawValue)) // Prints true
        /// print(groundLayer.isPart(of: mask.rawValue)) // Prints true
        ///
        /// let environmentLayer = GameObject.Layer.environment
        /// print(environmentLayer.isPart(of: mask.rawValue)) // Prints false
        ///
        /// // Practical use case: checking if a GameObject should be affected
        /// if gameObject.layer.isPart(of: affectedLayers.rawValue) {
        ///     applyEffect(to: gameObject)
        /// }
        /// ```
        public func isPart(of bitMaskRawValue: Int) -> Bool {
            return Layer(rawValue: bitMaskRawValue).contains(self)
        }
    }
}
