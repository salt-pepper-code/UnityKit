import SceneKit

public extension GameObject {
    /// Runs an action on the GameObject.
    ///
    /// Executes the specified action on the GameObject's underlying node,
    /// allowing for animations and transformations.
    ///
    /// - Parameter action: The action to execute.
    ///
    /// ## Example
    /// ```swift
    /// // Rotate a GameObject continuously
    /// let rotateAction = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 2.0)
    /// let repeatAction = SCNAction.repeatForever(rotateAction)
    /// gameObject.runAction(repeatAction)
    ///
    /// // Move a GameObject
    /// let moveAction = SCNAction.move(by: Vector3(0, 5, 0), duration: 1.0)
    /// gameObject.runAction(moveAction)
    /// ```
    func runAction(_ action: SCNAction) {
        node.runAction(action)
    }

    /// Runs an action on the GameObject with a completion handler.
    ///
    /// Executes the specified action and calls the completion handler when finished.
    ///
    /// - Parameters:
    ///   - action: The action to execute.
    ///   - block: A closure to execute when the action completes. Optional.
    ///
    /// ## Example
    /// ```swift
    /// // Fade out and then destroy
    /// let fadeOut = SCNAction.fadeOut(duration: 1.0)
    /// gameObject.runAction(fadeOut) {
    ///     gameObject.destroy()
    /// }
    ///
    /// // Move and play sound when done
    /// let moveAction = SCNAction.move(to: targetPosition, duration: 2.0)
    /// player.runAction(moveAction) {
    ///     audioSource.play()
    ///     print("Player reached destination")
    /// }
    ///
    /// // Chain multiple actions
    /// let scaleUp = SCNAction.scale(to: 2.0, duration: 0.5)
    /// powerUp.runAction(scaleUp) {
    ///     print("Power-up collected!")
    /// }
    /// ```
    func runAction(_ action: SCNAction, completionHandler block: (() -> Void)? = nil) {
        node.runAction(action, completionHandler: block)
    }

    /// Runs an action on the GameObject with an identifying key.
    ///
    /// Executes the specified action and associates it with a key for later reference.
    /// This allows you to retrieve or remove the action by key.
    ///
    /// - Parameters:
    ///   - action: The action to execute.
    ///   - key: A string identifier for the action. Can be `nil`.
    ///
    /// ## Example
    /// ```swift
    /// // Start a walk animation
    /// let walkAction = SCNAction.repeatForever(walkCycle)
    /// character.runAction(walkAction, forKey: "walking")
    ///
    /// // Later, check if still walking
    /// if character.action(forKey: "walking") != nil {
    ///     print("Character is walking")
    /// }
    ///
    /// // Run damage flash effect
    /// let flashAction = SCNAction.sequence([
    ///     SCNAction.fadeOpacity(to: 0.5, duration: 0.1),
    ///     SCNAction.fadeOpacity(to: 1.0, duration: 0.1)
    /// ])
    /// enemy.runAction(flashAction, forKey: "damage")
    /// ```
    func runAction(_ action: SCNAction, forKey key: String?) {
        node.runAction(action, forKey: key)
    }

    /// Runs an action on the GameObject with a key and completion handler.
    ///
    /// Executes the specified action with an identifying key and calls the
    /// completion handler when finished.
    ///
    /// - Parameters:
    ///   - action: The action to execute.
    ///   - key: A string identifier for the action. Can be `nil`.
    ///   - block: A closure to execute when the action completes. Optional.
    ///
    /// ## Example
    /// ```swift
    /// // Run jump animation with callback
    /// let jumpAction = SCNAction.sequence([
    ///     SCNAction.moveBy(x: 0, y: 2, z: 0, duration: 0.3),
    ///     SCNAction.moveBy(x: 0, y: -2, z: 0, duration: 0.3)
    /// ])
    /// player.runAction(jumpAction, forKey: "jump") {
    ///     print("Jump completed")
    ///     canJump = true
    /// }
    ///
    /// // Timed power-up effect
    /// let glowAction = SCNAction.sequence([
    ///     SCNAction.fadeOpacity(to: 1.5, duration: 0.5),
    ///     SCNAction.wait(duration: 5.0),
    ///     SCNAction.fadeOpacity(to: 1.0, duration: 0.5)
    /// ])
    /// player.runAction(glowAction, forKey: "powerUp") {
    ///     player.removeComponent(PowerUpEffect.self)
    /// }
    /// ```
    func runAction(_ action: SCNAction, forKey key: String?, completionHandler block: (() -> Void)? = nil) {
        node.runAction(action, forKey: key, completionHandler: block)
    }

    /// A Boolean value indicating whether the GameObject has any running actions.
    ///
    /// ## Example
    /// ```swift
    /// // Check if character is animating
    /// if character.hasActions {
    ///     print("Character is performing actions")
    /// }
    ///
    /// // Pause game only if animations are running
    /// if !gameObject.hasActions {
    ///     startNextAnimation()
    /// }
    /// ```
    var hasActions: Bool {
        return node.hasActions
    }

    /// Returns the action associated with the specified key.
    ///
    /// - Parameter key: The identifying key for the action.
    ///
    /// - Returns: The action object, or `nil` if no action is associated with the key.
    ///
    /// ## Example
    /// ```swift
    /// // Check if a specific animation is running
    /// if let walkAction = character.action(forKey: "walking") {
    ///     print("Walk animation is active")
    ///     // Could modify or inspect the action
    /// }
    ///
    /// // Verify attack animation before canceling
    /// if player.action(forKey: "attack") != nil {
    ///     player.removeAction(forKey: "attack")
    /// }
    /// ```
    func action(forKey key: String) -> SCNAction? {
        return node.action(forKey: key)
    }

    /// Removes the action associated with the specified key.
    ///
    /// Stops and removes the action immediately, without completing it.
    ///
    /// - Parameter key: The identifying key for the action to remove.
    ///
    /// ## Example
    /// ```swift
    /// // Stop walking animation
    /// character.removeAction(forKey: "walking")
    ///
    /// // Cancel attack animation when stunned
    /// if player.isStunned {
    ///     player.removeAction(forKey: "attack")
    /// }
    ///
    /// // Stop rotation when object is grabbed
    /// pickup.removeAction(forKey: "rotate")
    /// ```
    func removeAction(forKey key: String) {
        node.removeAction(forKey: key)
    }

    /// Removes all actions currently running on the GameObject.
    ///
    /// Stops and removes all actions immediately, without completing them.
    ///
    /// ## Example
    /// ```swift
    /// // Stop all animations when game pauses
    /// for gameObject in activeObjects {
    ///     gameObject.removeAllActions()
    /// }
    ///
    /// // Reset character state
    /// player.removeAllActions()
    /// player.transform.position = spawnPoint
    ///
    /// // Clear enemy behavior
    /// enemy.removeAllActions()
    /// enemy.destroy()
    /// ```
    func removeAllActions() {
        node.removeAllActions()
    }

    /// An array of keys identifying all actions currently running on the GameObject.
    ///
    /// ## Example
    /// ```swift
    /// // List all active animations
    /// for key in character.actionKeys {
    ///     print("Active action: \(key)")
    /// }
    ///
    /// // Check for specific action type
    /// if character.actionKeys.contains("attack") {
    ///     print("Character is attacking")
    /// }
    ///
    /// // Debug action count
    /// print("GameObject has \(gameObject.actionKeys.count) actions running")
    /// ```
    var actionKeys: [String] {
        return node.actionKeys
    }
}
