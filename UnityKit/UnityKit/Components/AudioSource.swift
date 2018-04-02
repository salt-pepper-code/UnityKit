
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

            guard let clip = clip,
                let file = clip.file
                else { return }

            let engine = AudioEngine.sharedInstance
            engine.connect(soundPlayer, to: engine.environment, format: engine.format)
            engine.startEngine()

            guard let sampleRate = engine.format?.sampleRate
                else { return }

            let completion: AVAudioNodeCompletionHandler?
            switch clip.playType {
            case .loop:
                completion = { [weak self] in
                    DispatchQueue.main.async {
                        let sampleTime = AVAudioFramePosition(0)
                        let startTime = AVAudioTime(hostTime: mach_absolute_time(), sampleTime: sampleTime, atRate: sampleRate)
                        self?.soundPlayer.play(at: startTime)
                    }
                }
            case .playOnce:
                completion = nil
            }

            soundPlayer.scheduleFile(file, at: nil, completionHandler: completion)
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
