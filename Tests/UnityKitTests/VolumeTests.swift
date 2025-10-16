import Testing
import SceneKit
@testable import UnityKit

@Suite("Volume Utilities")
struct VolumeTests {

    // MARK: - Bounding Size

    @Test("boundingSize calculates dimensions correctly")
    func boundingSizeCalculatesDimensions() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 20, 30)
        )

        let size = Volume.boundingSize(box)

        #expect(size.x == 10)
        #expect(size.y == 20)
        #expect(size.z == 30)
    }

    @Test("boundingSize handles negative coordinates")
    func boundingSizeHandlesNegative() {
        let box: BoundingBox = (
            min: Vector3(-5, -10, -15),
            max: Vector3(5, 10, 15)
        )

        let size = Volume.boundingSize(box)

        #expect(size.x == 10)
        #expect(size.y == 20)
        #expect(size.z == 30)
    }

    @Test("boundingSize of zero volume")
    func boundingSizeZeroVolume() {
        let box: BoundingBox = (
            min: Vector3(5, 5, 5),
            max: Vector3(5, 5, 5)
        )

        let size = Volume.boundingSize(box)

        #expect(size.x == 0)
        #expect(size.y == 0)
        #expect(size.z == 0)
    }

    @Test("boundingSize handles inverted box")
    func boundingSizeInvertedBox() {
        let box: BoundingBox = (
            min: Vector3(10, 10, 10),
            max: Vector3(0, 0, 0)
        )

        let size = Volume.boundingSize(box)

        // Uses abs, so size is always positive
        #expect(size.x == 10)
        #expect(size.y == 10)
        #expect(size.z == 10)
    }

    // MARK: - Bounding Center

    @Test("boundingCenter calculates center correctly")
    func boundingCenterCalculatesCorrectly() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 20, 30)
        )

        let center = Volume.boundingCenter(box)

        #expect(center.x == 5)
        #expect(center.y == 10)
        #expect(center.z == 15)
    }

    @Test("boundingCenter with negative coordinates")
    func boundingCenterNegativeCoordinates() {
        let box: BoundingBox = (
            min: Vector3(-10, -20, -30),
            max: Vector3(10, 20, 30)
        )

        let center = Volume.boundingCenter(box)

        #expect(center.x == 0)
        #expect(center.y == 0)
        #expect(center.z == 0)
    }

    @Test("boundingCenter of offset box")
    func boundingCenterOffsetBox() {
        let box: BoundingBox = (
            min: Vector3(5, 5, 5),
            max: Vector3(15, 15, 15)
        )

        let center = Volume.boundingCenter(box)

        #expect(center.x == 10)
        #expect(center.y == 10)
        #expect(center.z == 10)
    }

    // MARK: - Move Center

    @Test("moveCenter moves all axes")
    func moveCenterAllAxes() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )

        let newBox = Volume.moveCenter(box, center: Vector3Nullable(20, 30, 40))

        let newCenter = Volume.boundingCenter(newBox)
        #expect(newCenter.x == 20)
        #expect(newCenter.y == 30)
        #expect(newCenter.z == 40)

        // Size should remain the same
        let size = Volume.boundingSize(newBox)
        #expect(size.x == 10)
        #expect(size.y == 10)
        #expect(size.z == 10)
    }

    @Test("moveCenter moves only X axis")
    func moveCenterOnlyX() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )

        let newBox = Volume.moveCenter(box, center: Vector3Nullable(50, nil, nil))

        let newCenter = Volume.boundingCenter(newBox)
        #expect(newCenter.x == 50)
        #expect(newCenter.y == 5)
        #expect(newCenter.z == 5)
    }

    @Test("moveCenter moves only Y axis")
    func moveCenterOnlyY() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )

        let newBox = Volume.moveCenter(box, center: Vector3Nullable(nil, 50, nil))

        let newCenter = Volume.boundingCenter(newBox)
        #expect(newCenter.x == 5)
        #expect(newCenter.y == 50)
        #expect(newCenter.z == 5)
    }

    @Test("moveCenter moves only Z axis")
    func moveCenterOnlyZ() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )

        let newBox = Volume.moveCenter(box, center: Vector3Nullable(nil, nil, 50))

        let newCenter = Volume.boundingCenter(newBox)
        #expect(newCenter.x == 5)
        #expect(newCenter.y == 5)
        #expect(newCenter.z == 50)
    }

    @Test("moveCenter preserves size")
    func moveCenterPreservesSize() {
        let box: BoundingBox = (
            min: Vector3(-5, -10, -15),
            max: Vector3(5, 10, 15)
        )

        let originalSize = Volume.boundingSize(box)
        let newBox = Volume.moveCenter(box, center: Vector3Nullable(100, 200, 300))
        let newSize = Volume.boundingSize(newBox)

        #expect(newSize.x == originalSize.x)
        #expect(newSize.y == originalSize.y)
        #expect(newSize.z == originalSize.z)
    }

    @Test("moveCenter with no changes returns equivalent box")
    func moveCenterNoChanges() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )

        let newBox = Volume.moveCenter(box, center: Vector3Nullable(nil, nil, nil))

        let originalCenter = Volume.boundingCenter(box)
        let newCenter = Volume.boundingCenter(newBox)

        #expect(newCenter.x == originalCenter.x)
        #expect(newCenter.y == originalCenter.y)
        #expect(newCenter.z == originalCenter.z)
    }

    // MARK: - BoundingBox Addition

    @Test("BoundingBox addition combines two boxes")
    func boundingBoxAdditionCombines() {
        let box1: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )
        let box2: BoundingBox = (
            min: Vector3(5, 5, 5),
            max: Vector3(15, 15, 15)
        )

        let combined = box1 + box2

        #expect(combined?.min.x == 0)
        #expect(combined?.min.y == 0)
        #expect(combined?.min.z == 0)
        #expect(combined?.max.x == 15)
        #expect(combined?.max.y == 15)
        #expect(combined?.max.z == 15)
    }

    @Test("BoundingBox addition with non-overlapping boxes")
    func boundingBoxAdditionNonOverlapping() {
        let box1: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )
        let box2: BoundingBox = (
            min: Vector3(20, 20, 20),
            max: Vector3(30, 30, 30)
        )

        let combined = box1 + box2

        #expect(combined?.min.x == 0)
        #expect(combined?.min.y == 0)
        #expect(combined?.min.z == 0)
        #expect(combined?.max.x == 30)
        #expect(combined?.max.y == 30)
        #expect(combined?.max.z == 30)
    }

    @Test("BoundingBox addition with nil left returns right")
    func boundingBoxAdditionNilLeft() {
        let box: BoundingBox = (
            min: Vector3(5, 5, 5),
            max: Vector3(10, 10, 10)
        )

        let result: BoundingBox? = nil + box

        #expect(result?.min.x == 5)
        #expect(result?.min.y == 5)
        #expect(result?.min.z == 5)
        #expect(result?.max.x == 10)
        #expect(result?.max.y == 10)
        #expect(result?.max.z == 10)
    }

    @Test("BoundingBox addition with nil right returns left")
    func boundingBoxAdditionNilRight() {
        let box: BoundingBox = (
            min: Vector3(5, 5, 5),
            max: Vector3(10, 10, 10)
        )

        let result: BoundingBox? = box + nil

        #expect(result?.min.x == 5)
        #expect(result?.min.y == 5)
        #expect(result?.min.z == 5)
        #expect(result?.max.x == 10)
        #expect(result?.max.y == 10)
        #expect(result?.max.z == 10)
    }

    @Test("BoundingBox addition with both nil returns nil")
    func boundingBoxAdditionBothNil() {
        let result: BoundingBox? = nil + nil

        #expect(result == nil)
    }

    @Test("BoundingBox compound addition operator")
    func boundingBoxCompoundAddition() {
        var box1: BoundingBox? = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )
        let box2: BoundingBox = (
            min: Vector3(5, 5, 5),
            max: Vector3(15, 15, 15)
        )

        box1 += box2

        #expect(box1?.min.x == 0)
        #expect(box1?.min.y == 0)
        #expect(box1?.min.z == 0)
        #expect(box1?.max.x == 15)
        #expect(box1?.max.y == 15)
        #expect(box1?.max.z == 15)
    }

    // MARK: - BoundingBox Multiplication

    @Test("BoundingBox multiplication by Vector3")
    func boundingBoxMultiplicationVector3() {
        let box: BoundingBox = (
            min: Vector3(1, 2, 3),
            max: Vector3(4, 5, 6)
        )

        let result = box * Vector3(2, 3, 4)

        #expect(result.min.x == 2)
        #expect(result.min.y == 6)
        #expect(result.min.z == 12)
        #expect(result.max.x == 8)
        #expect(result.max.y == 15)
        #expect(result.max.z == 24)
    }

    @Test("BoundingBox multiplication by scalar")
    func boundingBoxMultiplicationScalar() {
        let box: BoundingBox = (
            min: Vector3(1, 2, 3),
            max: Vector3(4, 5, 6)
        )

        let result = box * 2.0

        #expect(result.min.x == 2)
        #expect(result.min.y == 4)
        #expect(result.min.z == 6)
        #expect(result.max.x == 8)
        #expect(result.max.y == 10)
        #expect(result.max.z == 12)
    }

    @Test("BoundingBox multiplication by zero scalar")
    func boundingBoxMultiplicationZero() {
        let box: BoundingBox = (
            min: Vector3(1, 2, 3),
            max: Vector3(4, 5, 6)
        )

        let result = box * 0.0

        #expect(result.min.x == 0)
        #expect(result.min.y == 0)
        #expect(result.min.z == 0)
        #expect(result.max.x == 0)
        #expect(result.max.y == 0)
        #expect(result.max.z == 0)
    }

    @Test("BoundingBox multiplication by negative scalar")
    func boundingBoxMultiplicationNegative() {
        let box: BoundingBox = (
            min: Vector3(1, 2, 3),
            max: Vector3(4, 5, 6)
        )

        let result = box * -1.0

        #expect(result.min.x == -1)
        #expect(result.min.y == -2)
        #expect(result.min.z == -3)
        #expect(result.max.x == -4)
        #expect(result.max.y == -5)
        #expect(result.max.z == -6)
    }

    @Test("BoundingBox multiplication by Vector3 with zero component")
    func boundingBoxMultiplicationVector3Zero() {
        let box: BoundingBox = (
            min: Vector3(1, 2, 3),
            max: Vector3(4, 5, 6)
        )

        let result = box * Vector3(0, 2, 3)

        #expect(result.min.x == 0)
        #expect(result.min.y == 4)
        #expect(result.min.z == 9)
        #expect(result.max.x == 0)
        #expect(result.max.y == 10)
        #expect(result.max.z == 18)
    }

    // MARK: - Integration Tests

    @Test("Calculate center then move it back")
    func calculateCenterThenMoveBack() {
        let box: BoundingBox = (
            min: Vector3(5, 10, 15),
            max: Vector3(15, 20, 25)
        )

        let center = Volume.boundingCenter(box)
        let movedBox = Volume.moveCenter(
            (min: Vector3(0, 0, 0), max: Vector3(10, 10, 10)),
            center: Vector3Nullable(center.x, center.y, center.z)
        )

        let newCenter = Volume.boundingCenter(movedBox)
        #expect(newCenter.x == center.x)
        #expect(newCenter.y == center.y)
        #expect(newCenter.z == center.z)
    }

    @Test("Combine multiple boxes")
    func combineMultipleBoxes() {
        let box1: BoundingBox = (min: Vector3(0, 0, 0), max: Vector3(5, 5, 5))
        let box2: BoundingBox = (min: Vector3(10, 10, 10), max: Vector3(15, 15, 15))
        let box3: BoundingBox = (min: Vector3(-5, -5, -5), max: Vector3(0, 0, 0))

        var combined: BoundingBox? = box1
        combined += box2
        combined += box3

        #expect(combined?.min.x == -5)
        #expect(combined?.min.y == -5)
        #expect(combined?.min.z == -5)
        #expect(combined?.max.x == 15)
        #expect(combined?.max.y == 15)
        #expect(combined?.max.z == 15)
    }

    @Test("Scale box then calculate properties")
    func scaleBoxThenCalculateProperties() {
        let box: BoundingBox = (
            min: Vector3(0, 0, 0),
            max: Vector3(10, 10, 10)
        )

        let scaled = box * 2.0

        let size = Volume.boundingSize(scaled)
        #expect(size.x == 20)
        #expect(size.y == 20)
        #expect(size.z == 20)

        let center = Volume.boundingCenter(scaled)
        #expect(center.x == 10)
        #expect(center.y == 10)
        #expect(center.z == 10)
    }
}
