import Foundation
import Testing
@testable import UnityKit

@Suite("Time System", .serialized)
struct TimeTests {
    @Test("Time properties have correct initial values")
    func initialValues() {
        Time.resetForTesting()

        #expect(Time.time == 0)
        #expect(Time.deltaTime == 0)
        #expect(Time.unscaledDeltaTime == 0)
        #expect(Time.frameCount == 0)
        #expect(Time.timeScale == 1.0)
    }

    @Test("Time.timeScale affects deltaTime but not unscaledDeltaTime")
    func timeScaleAffectsDeltaTime() {
        Time.resetForTesting()

        // Simulate normal frame at 60fps
        Time.simulateFrame(realDelta: 0.016)

        #expect(abs(Time.unscaledDeltaTime - 0.016) < 0.0001)
        #expect(abs(Time.deltaTime - 0.016) < 0.0001)
        #expect(abs(Time.time - 0.016) < 0.0001)
        #expect(Time.frameCount == 1)
    }

    @Test("Time.timeScale at 0.5 creates slow motion")
    func timeScaleSlowMotion() {
        Time.resetForTesting()
        Time.timeScale = 0.5

        Time.simulateFrame(realDelta: 0.016)

        #expect(abs(Time.unscaledDeltaTime - 0.016) < 0.0001)
        #expect(abs(Time.deltaTime - 0.008) < 0.0001) // Half speed
        #expect(abs(Time.time - 0.008) < 0.0001)
    }

    @Test("Time.timeScale at 2.0 creates fast forward")
    func timeScaleFastForward() {
        Time.resetForTesting()
        Time.timeScale = 2.0

        Time.simulateFrame(realDelta: 0.016)

        #expect(abs(Time.unscaledDeltaTime - 0.016) < 0.0001)
        #expect(abs(Time.deltaTime - 0.032) < 0.0001) // Double speed
        #expect(abs(Time.time - 0.032) < 0.0001)
    }

    @Test("Time.timeScale at 0 pauses time")
    func timeScalePause() {
        Time.resetForTesting()
        Time.timeScale = 0

        Time.simulateFrame(realDelta: 0.016)

        #expect(abs(Time.unscaledDeltaTime - 0.016) < 0.0001)
        #expect(abs(Time.deltaTime - 0.0) < 0.0001) // Paused
        #expect(abs(Time.time - 0.0) < 0.0001) // Time doesn't advance
    }

    @Test("Frame count increments correctly")
    func frameCountIncrements() {
        Time.resetForTesting()

        // Simulate 3 frames
        for _ in 0..<3 {
            Time.simulateFrame(realDelta: 0.016)
        }

        #expect(Time.frameCount == 3)
    }

    @Test("Time accumulates correctly over multiple frames")
    func timeAccumulation() {
        Time.resetForTesting()

        // Simulate 10 frames at 60fps (0.016s each)
        for _ in 0..<10 {
            Time.simulateFrame(realDelta: 0.016)
        }

        #expect(abs(Time.time - 0.16) < 0.001) // 10 frames * 0.016s
    }

    @Test("Unscaled time is independent of timeScale")
    func unscaledTimeIndependence() {
        Time.resetForTesting()
        Time.timeScale = 0.25 // Quarter speed

        Time.simulateFrame(realDelta: 0.020)

        // Unscaled should always match real delta
        #expect(abs(Time.unscaledDeltaTime - 0.020) < 0.0001)

        // Scaled should be affected
        #expect(abs(Time.deltaTime - 0.005) < 0.0001)
    }
}
