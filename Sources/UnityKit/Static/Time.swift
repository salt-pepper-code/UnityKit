import Foundation

public class Time {
    /// Delta time between frames (affected by timeScale)
    public internal(set) static var deltaTime: TimeInterval = 0

    /// Total elapsed time since game start (affected by timeScale)
    public internal(set) static var time: TimeInterval = 0

    /// Scale at which time passes (1.0 = normal, 0.0 = pause, 0.5 = slow motion)
    public static var timeScale: Double = 1.0

    /// Delta time between frames (unaffected by timeScale)
    public internal(set) static var unscaledDeltaTime: TimeInterval = 0

    /// Total frames rendered since game start
    public internal(set) static var frameCount: Int = 0

    @discardableResult static func evaluateTime(_ start: DispatchTime) -> TimeInterval {
        let nanoTime = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = TimeInterval(nanoTime) / 1_000_000_000

        Debug.debug("Time to evaluate: \(timeInterval) seconds")

        return timeInterval
    }
}

// MARK: - Testing Helpers

extension Time {
    /// Test-only helper to reset time values
    static func resetForTesting() {
        self.deltaTime = 0
        self.time = 0
        self.unscaledDeltaTime = 0
        self.frameCount = 0
        self.timeScale = 1.0
    }

    /// Test-only helper to simulate a frame update
    static func simulateFrame(realDelta: TimeInterval) {
        self.unscaledDeltaTime = realDelta
        self.deltaTime = realDelta * self.timeScale
        self.time += self.deltaTime
        self.frameCount += 1
    }
}
