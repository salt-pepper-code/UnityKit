import Foundation

public class Time {
    internal(set) public static var deltaTime: TimeInterval = 0

    @discardableResult internal static func evaluateTime(_ start: DispatchTime) -> TimeInterval {
        let nanoTime = DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = TimeInterval(nanoTime) / 1_000_000_000

        Debug.log("Time to evaluate: \(timeInterval) seconds")

        return timeInterval
    }
}
