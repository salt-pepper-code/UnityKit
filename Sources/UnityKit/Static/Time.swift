import Foundation

public class Time {
    /// Delta time between frames (affected by timeScale)
    internal(set) public static var deltaTime: TimeInterval = 0

    /// Total elapsed time since game start (affected by timeScale)
    internal(set) public static var time: TimeInterval = 0

    /// Scale at which time passes (1.0 = normal, 0.0 = pause, 0.5 = slow motion)
    public static var timeScale: Double = 1.0

    /// Delta time between frames (unaffected by timeScale)
    internal(set) public static var unscaledDeltaTime: TimeInterval = 0

    /// Total frames rendered since game start
    internal(set) public static var frameCount: Int = 0

    @discardableResult internal static func evaluateTime(_ start: DispatchTime) -> TimeInterval {
        let nanoTime = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = TimeInterval(nanoTime) / 1_000_000_000

        Debug.debug("Time to evaluate: \(timeInterval) seconds")

        return timeInterval
    }
}

// MARK: - Testing Helpers
extension Time {
    /// Test-only helper to reset time values
    internal static func resetForTesting() {
        deltaTime = 0
        time = 0
        unscaledDeltaTime = 0
        frameCount = 0
        timeScale = 1.0
    }

    /// Test-only helper to simulate a frame update
    internal static func simulateFrame(realDelta: TimeInterval) {
        unscaledDeltaTime = realDelta
        deltaTime = realDelta * timeScale
        time += deltaTime
        frameCount += 1
    }
}
