import Foundation

/// Helper utilities for async testing
enum TestHelpers {
    /// Async wait durations for testing
    enum WaitDuration {
        case tiny   // 10ms
        case small  // 50ms
        case long   // 200ms

        var nanoseconds: UInt64 {
            switch self {
            case .tiny:  return 10_000_000   // 10ms
            case .small: return 50_000_000   // 50ms
            case .long:  return 200_000_000  // 200ms
            }
        }

        var seconds: TimeInterval {
            return TimeInterval(nanoseconds) / 1_000_000_000
        }
    }

    /// Async wait helper for testing
    /// - Parameter duration: The wait duration
    static func wait(_ duration: WaitDuration) async {
        try? await Task.sleep(nanoseconds: duration.nanoseconds)
    }
}
