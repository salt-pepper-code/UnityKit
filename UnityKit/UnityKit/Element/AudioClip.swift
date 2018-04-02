
import AVKit

public class AudioClip {

    public enum PlayType {
        case playOnce
        case loop
    }

    public var playType: PlayType = .playOnce
    
    private(set) internal var file: AVAudioFile?
    public let filename: String

    public init?(fileName: String, playType: PlayType = .playOnce, bundle: Bundle = Bundle.main) {

        guard let audioUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
            else { return nil }

        do {
            file = try AVAudioFile(forReading: audioUrl)
            self.filename = fileName
            self.playType = playType
        } catch {
            return nil
        }
    }
}

