
import AVKit

public class AudioClip {

    private(set) internal var file: AVAudioFile?
    public let filename: String

    public init?(fileName: String, bundle: Bundle = Bundle.main) {

        guard let audioUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
            else { return nil }

        do {
            file = try AVAudioFile(forReading: audioUrl)
            self.filename = fileName
        } catch {
            return nil
        }
    }
}

