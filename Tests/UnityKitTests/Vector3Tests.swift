import Testing
@testable import UnityKit

@Suite("Vector3 Utilities")
struct Vector3Tests {
    // MARK: - Lerp Tests

    @Test("Lerp at t=0 returns start vector")
    func lerpAtZero() {
        let a = Vector3(0, 0, 0)
        let b = Vector3(10, 10, 10)
        let result = Vector3.Lerp(a, b, 0)

        #expect(abs(result.x - 0) < 0.001)
        #expect(abs(result.y - 0) < 0.001)
        #expect(abs(result.z - 0) < 0.001)
    }

    @Test("Lerp at t=1 returns end vector")
    func lerpAtOne() {
        let a = Vector3(0, 0, 0)
        let b = Vector3(10, 10, 10)
        let result = Vector3.Lerp(a, b, 1)

        #expect(abs(result.x - 10) < 0.001)
        #expect(abs(result.y - 10) < 0.001)
        #expect(abs(result.z - 10) < 0.001)
    }

    @Test("Lerp at t=0.5 returns midpoint")
    func lerpAtHalf() {
        let a = Vector3(0, 0, 0)
        let b = Vector3(10, 10, 10)
        let result = Vector3.Lerp(a, b, 0.5)

        #expect(abs(result.x - 5) < 0.001)
        #expect(abs(result.y - 5) < 0.001)
        #expect(abs(result.z - 5) < 0.001)
    }

    @Test("Lerp clamps t > 1")
    func lerpClampsAboveOne() {
        let a = Vector3(0, 0, 0)
        let b = Vector3(10, 10, 10)
        let result = Vector3.Lerp(a, b, 2.0)

        #expect(abs(result.x - 10) < 0.001)
        #expect(abs(result.y - 10) < 0.001)
        #expect(abs(result.z - 10) < 0.001)
    }

    @Test("Lerp clamps t < 0")
    func lerpClampsBelowZero() {
        let a = Vector3(0, 0, 0)
        let b = Vector3(10, 10, 10)
        let result = Vector3.Lerp(a, b, -1.0)

        #expect(abs(result.x - 0) < 0.001)
        #expect(abs(result.y - 0) < 0.001)
        #expect(abs(result.z - 0) < 0.001)
    }

    // MARK: - Angle Tests

    @Test("Angle between parallel vectors is 0 degrees")
    func angleParallel() {
        let forward1 = Vector3(0, 0, 1)
        let forward2 = Vector3(0, 0, 2)
        let angle = Vector3.Angle(forward1, forward2)

        #expect(abs(angle - 0) < 0.001)
    }

    @Test("Angle between perpendicular vectors is 90 degrees")
    func anglePerpendicular() {
        let right = Vector3(1, 0, 0)
        let up = Vector3(0, 1, 0)
        let angle = Vector3.Angle(right, up)

        #expect(abs(angle - 90) < 0.001)
    }

    @Test("Angle between opposite vectors is 180 degrees")
    func angleOpposite() {
        let forward = Vector3(0, 0, 1)
        let backward = Vector3(0, 0, -1)
        let angle = Vector3.Angle(forward, backward)

        #expect(abs(angle - 180) < 0.001)
    }

    @Test("Angle at 45 degrees")
    func angle45Degrees() {
        let v1 = Vector3(1, 0, 0)
        let v2 = Vector3(1, 1, 0).normalized()
        let angle = Vector3.Angle(v1, v2)

        #expect(abs(angle - 45) < 0.1)
    }

    @Test("Angle with zero vector returns 0")
    func angleWithZeroVector() {
        let zero = Vector3.zero
        let nonZero = Vector3(1, 0, 0)
        let angle = Vector3.Angle(zero, nonZero)

        #expect(abs(angle - 0) < 0.001)
    }

    // MARK: - MoveTowards Tests

