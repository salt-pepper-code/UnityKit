
import AVKit

public class AudioClip {

    public enum PlayType {
        case playOnce
        case loop
    }

    public var playType: PlayType = .playOnce
    
    private(set) internal var buffer: AVAudioPCMBuffer?
    public let filename: String

    public init?(fileName: String, playType: PlayType = .playOnce, bundle: Bundle = Bundle.main) {

        guard let audioUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
            else { return nil }

        do {
            let file = try AVAudioFile(forReading: audioUrl)
            guard let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false),
                let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(file.length))
                else { return nil }

            try file.read(into: buffer)

            self.buffer = buffer
            self.filename = fileName
            self.playType = playType

        } catch {
            return nil
        }
    }
}

