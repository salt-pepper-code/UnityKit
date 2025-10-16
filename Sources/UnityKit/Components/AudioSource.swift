import AVKit

/**
 A representation of audio sources in 3D.
 */
public class AudioSource: Component {
    override var order: ComponentOrder {
        .other
    }

    private var soundPlayer = AVAudioPlayerNode()

    public var volume: Float = 1 {
        didSet {
            self.soundPlayer.volume = self.volume
        }
    }

    public var customPosition: Vector3? {
        didSet {
            self.soundPlayer.position = self.customPosition?.toAVAudio3DPoint() ?? self.soundPlayer.position
        }
    }

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

    override public func awake() {
        let engine = AudioEngine.sharedInstance
        engine.attach(self.soundPlayer)
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
     - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (AudioSource) -> Void) -> AudioSource {
        configurationBlock(self)
        return self
    }

    @discardableResult public func set(volume: Float) -> AudioSource {
        self.volume = volume
        return self
    }

    @discardableResult public func set(clip: AudioClip) -> AudioSource {
        self.clip = clip
        return self
    }

    @discardableResult public func set(customPosition: Vector3) -> AudioSource {
        self.customPosition = customPosition
        return self
    }

    override public func onDestroy() {
        self.stop()
        let engine = AudioEngine.sharedInstance
        if let clip {
            engine.disconnectNodeOutput(self.soundPlayer, bus: clip.bus)
        }
        engine.detach(self.soundPlayer)
    }

    public func play() {
        self.soundPlayer.play()
    }

    public func stop() {
        self.soundPlayer.stop()
    }
}
