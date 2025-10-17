import SceneKit

public extension GameObject {
    internal static func convertAllChildToGameObjects(_ gameObject: GameObject) {
        gameObject.layer = .default
        for getChildNode in gameObject.getChildNodes() {
            gameObject.addChild(GameObject(getChildNode))
        }
    }

    /// Creates a copy of a GameObject and optionally adds it to the scene.
    ///
    /// This factory method instantiates a duplicate of the original GameObject,
    /// preserving all its components and properties.
    ///
    /// - Parameters:
    ///   - original: The GameObject to duplicate.
    ///   - addToScene: Whether to add the new GameObject to the scene. Defaults to `true`.
    ///
    /// - Returns: A new GameObject that is a copy of the original.
    ///
    /// ## Example
    /// ```swift
    /// // Create a prefab for an enemy
    /// let enemyPrefab = GameObject("Enemy")
    /// enemyPrefab.addComponent(MeshRenderer.self)
    /// enemyPrefab.addComponent(Rigidbody.self)
    ///
    /// // Spawn multiple enemies
    /// for i in 0..<5 {
    ///     let enemy = GameObject.instantiate(original: enemyPrefab)
    ///     enemy.transform.position = Vector3(Float(i) * 2, 0, 0)
    /// }
    ///
    /// // Create without adding to scene (useful for object pooling)
    /// let pooledObject = GameObject.instantiate(original: prefab, addToScene: false)
    /// ```
    static func instantiate(original: GameObject, addToScene: Bool = true) -> GameObject {
        let gameObject = original.instantiate()

        if addToScene {
            let scene = original.scene ?? Scene.shared
            scene?.addGameObject(gameObject)
        }

        return gameObject
    }

    /// Creates a copy of a GameObject as a child of the specified parent.
    ///
    /// This factory method instantiates a duplicate of the original GameObject
    /// and immediately adds it as a child of the specified parent transform.
    ///
    /// - Parameters:
    ///   - original: The GameObject to duplicate.
    ///   - parent: The parent transform to attach the new GameObject to.
    ///
    /// - Returns: A new GameObject that is a copy of the original, parented to the specified transform.
    ///
    /// ## Example
    /// ```swift
    /// // Create a weapon as a child of the player
    /// let weaponPrefab = GameObject("Weapon")
    /// if let player = GameObject.find(.name(.exact("Player"))) {
    ///     let weapon = GameObject.instantiate(original: weaponPrefab, parent: player.transform)
    ///     weapon.transform.localPosition = Vector3(0.5, 0, 0)
    /// }
    ///
    /// // Spawn bullets as children of a bullet container
    /// let bulletContainer = GameObject("Bullets")
    /// for _ in 0..<10 {
    ///     let bullet = GameObject.instantiate(original: bulletPrefab, parent: bulletContainer.transform)
    /// }
    /// ```
    static func instantiate(original: GameObject, parent: Transform) -> GameObject {
        let gameObject = original.instantiate()

        parent.gameObject?.addChild(gameObject)

        return gameObject
    }

    /// Sets the color of the GameObject's material.
    ///
    /// This method updates the GameObject's renderer material with the specified color
    /// and lighting model. It returns the GameObject to allow method chaining.
    ///
    /// - Parameters:
    ///   - color: The color to apply to the material.
    ///   - lightingModel: The lighting model to use. Defaults to `.phong`.
    ///
    /// - Returns: The GameObject instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// // Create a red cube
    /// let cube = GameObject.createPrimitive(.cube)
    ///     .setColor(.red)
    ///
    /// // Create a blue sphere with Lambert lighting
    /// let sphere = GameObject.createPrimitive(.sphere)
    ///     .setColor(.blue, lightingModel: .lambert)
    ///
    /// // Change color based on game state
    /// if player.health < 20 {
    ///     healthBar.setColor(.red)
    /// } else {
    ///     healthBar.setColor(.green)
    /// }
    ///
    /// // Chain multiple visual modifications
    /// GameObject.createPrimitive(.plane)
    ///     .setColor(.yellow)
    ///     .setOpacity(0.5)
    /// ```
    func setColor(_ color: Color, lightingModel: SCNMaterial.LightingModel = .phong) -> GameObject {
        renderer?.material = Material(color, lightingModel: lightingModel)

        return self
    }

    /// Sets the opacity of the GameObject.
    ///
    /// This method adjusts the transparency of the GameObject's node.
    /// It returns the GameObject to allow method chaining.
    ///
    /// - Parameters:
    ///   - opacity: The opacity value from 0.0 (fully transparent) to 1.0 (fully opaque).
    ///   - lightingModel: The lighting model to use. Defaults to `.phong`.
    ///
    /// - Returns: The GameObject instance for method chaining.
    ///
    /// ## Example
    /// ```swift
    /// // Create a semi-transparent window
    /// let window = GameObject.createPrimitive(.plane)
    ///     .setColor(.cyan)
    ///     .setOpacity(0.3)
    ///
    /// // Fade out effect
    /// gameObject.setOpacity(0.5)
    ///
    /// // Make completely invisible (but still active)
    /// ghostObject.setOpacity(0.0)
    ///
    /// // Chain with color setting
    /// let powerUp = GameObject.createPrimitive(.sphere)
    ///     .setColor(.purple)
    ///     .setOpacity(0.7)
    /// ```
    func setOpacity(_ opacity: Float, lightingModel: SCNMaterial.LightingModel = .phong) -> GameObject {
        node.opacity = opacity.toCGFloat()

        return self
    }
}
