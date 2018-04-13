import AVKit

public class AudioSource: Component {
    private var soundPlayer = AVAudioPlayerNode()

    public var volume: Float = 1 {
        didSet {
            soundPlayer.volume = volume
        }
    }

    public var customPosition: Vector3? {
        didSet {
            soundPlayer.position = customPosition?.toAVAudio3DPoint() ?? soundPlayer.position
        }
    }

    public var clip: AudioClip? {
        didSet {
            let engine = AudioEngine.sharedInstance

            if let oldValue = oldValue {
                engine.disconnectNodeOutput(soundPlayer, bus: oldValue.bus)
            }

            guard let clip = clip,
                let buffer = clip.buffer
                else { return }

            engine.connect(soundPlayer, to: engine.environment, fromBus: 0, toBus: clip.bus, format: engine.format)
            engine.startEngine()

            switch clip.playType {
            case .loop:
                soundPlayer.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            case .playOnce:
                soundPlayer.scheduleBuffer(buffer, at: nil)
            }
        }
    }

    public required init() {
        super.init()
        self.ignoreUpdates = true
    }
    
    public override func awake() {
        let engine = AudioEngine.sharedInstance
        engine.attach(soundPlayer)
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
        - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (AudioSource) -> ()) -> AudioSource {

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

    public override func onDestroy() {
        stop()
        let engine = AudioEngine.sharedInstance
        if let clip = clip {
            engine.disconnectNodeOutput(soundPlayer, bus: clip.bus)
        }
        engine.detach(soundPlayer)
    }

    public func play() {
        soundPlayer.play()
    }

    public func stop() {
        soundPlayer.stop()
    }
}
