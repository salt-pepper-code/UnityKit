
import AVKit

internal class AudioEngine: AVAudioEngine {

    internal static let sharedInstance = AudioEngine()
    internal var environment = AVAudioEnvironmentNode()
    internal var format: AVAudioFormat?

    override init() {

        super.init()

        let sessionInstance = AVAudioSession.sharedInstance()
        let hardwareSampleRate = environment.outputFormat(forBus: 0).sampleRate
        let maxChannels = sessionInstance.maximumOutputNumberOfChannels
        format = AVAudioFormat(standardFormatWithSampleRate: hardwareSampleRate, channels: AVAudioChannelCount(maxChannels))
        
        do {
            try sessionInstance.setCategory(AVAudioSessionCategoryPlayback)
            try sessionInstance.setPreferredOutputNumberOfChannels(min(8, maxChannels))
            try sessionInstance.setActive(true)
        } catch {}

        attach(environment)
        connect(environment, to: outputNode, format: format)
    }

    internal func startEngine() {

        guard !isRunning
            else { return }

        prepare()

        do { try start() }
        catch {}
    }
}
