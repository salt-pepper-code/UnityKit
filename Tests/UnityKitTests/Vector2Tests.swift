import Testing
import CoreGraphics
@testable import UnityKit

@Suite("Vector2")
struct Vector2Tests {

    // MARK: - Initialization

    @Test("Vector2 initializes with x and y")
    func initializesWithXAndY() {
        let v = Vector2(3.0, 4.0)
        #expect(v.x == 3.0)
        #expect(v.y == 4.0)
    }

    // MARK: - Static Properties

    @Test("Vector2.zero returns (0, 0)")
    func zeroReturnsOrigin() {
        let zero = Vector2.zero
        #expect(zero.x == 0)
        #expect(zero.y == 0)
    }

    @Test("Vector2.one returns (1, 1)")
    func oneReturnsUnit() {
        let one = Vector2.one
        #expect(one.x == 1)
        #expect(one.y == 1)
    }

    // MARK: - Equatable

    @Test("Vector2 equality works")
    func equalityWorks() {
        let a = Vector2(3, 4)
        let b = Vector2(3, 4)
        let c = Vector2(3, 5)

        #expect(a == b)
        #expect(a != c)
    }

    // MARK: - Conversions

    @Test("Vector2 converts to CGPoint")
    func convertsToCGPoint() {
        let v = Vector2(3.5, 4.5)
        let point = v.toCGPoint()

        #expect(point.x == 3.5)
        #expect(point.y == 4.5)
    }

    @Test("CGPoint converts to Vector2")
    func cgPointConvertsToVector2() {
        let point = CGPoint(x: 3.5, y: 4.5)
        let v = point.toVector2()

        #expect(v.x == 3.5)
        #expect(v.y == 4.5)
    }

    @Test("CGSize converts to Vector2")
    func cgSizeConvertsToVector2() {
        let size = CGSize(width: 100, height: 200)
        let v = size.toVector2()

        #expect(v.x == 100)
        #expect(v.y == 200)
    }

    // MARK: - Length/Magnitude

    @Test("Vector2 length calculates magnitude")
    func lengthCalculatesMagnitude() {
        let v = Vector2(3, 4)
        let length = v.length()

        #expect(length == 5.0)
    }

    @Test("Vector2 length of zero is zero")
    func lengthOfZeroIsZero() {
        let v = Vector2.zero
        let length = v.length()

        #expect(length == 0)
    }

    @Test("Vector2 static length works")
    func staticLengthWorks() {
        let v = Vector2(3, 4)
        let length = Vector2.length(v)

        #expect(length == 5.0)
    }

    @Test("Vector2 length of unit vector is 1")
    func lengthOfUnitVectorIsOne() {
        let v = Vector2(1, 0)
        let length = v.length()

        #expect(length == 1.0)
    }

    // MARK: - Distance

    @Test("Vector2 distance between two points")
    func distanceBetweenTwoPoints() {
        let a = Vector2(0, 0)
        let b = Vector2(3, 4)
        let distance = a.distance(b)

        #expect(distance == 5.0)
    }

    @Test("Vector2 distance to self is zero")
    func distanceToSelfIsZero() {
        let v = Vector2(5, 10)
        let distance = v.distance(v)

        #expect(distance == 0)
    }

    @Test("Vector2 static distance works")
    func staticDistanceWorks() {
        let a = Vector2(0, 0)
        let b = Vector2(3, 4)
        let distance = Vector2.distance(a, b)

        #expect(distance == 5.0)
    }

    @Test("Vector2 distance is commutative")
    func distanceIsCommutative() {
        let a = Vector2(1, 2)
        let b = Vector2(4, 6)

        #expect(a.distance(b) == b.distance(a))
    }

    // MARK: - Addition

    @Test("Vector2 addition operator")
    func additionOperator() {
        let a = Vector2(1, 2)
        let b = Vector2(3, 4)
        let result = a + b

        #expect(result.x == 4)
        #expect(result.y == 6)
    }

    @Test("Vector2 addition with zero")
    func additionWithZero() {
        let v = Vector2(5, 10)
        let result = v + Vector2.zero

        #expect(result == v)
    }

    @Test("Vector2 compound addition operator")
    func compoundAdditionOperator() {
        var v = Vector2(1, 2)
        v += Vector2(3, 4)

        #expect(v.x == 4)
        #expect(v.y == 6)
    }

    // MARK: - Subtraction

    @Test("Vector2 subtraction operator")
    func subtractionOperator() {
        let a = Vector2(5, 8)
        let b = Vector2(2, 3)
        let result = a - b

        #expect(result.x == 3)
        #expect(result.y == 5)
    }

    @Test("Vector2 subtraction with zero")
    func subtractionWithZero() {
        let v = Vector2(5, 10)
        let result = v - Vector2.zero

        #expect(result == v)
    }

    @Test("Vector2 subtraction from self is zero")
    func subtractionFromSelfIsZero() {
        let v = Vector2(5, 10)
        let result = v - v

        #expect(result == Vector2.zero)
    }

    @Test("Vector2 compound subtraction operator")
    func compoundSubtractionOperator() {
        var v = Vector2(5, 8)
        v -= Vector2(2, 3)

        #expect(v.x == 3)
        #expect(v.y == 5)
    }

