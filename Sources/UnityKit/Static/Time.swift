import Foundation

/// Provides access to time-related information for your game or application.
///
/// The `Time` class offers static properties to track frame timing, elapsed time, and time scaling.
/// Use these properties to create frame-rate independent movement, implement pause functionality,
/// and create time-based effects.
///
/// ## Overview
///
/// Time information is automatically updated by the game engine each frame. All time values are
/// measured in seconds unless otherwise specified.
///
/// ## Topics
///
/// ### Frame Timing
/// - ``deltaTime``
/// - ``unscaledDeltaTime``
/// - ``frameCount``
///
/// ### Elapsed Time
/// - ``time``
///
/// ### Time Control
/// - ``timeScale``
///
/// ## Example Usage
///
/// ```swift
/// // Frame-rate independent movement
/// func update() {
///     let speed: Float = 5.0
///     transform.position.x += speed * Time.deltaTime
/// }
///
/// // Pause the game
/// Time.timeScale = 0.0
///
/// // Resume normal speed
/// Time.timeScale = 1.0
///
/// // Slow motion effect
/// Time.timeScale = 0.5
/// ```
public class Time {
    /// The interval in seconds from the last frame to the current one.
    ///
    /// This value is affected by ``timeScale``. Use this for frame-rate independent movement
    /// and calculations that should be affected by time scaling.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Move object at constant speed regardless of frame rate
    /// func update() {
    ///     let speed: Float = 10.0
    ///     position.x += speed * Time.deltaTime
    /// }
    /// ```
    public internal(set) static var deltaTime: TimeInterval = 0

    /// The total time in seconds since the game started.
    ///
    /// This value is affected by ``timeScale`` and accumulates scaled delta time each frame.
    /// When time is paused (timeScale = 0), this value stops increasing.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Check if 5 seconds have passed
    /// if Time.time > 5.0 {
    ///     print("Game has been running for 5 seconds")
    /// }
    /// ```
    public internal(set) static var time: TimeInterval = 0

    /// The scale at which time passes.
    ///
    /// This can be used to create slow motion effects or to pause the game.
    /// - A value of `1.0` represents normal time speed
    /// - A value of `0.0` effectively pauses time-based updates
    /// - A value of `0.5` runs at half speed (slow motion)
    /// - A value of `2.0` runs at double speed
    ///
    /// This affects ``deltaTime`` and ``time``, but does not affect ``unscaledDeltaTime``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Pause the game
    /// Time.timeScale = 0.0
    ///
    /// // Slow motion effect
    /// Time.timeScale = 0.5
    ///
    /// // Fast forward
    /// Time.timeScale = 2.0
    ///
    /// // Resume normal speed
    /// Time.timeScale = 1.0
    /// ```
    public static var timeScale: Double = 1.0

    /// The interval in seconds from the last frame to the current one, unaffected by time scaling.
    ///
    /// This value is not affected by ``timeScale``. Use this for UI animations, timers, or other
    /// elements that should continue running normally even when the game is paused or in slow motion.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // UI animation that continues during pause
    /// func updateUI() {
    ///     loadingSpinner.rotation += 180.0 * Time.unscaledDeltaTime
    /// }
    /// ```
    public internal(set) static var unscaledDeltaTime: TimeInterval = 0

    /// The total number of frames that have been rendered since the game started.
    ///
    /// This counter increments by 1 each frame, regardless of ``timeScale``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Execute logic every 60 frames
    /// if Time.frameCount % 60 == 0 {
    ///     performPeriodicUpdate()
    /// }
    /// ```
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
