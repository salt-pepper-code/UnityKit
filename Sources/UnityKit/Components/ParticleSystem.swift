import SceneKit

/// A component for creating and controlling particle effects.
///
/// `ParticleSystem` wraps SceneKit's `SCNParticleSystem` to provide visual effects like fire,
/// smoke, rain, explosions, and other particle-based animations. Particle systems are loaded
/// from `.scnp` files created in Xcode's particle system editor or programmatically configured.
///
/// ## Topics
///
/// ### Loading Particle Systems
/// - ``load(fileName:bundle:loops:)``
///
/// ### Accessing the Particle System
/// - ``scnParticleSystem``
///
/// ### Executing Actions
/// - ``execute(_:)``
/// - ``executeAfter(milliseconds:block:)``
///
/// ### Component Lifecycle
/// - ``onDestroy()``
///
/// ## Example
///
/// ```swift
/// // Create a GameObject with a particle system
/// let fireEffect = GameObject(name: "Fire")
///     .addComponent(ParticleSystem.self)?
///     .load(fileName: "fire.scnp", loops: true)
///     .execute { system in
///         system?.particleSize = 0.5
///         system?.birthRate = 100
///     }
///
/// // Stop the effect after 3 seconds
/// fireEffect?.getComponent(ParticleSystem.self)?
///     .executeAfter(milliseconds: 3000) { system in
///         system?.birthRate = 0
///     }
/// ```
///
/// - Note: Particle system files (`.scnp`) can be created in Xcode's SceneKit editor.
/// - Important: The particle system is automatically cleaned up when the component is destroyed.
public class ParticleSystem: Component {
    override var order: ComponentOrder {
        .other
    }

    /// The underlying SceneKit particle system.
    ///
    /// Provides direct access to the `SCNParticleSystem` for advanced configuration.
    /// This is set when a particle system is loaded via ``load(fileName:bundle:loops:)``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let system = particleSystem.scnParticleSystem {
    ///     system.birthRate = 50
    ///     system.particleLifeSpan = 2.0
    ///     system.emissionDuration = 5.0
    /// }
    /// ```
    public var scnParticleSystem: SCNParticleSystem?

    /// Called when the component is destroyed.
    ///
    /// Resets the particle system, removes it from the GameObject's node, and cleans up resources.
    /// This ensures all particles are removed and the system is properly disposed of.
    override public func onDestroy() {
        guard let particule = scnParticleSystem
        else { return }

        particule.reset()
        self.scnParticleSystem = nil
        gameObject?.node.removeParticleSystem(particule)
    }

    /// Loads a particle system from a file.
    ///
    /// Loads a SceneKit particle system (`.scnp` file) from the specified bundle and adds it
    /// to the GameObject's node. The particle system can be configured to loop continuously
    /// or play once.
    ///
    /// - Parameters:
    ///   - fileName: The name of the particle system file to load (with or without `.scnp` extension).
    ///   - bundle: The bundle containing the particle system file. Defaults to the main bundle.
    ///   - loops: Whether the particle system should loop continuously (`true`) or play once (`false`).
    ///
    /// - Returns: This particle system component for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// particleSystem
    ///     .load(fileName: "explosion.scnp", loops: false)
    ///     .execute { system in
    ///         system?.particleSize = 1.0
    ///     }
    /// ```
    ///
    /// - Note: If the file cannot be found or loaded, the method returns self without making changes.
    @discardableResult public func load(
        fileName: String,
        bundle: Bundle = Bundle.main,
        loops: Bool
    ) -> ParticleSystem {
        guard let modelUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
        else { return self }

        var path = modelUrl.relativePath
            .replacingOccurrences(of: bundle.bundlePath, with: "")
            .replacingOccurrences(of: modelUrl.lastPathComponent, with: "")

        if path.first == "/" {
            path.removeFirst()
        }

        guard let particule = SCNParticleSystem(named: modelUrl.lastPathComponent, inDirectory: path)
        else { return self }

        particule.colliderNodes = []
        particule.loops = loops
        self.scnParticleSystem = particule
        gameObject?.node.addParticleSystem(particule)

        return self
    }

    /// Executes a configuration block immediately.
    ///
    /// Provides access to the underlying `SCNParticleSystem` for configuration. This is useful
    /// for setting particle system properties right after loading.
    ///
    /// - Parameter block: A closure that receives the particle system for configuration.
    /// - Returns: This particle system component for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// particleSystem
    ///     .load(fileName: "smoke.scnp", loops: true)
    ///     .execute { system in
    ///         system?.birthRate = 200
    ///         system?.particleColor = .gray
    ///         system?.emitterShape = .sphere(radius: 1.0)
    ///     }
    /// ```
    @discardableResult public func execute(_ block: (SCNParticleSystem?) -> Void) -> ParticleSystem {
        block(self.scnParticleSystem)
        return self
    }

    /// Executes a configuration block after a specified delay.
    ///
    /// Schedules a block to execute on the main queue after the specified number of milliseconds.
    /// This is useful for timed particle effects or animations.
    ///
    /// - Parameters:
    ///   - milliseconds: The delay in milliseconds before executing the block.
    ///   - block: A closure that receives the particle system for configuration.
    ///
    /// - Returns: This particle system component for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Start with high birth rate, then fade out
    /// particleSystem
    ///     .load(fileName: "sparkles.scnp", loops: false)
    ///     .execute { system in
    ///         system?.birthRate = 500
    ///     }
    ///     .executeAfter(milliseconds: 2000) { system in
    ///         system?.birthRate = 0  // Stop emitting after 2 seconds
    ///     }
    /// ```
    ///
    /// - Note: The block is executed on the main queue and uses a weak reference to the particle system
    ///   to prevent retain cycles.
    @discardableResult public func executeAfter(
        milliseconds: Int,
        block: @escaping (SCNParticleSystem?) -> Void
    ) -> ParticleSystem {
        DispatchQueue.main
            .asyncAfter(deadline: .now() + DispatchTimeInterval
                .milliseconds(milliseconds))
            { [weak scnParticleSystem] in
                block(scnParticleSystem)
            }
        return self
    }
}