    // MARK: - Multiplication (Vector * Vector)

    @Test("Vector2 multiplication operator")
    func multiplicationOperator() {
        let a = Vector2(2, 3)
        let b = Vector2(4, 5)
        let result = a * b

        #expect(result.x == 8)
        #expect(result.y == 15)
    }

    @Test("Vector2 multiplication with one")
    func multiplicationWithOne() {
        let v = Vector2(5, 10)
        let result = v * Vector2.one

        #expect(result == v)
    }

    @Test("Vector2 multiplication with zero")
    func multiplicationWithZero() {
        let v = Vector2(5, 10)
        let result = v * Vector2.zero

        #expect(result == Vector2.zero)
    }

    @Test("Vector2 compound multiplication operator")
    func compoundMultiplicationOperator() {
        var v = Vector2(2, 3)
        v *= Vector2(4, 5)

        #expect(v.x == 8)
        #expect(v.y == 15)
    }

    // MARK: - Multiplication (Scalar)

    @Test("Vector2 scalar multiplication")
    func scalarMultiplication() {
        let v = Vector2(2, 3)
        let result = v * 2.0

        #expect(result.x == 4)
        #expect(result.y == 6)
    }

    @Test("Vector2 scalar multiplication commutative")
    func scalarMultiplicationCommutative() {
        let v = Vector2(2, 3)
        let result1 = v * 2.0
        let result2 = 2.0 * v

        #expect(result1 == result2)
    }

    @Test("Vector2 scalar multiplication by zero")
    func scalarMultiplicationByZero() {
        let v = Vector2(5, 10)
        let result = v * 0.0

        #expect(result == Vector2.zero)
    }

    @Test("Vector2 scalar multiplication by one")
    func scalarMultiplicationByOne() {
        let v = Vector2(5, 10)
        let result = v * 1.0

        #expect(result == v)
    }

    @Test("Vector2 compound scalar multiplication")
    func compoundScalarMultiplication() {
        var v = Vector2(2, 3)
        v *= 2.0

        #expect(v.x == 4)
        #expect(v.y == 6)
    }

    @Test("Vector2 scalar multiplication by negative")
    func scalarMultiplicationByNegative() {
        let v = Vector2(2, 3)
        let result = v * -1.0

        #expect(result.x == -2)
        #expect(result.y == -3)
    }

    // MARK: - Division (Vector / Vector)

    @Test("Vector2 division operator")
    func divisionOperator() {
        let a = Vector2(8, 15)
        let b = Vector2(2, 3)
        let result = a / b

        #expect(result.x == 4)
        #expect(result.y == 5)
    }

    @Test("Vector2 division by one")
    func divisionByOne() {
        let v = Vector2(5, 10)
        let result = v / Vector2.one

        #expect(result == v)
    }

    @Test("Vector2 compound division operator")
    func compoundDivisionOperator() {
        var v = Vector2(8, 15)
        v /= Vector2(2, 3)

        #expect(v.x == 4)
        #expect(v.y == 5)
    }

    // MARK: - Division (Scalar)

    @Test("Vector2 scalar division")
    func scalarDivision() {
        let v = Vector2(8, 12)
        let result = v / 2.0

        #expect(result.x == 4)
        #expect(result.y == 6)
    }

    @Test("Vector2 scalar division by one")
    func scalarDivisionByOne() {
        let v = Vector2(5, 10)
        let result = v / 1.0

        #expect(result == v)
    }

    @Test("Vector2 compound scalar division")
    func compoundScalarDivision() {
        var v = Vector2(8, 12)
        v /= 2.0

        #expect(v.x == 4)
        #expect(v.y == 6)
    }

    @Test("Vector2 scalar division by negative")
    func scalarDivisionByNegative() {
        let v = Vector2(8, 12)
        let result = v / -2.0

        #expect(result.x == -4)
        #expect(result.y == -6)
    }

    // MARK: - Complex Operations

    @Test("Vector2 chained operations")
    func chainedOperations() {
        let a = Vector2(1, 2)
        let b = Vector2(3, 4)
        let c = Vector2(2, 2)
        let result = (a + b) * c / 2.0

        #expect(result.x == 4)
        #expect(result.y == 6)
    }

    @Test("Vector2 normalized vector has length 1")
    func normalizedVectorHasLengthOne() {
        let v = Vector2(3, 4)
        let length = v.length()
        let normalized = v / length

        let normalizedLength = normalized.length()
        #expect(abs(normalizedLength - 1.0) < 0.0001)
    }

    @Test("Vector2 perpendicular vectors")
    func perpendicularVectors() {
        let a = Vector2(1, 0)
        let b = Vector2(0, 1)

        // Dot product of perpendicular vectors is zero
        let dotProduct = (a.x * b.x) + (a.y * b.y)
        #expect(dotProduct == 0)
    }

    @Test("Vector2 midpoint calculation")
    func midpointCalculation() {
        let a = Vector2(0, 0)
        let b = Vector2(4, 6)
        let midpoint = (a + b) / 2.0

        #expect(midpoint.x == 2)
        #expect(midpoint.y == 3)
    }
}
