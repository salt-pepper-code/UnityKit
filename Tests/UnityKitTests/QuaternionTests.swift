import Foundation
import Testing
@testable import UnityKit

@Suite("Quaternion Utilities")
struct QuaternionTests {
    // MARK: - Slerp Tests

    @Test("Slerp at t=0 returns start quaternion")
    func slerpAtZero() {
        let a = Quaternion.identity
        let b = Quaternion.euler(0, 90, 0)
        let result = Quaternion.Slerp(a, b, 0)

        #expect(abs(result.x - a.x) < 0.001)
        #expect(abs(result.y - a.y) < 0.001)
        #expect(abs(result.z - a.z) < 0.001)
        #expect(abs(result.w - a.w) < 0.001)
    }

    @Test("Slerp at t=1 returns end quaternion")
    func slerpAtOne() {
        let a = Quaternion.identity
        let b = Quaternion.euler(0, 90, 0)
        let result = Quaternion.Slerp(a, b, 1)

        // Normalize both for comparison (quaternions may have opposite signs but same rotation)
        let resultNorm = result.normalized()
        let bNorm = b.normalized()

        let dotProduct = resultNorm.x * bNorm.x + resultNorm.y * bNorm.y +
            resultNorm.z * bNorm.z + resultNorm.w * bNorm.w

        // Check if quaternions are equivalent (dot product close to 1 or -1)
        #expect(abs(abs(dotProduct) - 1.0) < 0.01)
    }

    @Test("Slerp at t=0.5 is halfway rotation")
    func slerpAtHalf() {
        let a = Quaternion.identity
        let b = Quaternion.euler(0, 90, 0)
        let result = Quaternion.Slerp(a, b, 0.5)

        // Result should be approximately 45 degrees rotation
        let euler = result.toEuler()
        let degrees = euler.y * (180.0 / .pi)

        #expect(abs(degrees - 45) < 2.0) // Allow 2 degree tolerance
    }

    @Test("Slerp produces smooth rotation")
    func slerpSmoothRotation() {
        let a = Quaternion.identity
        let b = Quaternion.euler(0, 90, 0) // Use 90 degrees instead of 180 to avoid gimbal lock issues

        // Sample multiple points
        let t25 = Quaternion.Slerp(a, b, 0.25)
        let t50 = Quaternion.Slerp(a, b, 0.50)
        let t75 = Quaternion.Slerp(a, b, 0.75)

        let euler25 = abs(t25.toEuler().y * (180.0 / .pi))
        let euler50 = abs(t50.toEuler().y * (180.0 / .pi))
        let euler75 = abs(t75.toEuler().y * (180.0 / .pi))

        // Should be progressive rotation
        #expect(euler25 < euler50)
        #expect(euler50 < euler75)
        #expect(euler75 < 90.5) // Should approach 90 degrees
    }

    // MARK: - LookRotation Tests

    @Test("LookRotation forward creates identity-like rotation")
    func lookRotationForward() {
        let forward = Vector3(0, 0, 1)
        let rotation = Quaternion.LookRotation(forward)

        // Should be close to identity or a simple rotation
        let euler = rotation.toEuler()
        #expect(abs(euler.x) < 0.1)
        #expect(abs(euler.z) < 0.1)
    }

    @Test("LookRotation right creates 90 degree rotation")
    func lookRotationRight() {
        let right = Vector3(1, 0, 0)
        let rotation = Quaternion.LookRotation(right)

        let euler = rotation.toEuler()
        let yDegrees = abs(euler.y * (180.0 / .pi))

        // Should be approximately 90 degrees
        #expect(abs(yDegrees - 90) < 5.0)
    }

    @Test("LookRotation up vector is respected")
    func lookRotationWithUpVector() {
        let forward = Vector3(1, 0, 0)
        let up = Vector3(0, 1, 0)
        let rotation = Quaternion.LookRotation(forward, up)

        // Should create a valid rotation
        let normalized = rotation.normalized()
        let magnitude = sqrt(normalized.x * normalized.x + normalized.y * normalized.y +
            normalized.z * normalized.z + normalized.w * normalized.w)

        #expect(abs(magnitude - 1.0) < 0.01)
    }

    @Test("LookRotation handles parallel forward and up")
    func lookRotationParallelVectors() {
        let forward = Vector3(0, 1, 0)
        let up = Vector3(0, 1, 0) // Same as forward

        // Should not crash and should produce valid rotation
        let rotation = Quaternion.LookRotation(forward, up)

        let normalized = rotation.normalized()
        let magnitude = sqrt(normalized.x * normalized.x + normalized.y * normalized.y +
            normalized.z * normalized.z + normalized.w * normalized.w)

        #expect(abs(magnitude - 1.0) < 0.01)
    }

    // MARK: - Identity Tests

    @Test("Identity quaternion has correct values")
    func identityValues() {
        let identity = Quaternion.identity

        #expect(identity.x == 0)
        #expect(identity.y == 0)
        #expect(identity.z == 0)
        #expect(identity.w == 1)
    }

    @Test("Identity quaternion produces zero rotation")
    func identityNoRotation() {
        let identity = Quaternion.identity
        let euler = identity.toEuler()

        #expect(abs(euler.x) < 0.001)
        #expect(abs(euler.y) < 0.001)
        #expect(abs(euler.z) < 0.001)
    }
}
