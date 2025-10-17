import AVKit

/// Represents an audio file that can be played by an `AudioSource`.
///
/// `AudioClip` encapsulates audio data loaded from a file in your app bundle or custom location.
/// It loads the audio file into memory as a PCM buffer and prepares it for playback through the
/// shared `AudioEngine`. The clip can be configured to play once or loop continuously.
///
/// ## Topics
///
/// ### Creating an Audio Clip
/// - ``init(fileName:playType:bundle:)``
///
/// ### Configuring Playback
/// - ``PlayType``
/// - ``playType``
///
/// ### Accessing Audio Properties
/// - ``filename``
/// - ``bus``
/// - ``buffer``
///
/// ## Example
///
/// ```swift
/// // Load a sound effect that plays once
/// guard let jumpSound = AudioClip(fileName: "jump.wav", playType: .playOnce) else {
///     print("Failed to load jump sound")
///     return
/// }
///
/// // Load background music that loops
/// guard let bgMusic = AudioClip(fileName: "background.mp3", playType: .loop) else {
///     print("Failed to load background music")
///     return
/// }
///
/// // Assign to an AudioSource
/// audioSource.clip = jumpSound
/// audioSource.play()
/// ```
public class AudioClip {
    /// Defines how an audio clip should be played.
    ///
    /// Use this enumeration to specify whether an audio clip should play once and stop,
    /// or loop continuously until manually stopped.
    public enum PlayType {
        /// Play the audio clip once and stop.
        case playOnce

        /// Loop the audio clip continuously until stopped.
        case loop
    }

    /// The playback behavior for this audio clip.
    ///
    /// Determines whether the clip plays once or loops continuously. This can be changed
    /// after initialization to modify playback behavior.
    public var playType: PlayType = .playOnce

    /// The audio engine bus number assigned to this clip.
    ///
    /// Each audio clip is assigned a unique bus number from the shared `AudioEngine`
    /// for routing audio through the engine's mixer.
    private(set) var bus: Int = 0

    /// The PCM audio buffer containing the loaded audio data.
    ///
    /// This buffer holds the actual audio samples in memory, ready for playback.
    /// The buffer is created with the format required by the `AudioEngine`.
    private(set) var buffer: AVAudioPCMBuffer?

    /// The original filename used to load this audio clip.
    ///
    /// This property stores the filename parameter passed during initialization,
    /// useful for debugging and identifying clips.
    public let filename: String

    /// Creates an audio clip from a file in the specified bundle.
    ///
    /// Loads an audio file from disk and prepares it for playback. The file is read into
    /// a PCM buffer using the shared `AudioEngine`'s format. If any step fails (file not found,
    /// invalid format, or read error), initialization returns `nil`.
    ///
    /// - Parameters:
    ///   - fileName: The name of the audio file to load. Can include or omit the file extension.
    ///   - playType: The playback behavior for this clip. Defaults to `.playOnce`.
    ///   - bundle: The bundle containing the audio file. Defaults to the main app bundle.
    ///
    /// - Returns: An initialized `AudioClip` if successful, or `nil` if the file couldn't be loaded.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Load from main bundle
    /// let sound = AudioClip(fileName: "explosion.wav")
    ///
    /// // Load with explicit play type
    /// let music = AudioClip(fileName: "theme.mp3", playType: .loop)
    ///
    /// // Load from custom bundle
    /// let customBundle = Bundle(identifier: "com.example.sounds")!
    /// let effect = AudioClip(fileName: "laser.wav", bundle: customBundle)
    /// ```
    public init?(fileName: String, playType: PlayType = .playOnce, bundle: Bundle = Bundle.main) {
        guard let audioUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
        else { return nil }

        do {
            let file = try AVAudioFile(forReading: audioUrl)
            guard let format = AudioEngine.sharedInstance.format,
                  // AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false),
                  let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
            else { return nil }

            try file.read(into: buffer)

            let engine = AudioEngine.sharedInstance
            self.bus = engine.environment.nextAvailableInputBus
            self.buffer = buffer
            self.filename = fileName
            self.playType = playType
        } catch {
            return nil
        }
    }
}
