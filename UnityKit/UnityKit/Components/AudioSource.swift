
import AVKit

public class AudioSource: Component {

    private var soundPlayer = AVAudioPlayerNode()

    public var volume: Float = 1 {
        didSet {
            soundPlayer.volume = volume
        }
    }

    public var customPosition: Vector3?{
        didSet {
            soundPlayer.position = customPosition?.toAVAudio3DPoint() ?? soundPlayer.position
        }
    }

    public var clip: AudioClip? {

        didSet {

            guard let file = clip?.file
                else { return }

            print(clip!.filename)
            let engine = AudioEngine.sharedInstance
            engine.connect(soundPlayer, to: engine.environment, format: engine.format)
            engine.startEngine()
            soundPlayer.scheduleFile(file, at: nil, completionHandler: nil)
        }
    }

    public override func awake() {

        let engine = AudioEngine.sharedInstance
        engine.attach(soundPlayer)
    }

    @discardableResult public func configure(_ completionBlock: (AudioSource) -> ()) -> AudioSource {

        completionBlock(self)
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

        soundPlayer.stop()
        AudioEngine.sharedInstance.detach(soundPlayer)
    }

    public func play() {
        soundPlayer.play()
    }

    public func stop() {
        soundPlayer.stop()
    }
}
