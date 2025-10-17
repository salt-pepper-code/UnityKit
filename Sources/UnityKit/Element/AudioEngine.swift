import AVKit

class AudioEngine: AVAudioEngine {
    static let sharedInstance = AudioEngine()
    var environment = AVAudioEnvironmentNode()
    var format: AVAudioFormat?

    override init() {
        super.init()

        let sessionInstance = AVAudioSession.sharedInstance()
        let hardwareSampleRate = self.environment.outputFormat(forBus: 0).sampleRate
        let maxChannels = sessionInstance.maximumOutputNumberOfChannels
        self.format = AVAudioFormat(
            standardFormatWithSampleRate: hardwareSampleRate,
            channels: AVAudioChannelCount(maxChannels)
        )

        do {
            try sessionInstance
                .setCategory(AVAudioSession
                    .Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try sessionInstance.setPreferredOutputNumberOfChannels(min(8, maxChannels))
            try sessionInstance.setActive(true)
        } catch {}

        attach(self.environment)
        connect(self.environment, to: outputNode, format: self.format)
    }

    func startEngine() {
        guard !isRunning
        else { return }

        prepare()

        do { try start() } catch {}
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