    @Test("MoveTowards partial distance")
    func moveTowardsPartial() {
        let current = Vector3(0, 0, 0)
        let target = Vector3(10, 0, 0)
        let result = Vector3.MoveTowards(current, target, 5)

        #expect(abs(result.x - 5) < 0.001)
        #expect(abs(result.y - 0) < 0.001)
        #expect(abs(result.z - 0) < 0.001)
    }

    @Test("MoveTowards exact distance reaches target")
    func moveTowardsExact() {
        let current = Vector3(0, 0, 0)
        let target = Vector3(10, 0, 0)
        let result = Vector3.MoveTowards(current, target, 10)

        #expect(abs(result.x - 10) < 0.001)
        #expect(abs(result.y - 0) < 0.001)
        #expect(abs(result.z - 0) < 0.001)
    }

    @Test("MoveTowards excessive distance clamps to target")
    func moveTowardsExcessive() {
        let current = Vector3(0, 0, 0)
        let target = Vector3(10, 0, 0)
        let result = Vector3.MoveTowards(current, target, 20)

        #expect(abs(result.x - 10) < 0.001)
        #expect(abs(result.y - 0) < 0.001)
        #expect(abs(result.z - 0) < 0.001)
    }

    @Test("MoveTowards already at target stays at target")
    func moveTowardsAtTarget() {
        let target = Vector3(10, 0, 0)
        let result = Vector3.MoveTowards(target, target, 5)

        #expect(abs(result.x - 10) < 0.001)
        #expect(abs(result.y - 0) < 0.001)
        #expect(abs(result.z - 0) < 0.001)
    }

    @Test("MoveTowards in 3D space")
    func moveTowards3D() {
        let current = Vector3(0, 0, 0)
        let target = Vector3(3, 4, 0) // Distance is 5
        let result = Vector3.MoveTowards(current, target, 2.5)
        let distance = Vector3.distance(current, result)

        #expect(abs(distance - 2.5) < 0.001)
    }

    // MARK: - Min/Max Tests

    @Test("Min returns smallest components")
    func minComponents() {
        let a = Vector3(1, 5, 3)
        let b = Vector3(2, 4, 6)
        let result = Vector3.Min(a, b)

        #expect(result.x == 1)
        #expect(result.y == 4)
        #expect(result.z == 3)
    }

    @Test("Max returns largest components")
    func maxComponents() {
        let a = Vector3(1, 5, 3)
        let b = Vector3(2, 4, 6)
        let result = Vector3.Max(a, b)

        #expect(result.x == 2)
        #expect(result.y == 5)
        #expect(result.z == 6)
    }

    // MARK: - ClampMagnitude Tests

    @Test("ClampMagnitude reduces long vector")
    func clampMagnitudeLong() {
        let longVector = Vector3(10, 0, 0)
        let clamped = Vector3.ClampMagnitude(longVector, 5)

        #expect(abs(clamped.length() - 5) < 0.001)
        #expect(abs(clamped.x - 5) < 0.001)
    }

    @Test("ClampMagnitude preserves short vector")
    func clampMagnitudeShort() {
        let shortVector = Vector3(3, 0, 0)
        let clamped = Vector3.ClampMagnitude(shortVector, 5)

        #expect(abs(clamped.length() - 3) < 0.001)
        #expect(abs(clamped.x - 3) < 0.001)
    }

    @Test("ClampMagnitude preserves direction")
    func clampMagnitudeDirection() {
        let vector = Vector3(3, 4, 0) // Length is 5
        let clamped = Vector3.ClampMagnitude(vector, 2.5)

        #expect(abs(clamped.length() - 2.5) < 0.001)

        let direction = clamped.normalized()
        let originalDirection = vector.normalized()
        #expect(abs(direction.x - originalDirection.x) < 0.001)
        #expect(abs(direction.y - originalDirection.y) < 0.001)
        #expect(abs(direction.z - originalDirection.z) < 0.001)
    }
}
