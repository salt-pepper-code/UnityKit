import SceneKit
import Testing
@testable import UnityKit

@Suite("Transform Component")
struct TransformTests {
    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - Basic Properties

    @Test("Transform has correct parent reference")
    func parentReference() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        // Child's parent should be the parent GameObject
        #expect(child.transform.parent === parent.transform)

        // Parent's parent should be the scene's root GameObject
        #expect(parent.transform.parent != nil)
        #expect(parent.transform.parent === scene.rootGameObject.transform)
    }

    @Test("Transform children list reflects hierarchy")
    func childrenList() throws {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child1 = GameObject(name: "Child1")
        let child2 = GameObject(name: "Child2")

        scene.addGameObject(parent)
        parent.addChild(child1)
        parent.addChild(child2)

        let children = try #require(parent.transform.children)
        #expect(children.count == 2)
        #expect(children.contains { $0 === child1.transform })
        #expect(children.contains { $0 === child2.transform })
    }

    @Test("Transform childCount reflects number of children")
    func childCount() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")

        scene.addGameObject(parent)
        #expect(parent.transform.childCount == 0)

        parent.addChild(GameObject(name: "Child1"))
        #expect(parent.transform.childCount == 1)

        parent.addChild(GameObject(name: "Child2"))
        #expect(parent.transform.childCount == 2)
    }

    // MARK: - Position Properties

    @Test("Position getter and setter work correctly")
    func positionProperty() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let testPosition = Vector3(10, 20, 30)
        obj.transform.position = testPosition

        let result = obj.transform.position
        #expect(abs(result.x - 10) < 0.001)
        #expect(abs(result.y - 20) < 0.001)
        #expect(abs(result.z - 30) < 0.001)
    }

    @Test("LocalPosition getter and setter work correctly")
    func localPositionProperty() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        parent.transform.position = Vector3(10, 0, 0)
        child.transform.localPosition = Vector3(5, 0, 0)

        let localPos = child.transform.localPosition
        #expect(abs(localPos.x - 5) < 0.001)

        // World position should be parent + local
        let worldPos = child.transform.position
        #expect(abs(worldPos.x - 15) < 0.001)
    }

    // MARK: - Rotation Properties

    @Test("Orientation getter and setter work correctly")
    func orientationProperty() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let testOrientation = Quaternion(x: 0, y: 0.707, z: 0, w: 0.707) // ~90 degrees Y
        obj.transform.orientation = testOrientation

        let result = obj.transform.orientation
        #expect(abs(result.x - testOrientation.x) < 0.01)
        #expect(abs(result.y - testOrientation.y) < 0.01)
        #expect(abs(result.z - testOrientation.z) < 0.01)
        #expect(abs(result.w - testOrientation.w) < 0.01)
    }

    @Test("LocalOrientation getter and setter work correctly")
    func localOrientationProperty() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let testOrientation = Quaternion(x: 0, y: 0.707, z: 0, w: 0.707)
        obj.transform.localOrientation = testOrientation

        let result = obj.transform.localOrientation
        #expect(abs(result.x - testOrientation.x) < 0.01)
        #expect(abs(result.y - testOrientation.y) < 0.01)
    }

    @Test("LocalRotation getter and setter work correctly")
    func localRotationProperty() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Rotation as axis-angle (x, y, z, angle)
        let testRotation = Vector4(0, 1, 0, Float.pi / 2) // 90 degrees around Y
        obj.transform.localRotation = testRotation

        let result = obj.transform.localRotation
        #expect(abs(result.y - 1) < 0.01)
        #expect(abs(result.w - Float.pi / 2) < 0.1)
    }

    @Test("LocalEulerAngles getter and setter work correctly")
    func localEulerAnglesProperty() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Set euler angles in degrees
        let testAngles = Vector3(0, 90, 0) // 90 degrees around Y
        obj.transform.localEulerAngles = testAngles

        let result = obj.transform.localEulerAngles
        #expect(abs(result.y - 90) < 1.0) // Allow 1 degree tolerance due to conversions
    }

    // MARK: - Scale Properties

    @Test("LocalScale getter and setter work correctly")
    func localScaleProperty() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let testScale = Vector3(2, 3, 4)
        obj.transform.localScale = testScale

        let result = obj.transform.localScale
        #expect(abs(result.x - 2) < 0.001)
        #expect(abs(result.y - 3) < 0.001)
        #expect(abs(result.z - 4) < 0.001)
    }

    @Test("LossyScale returns correct value without parent")
    func lossyScaleNoParent() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        obj.transform.localScale = Vector3(2, 3, 4)

        let lossy = obj.transform.lossyScale
        #expect(abs(lossy.x - 2) < 0.001)
        #expect(abs(lossy.y - 3) < 0.001)
        #expect(abs(lossy.z - 4) < 0.001)
    }

    @Test("LossyScale accumulates parent scale")
    func lossyScaleWithParent() {
        let scene = self.createTestScene()
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent)
        parent.addChild(child)

        parent.transform.localScale = Vector3(2, 2, 2)
        child.transform.localScale = Vector3(3, 3, 3)

        let lossy = child.transform.lossyScale
        #expect(abs(lossy.x - 6) < 0.001) // 2 * 3
        #expect(abs(lossy.y - 6) < 0.001)
        #expect(abs(lossy.z - 6) < 0.001)
    }

    @Test("LossyScale accumulates through multiple parents")
    func lossyScaleMultipleLevels() {
        let scene = self.createTestScene()
        let grandparent = GameObject(name: "Grandparent")
        let parent = GameObject(name: "Parent")
        let child = GameObject(name: "Child")

        scene.addGameObject(grandparent)
        grandparent.addChild(parent)
        parent.addChild(child)

        grandparent.transform.localScale = Vector3(2, 2, 2)
        parent.transform.localScale = Vector3(1.5, 1.5, 1.5)
        child.transform.localScale = Vector3(2, 2, 2)

        let lossy = child.transform.lossyScale
        #expect(abs(lossy.x - 6) < 0.001) // 2 * 1.5 * 2 = 6
        #expect(abs(lossy.y - 6) < 0.001)
        #expect(abs(lossy.z - 6) < 0.001)
    }

    // MARK: - Direction Vectors

    @Test("Forward direction vector defaults correctly")
    func forwardDirection() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let forward = obj.transform.forward
        // Default forward should be along negative Z in SceneKit
        #expect(forward != .zero)
    }

    @Test("Back direction is negated forward")
    func backDirection() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let forward = obj.transform.forward
        let back = obj.transform.back

        #expect(abs(back.x + forward.x) < 0.001)
        #expect(abs(back.y + forward.y) < 0.001)
        #expect(abs(back.z + forward.z) < 0.001)
    }

    @Test("Up direction vector works correctly")
    func upDirection() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let up = obj.transform.up
        #expect(up != .zero)
    }

    @Test("Bottom direction is negated up")
    func bottomDirection() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let up = obj.transform.up
        let bottom = obj.transform.bottom

        #expect(abs(bottom.x + up.x) < 0.001)
        #expect(abs(bottom.y + up.y) < 0.001)
        #expect(abs(bottom.z + up.z) < 0.001)
    }

    @Test("Right direction vector works correctly")
    func rightDirection() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let right = obj.transform.right
        #expect(right != .zero)
    }

    @Test("Left direction is negated right")
    func leftDirection() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let right = obj.transform.right
        let left = obj.transform.left

        #expect(abs(left.x + right.x) < 0.001)
        #expect(abs(left.y + right.y) < 0.001)
        #expect(abs(left.z + right.z) < 0.001)
    }

    @Test("Direction vectors update when rotation changes")
    func directionVectorsUpdateWithRotation() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let initialForward = obj.transform.forward

        // Rotate 90 degrees around Y
        obj.transform.localEulerAngles = Vector3(0, 90, 0)

        let newForward = obj.transform.forward

        // Forward should have changed
        #expect(abs(initialForward.x - newForward.x) > 0.1)
    }

    // MARK: - LookAt Method

    @Test("LookAt points transform toward target")
    func lookAtTarget() {
        let scene = self.createTestScene()
        let source = GameObject(name: "Source")
        let target = GameObject(name: "Target")

        scene.addGameObject(source)
        scene.addGameObject(target)

        source.transform.position = Vector3(0, 0, 0)
        target.transform.position = Vector3(10, 0, 0)

        // Call lookAt
        source.transform.lookAt(target.transform)

        // Forward direction should roughly point toward target
        let forward = source.transform.forward
        let directionToTarget = (target.transform.position - source.transform.position).normalized()

        // Check that forward aligns with direction to target (allowing some tolerance)
        let dot = forward.x * directionToTarget.x +
            forward.y * directionToTarget.y +
            forward.z * directionToTarget.z
        #expect(abs(dot) > 0.9) // Should be close to 1 or -1 (aligned)
    }

    @Test("LookAt works with different positions")
    func lookAtDifferentPositions() {
        let scene = self.createTestScene()
        let source = GameObject(name: "Source")
        let target = GameObject(name: "Target")

        scene.addGameObject(source)
        scene.addGameObject(target)

        source.transform.position = Vector3(0, 5, 0)
        target.transform.position = Vector3(0, 0, 10)

        source.transform.lookAt(target.transform)

        // Should point forward generally (allowing for SceneKit coordinate system)
        let forward = source.transform.forward
        #expect(forward != .zero)
    }

    // MARK: - Edge Cases

    @Test("Transform properties work with zero GameObject")
    func transformWithoutGameObject() {
        let transform = Transform()

        // Should return sensible defaults
        #expect(transform.position == .zero)
        #expect(transform.localPosition == .zero)
        #expect(transform.forward == .zero)
        #expect(transform.childCount == 0)
    }

    @Test("Multiple property changes are independent")
    func multiplePropertiesIndependent() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        obj.transform.position = Vector3(10, 20, 30)
        obj.transform.localScale = Vector3(2, 3, 4)
        obj.transform.localEulerAngles = Vector3(45, 90, 0)

        // Verify all properties are maintained independently
        let pos = obj.transform.position
        #expect(abs(pos.x - 10) < 0.001)
        #expect(abs(pos.y - 20) < 0.001)

        let scale = obj.transform.localScale
        #expect(abs(scale.x - 2) < 0.001)
        #expect(abs(scale.y - 3) < 0.001)

        let angles = obj.transform.localEulerAngles
        #expect(abs(angles.y - 90) < 1.0)
    }

    @Test("Transform preserves values through parent changes")
    func transformPreservesValuesWithParentChanges() {
        let scene = self.createTestScene()
        let parent1 = GameObject(name: "Parent1")
        let parent2 = GameObject(name: "Parent2")
        let child = GameObject(name: "Child")

        scene.addGameObject(parent1)
        scene.addGameObject(parent2)
        parent1.addChild(child)

        child.transform.localPosition = Vector3(5, 0, 0)
        let initialLocalPos = child.transform.localPosition

        // Change parent
        parent1.removeChild(child)
        parent2.addChild(child)

        // Local position should be preserved
        let finalLocalPos = child.transform.localPosition
        #expect(abs(finalLocalPos.x - initialLocalPos.x) < 0.001)
    }
}
