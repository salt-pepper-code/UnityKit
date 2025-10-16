import Foundation

/// Thread-safe wrapper for shared mutable state
/// Follows Unity's Input pattern: concurrent reads, exclusive writes from single thread
public final class Synchronized<Value> {
    private let queue: DispatchQueue
    private var value: Value

    public init(_ value: Value, label: String, qos: DispatchQoS = .userInitiated) {
        self.value = value
        self.queue = DispatchQueue(label: label, qos: qos, attributes: .concurrent)
    }

    /// Perform a read operation (allows concurrent reads)
    public func read<T>(_ block: (Value) -> T) -> T {
        return queue.sync {
            return block(self.value)
        }
    }

    /// Perform a write operation (exclusive access via barrier)
    /// Synchronous to ensure writes complete before returning (Unity pattern: main thread writes)
    public func write(_ block: (inout Value) -> Void) {
        queue.sync(flags: .barrier) {
            block(&self.value)
        }
    }
}
