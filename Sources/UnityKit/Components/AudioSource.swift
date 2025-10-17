import AVKit

/// A component that plays audio clips in 3D space.
///
/// `AudioSource` is a component that can play audio clips with spatial audio positioning.
/// It wraps an `AVAudioPlayerNode` and integrates with the shared `AudioEngine` to provide
/// 3D audio playback. You can control playback volume, position, and assign different audio clips.
///
/// ## Topics
///
/// ### Configuring Audio
/// - ``configure(_:)``
/// - ``set(volume:)``
/// - ``set(clip:)``
/// - ``set(customPosition:)``
///
/// ### Managing Properties
/// - ``volume``
/// - ``clip``
/// - ``customPosition``
///
/// ### Controlling Playback
/// - ``play()``
/// - ``stop()``
///
/// ### Component Lifecycle
/// - ``awake()``
/// - ``onDestroy()``
///
/// ## Example
///
/// ```swift
/// // Create a GameObject with an AudioSource
/// let speaker = GameObject(name: "Speaker")
///     .addComponent(AudioSource.self)?
///     .configure { audioSource in
///         guard let clip = AudioClip(fileName: "music.mp3", playType: .loop) else { return }
///         audioSource.set(clip: clip)
///             .set(volume: 0.8)
///             .set(customPosition: Vector3(x: 5, y: 0, z: 10))
///     }
///
/// // Start playback
/// speaker?.getComponent(AudioSource.self)?.play()
///
/// // Stop playback later
/// speaker?.getComponent(AudioSource.self)?.stop()
/// ```
///
/// - Note: Audio clips must be loaded before being assigned to an AudioSource.
/// - Important: The AudioSource automatically manages its connection to the AudioEngine,
///   including cleanup when destroyed.
public class AudioSource: Component {
    override var order: ComponentOrder {
        .other
    }

    private var soundPlayer = AVAudioPlayerNode()

    /// The volume of the audio source.
    ///
    /// Controls the playback volume for this audio source. The value ranges from `0.0` (silent)
    /// to `1.0` (maximum volume). Changes take effect immediately.
    ///
    /// ## Example
    ///
    /// ```swift
    /// audioSource.volume = 0.5  // 50% volume
    /// audioSource.volume = 1.0  // Full volume
    /// audioSource.volume = 0.0  // Muted
    /// ```
    public var volume: Float = 1 {
        didSet {
            self.soundPlayer.volume = self.volume
        }
    }

    /// A custom 3D position for the audio source.
    ///
    /// When set, this overrides the position of the GameObject's transform and places the
    /// audio source at a specific location in 3D space for spatial audio calculations.
    /// Set to `nil` to use the GameObject's transform position instead.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Position audio at a fixed location
    /// audioSource.customPosition = Vector3(x: 10, y: 5, z: 0)
    ///
    /// // Reset to use GameObject's position
    /// audioSource.customPosition = nil
    /// ```
    public var customPosition: Vector3? {
        didSet {
            self.soundPlayer.position = self.customPosition?.toAVAudio3DPoint() ?? self.soundPlayer.position
        }
    }

    /// The audio clip to play.
    ///
    /// Assigning a new clip will disconnect any previously assigned clip from the audio engine
    /// and connect the new clip. The clip is scheduled for playback according to its `playType`
    /// (once or looping). Call ``play()`` to start playback after assigning a clip.
    ///
    /// ## Example
    ///
    /// ```swift
    /// guard let clip = AudioClip(fileName: "explosion.wav") else { return }
    /// audioSource.clip = clip
    /// audioSource.play()
    /// ```
    public var clip: AudioClip? {
        didSet {
            let engine = AudioEngine.sharedInstance

            if let oldValue {
                engine.disconnectNodeOutput(self.soundPlayer, bus: oldValue.bus)
            }

            guard let clip,
                  let buffer = clip.buffer
            else { return }

            engine.connect(self.soundPlayer, to: engine.environment, fromBus: 0, toBus: clip.bus, format: engine.format)
            engine.startEngine()

            switch clip.playType {
            case .loop:
                self.soundPlayer.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            case .playOnce:
                self.soundPlayer.scheduleBuffer(buffer, at: nil)
            }
        }
    }

    /// Called when the component is initialized.
    ///
    /// Attaches the internal audio player node to the shared audio engine during the awake phase.
    override public func awake() {
        let engine = AudioEngine.sharedInstance
        engine.attach(self.soundPlayer)
    }

    /// Configures the audio source using a closure.
    ///
    /// Provides a convenient way to configure multiple properties in a single chained call.
    /// The closure receives the audio source instance for configuration.
    ///
    /// - Parameter configurationBlock: A closure that receives and configures this audio source.
    /// - Returns: This audio source for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// audioSource.configure { source in
    ///     source.volume = 0.7
    ///     guard let clip = AudioClip(fileName: "sound.wav") else { return }
    ///     source.clip = clip
    /// }
    /// ```
    @discardableResult public func configure(_ configurationBlock: (AudioSource) -> Void) -> AudioSource {
        configurationBlock(self)
        return self
    }

    /// Sets the volume of the audio source.
    ///
    /// - Parameter volume: The volume level from `0.0` (silent) to `1.0` (maximum).
    /// - Returns: This audio source for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// audioSource
    ///     .set(volume: 0.8)
    ///     .play()
    /// ```
    @discardableResult public func set(volume: Float) -> AudioSource {
        self.volume = volume
        return self
    }

    /// Sets the audio clip to play.
    ///
    /// - Parameter clip: The audio clip to assign to this source.
    /// - Returns: This audio source for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// guard let clip = AudioClip(fileName: "music.mp3", playType: .loop) else { return }
    /// audioSource
    ///     .set(clip: clip)
    ///     .set(volume: 0.5)
    ///     .play()
    /// ```
    @discardableResult public func set(clip: AudioClip) -> AudioSource {
        self.clip = clip
        return self
    }

    /// Sets a custom 3D position for the audio source.
    ///
    /// - Parameter customPosition: The 3D position where the audio should be positioned.
    /// - Returns: This audio source for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// audioSource
    ///     .set(customPosition: Vector3(x: 5, y: 0, z: 10))
    ///     .play()
    /// ```
    @discardableResult public func set(customPosition: Vector3) -> AudioSource {
        self.customPosition = customPosition
        return self
    }

    /// Called when the component is destroyed.
    ///
    /// Stops playback, disconnects the audio player from the engine, and detaches the player node.
    /// This ensures proper cleanup of audio resources.
    override public func onDestroy() {
        self.stop()
        let engine = AudioEngine.sharedInstance
        if let clip {
            engine.disconnectNodeOutput(self.soundPlayer, bus: clip.bus)
        }
        engine.detach(self.soundPlayer)
    }

    /// Starts audio playback.
    ///
    /// Begins playing the assigned audio clip. If no clip is assigned, this method has no effect.
    /// The clip plays according to its configured `playType` (once or looping).
    ///
    /// ## Example
    ///
    /// ```swift
    /// guard let clip = AudioClip(fileName: "sound.wav") else { return }
    /// audioSource.clip = clip
    /// audioSource.play()
    /// ```
    public func play() {
        self.soundPlayer.play()
    }

    /// Stops audio playback.
    ///
    /// Immediately stops playing the current audio clip. The clip can be played again by calling ``play()``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Stop the sound effect
    /// audioSource.stop()
    ///
    /// // Play it again later
    /// audioSource.play()
    /// ```
    public func stop() {
        self.soundPlayer.stop()
    }
}
