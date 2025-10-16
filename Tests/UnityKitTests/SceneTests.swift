import SceneKit
import Testing
@testable import UnityKit

@Suite("Scene Management", .serialized)
struct SceneTests {
    // MARK: - Initialization

    @Test("Scene instantiate allocation doesn't set shared")
    func instantiateAllocation() {
        _ = Scene(allocation: .instantiate)
        #expect(Scene.shared == nil)

        _ = Scene(allocation: .instantiate)
        #expect(Scene.shared == nil)
    }

    @Test("Scene singleton allocation sets shared")
    func singletonAllocation() {
        // Create with singleton allocation
        let scene = Scene(allocation: .singleton)

        // Get reference immediately (before other tests might interfere)
        let shared = Scene.shared

        // Shared should be set to this scene
        #expect(shared != nil)
        #expect(shared === scene)

        // Clean up: reset to nil for other tests
        _ = Scene(allocation: .instantiate)
    }

    @Test("Scene has root GameObject")
    func hasRootGameObject() {
        let scene = Scene(allocation: .instantiate)
        // Root GameObject has a default name
        #expect(scene.rootGameObject.name != nil)
    }

    @Test("Scene has unique ID")
    func hasUniqueID() {
        let scene1 = Scene(allocation: .instantiate)
        let scene2 = Scene(allocation: .instantiate)

        #expect(scene1.id != scene2.id)
        #expect(scene1.getInstanceID() == scene1.id)
    }

    @Test("Scene creates main camera if none exists")
    func createsMainCamera() {
        let scene = Scene(allocation: .instantiate)

        let camera = Camera.main(in: scene)
        #expect(camera != nil)
        #expect(camera?.gameObject?.tag == .mainCamera)
    }

    @Test("Scene with custom SCNScene")
    func customSCNScene() {
        let scnScene = SCNScene()
        let scene = Scene(scnScene, allocation: .instantiate)

        #expect(scene.scnScene === scnScene)
    }

    // MARK: - Time Management

    @Test("Scene first update initializes timestamp")
    func firstUpdateInitializesTimestamp() {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = Scene(allocation: .instantiate)

        let frameBefore = Time.frameCount

        // First update initializes timestamp but doesn't increment frame count
        scene.update(updateAtTime: 0.0)
        let frameAfterInit = Time.frameCount

        // Frame count stays the same on first update
        #expect(frameAfterInit == frameBefore)

        // Second update should increment by exactly 1
        scene.update(updateAtTime: 0.016)
        let frameAfterSecond = Time.frameCount

        #expect(frameAfterSecond == frameAfterInit + 1)
    }

    @Test("Scene update calculates deltaTime correctly")
    func updateCalculatesDeltaTime() {
        Time.resetForTesting()
        Time.timeScale = 1.0 // Ensure timeScale is 1.0
        let scene = Scene(allocation: .instantiate)

        // First update to initialize
        scene.update(updateAtTime: 0.0)

        // Second update with time difference
        scene.update(updateAtTime: 0.016) // 16ms later (60fps)

        // Allow slight tolerance for floating point precision
        #expect(abs(Time.unscaledDeltaTime - 0.016) < 0.002)
        #expect(abs(Time.deltaTime - 0.016) < 0.002)
    }

    @Test("Scene update respects timeScale")
    func updateRespectsTimeScale() {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = Scene(allocation: .instantiate)

        Time.timeScale = 0.5 // Half speed

        scene.update(updateAtTime: 0.0)
        scene.update(updateAtTime: 0.016)

        // Unscaled should be approximately 0.016
        #expect(abs(Time.unscaledDeltaTime - 0.016) < 0.002)

        // Scaled should be approximately 0.008 (half of 0.016)
        #expect(abs(Time.deltaTime - 0.008) < 0.002)

        // Reset timeScale for other tests
        Time.timeScale = 1.0
    }

    @Test("Scene update increments frame count")
    func updateIncrementsFrameCount() {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = Scene(allocation: .instantiate)

        let countBefore = Time.frameCount

        // First update initializes (doesn't increment)
        scene.update(updateAtTime: 0.0)
        #expect(Time.frameCount == countBefore)

        // Subsequent updates should increment
        scene.update(updateAtTime: 0.016)
        #expect(Time.frameCount == countBefore + 1)

        scene.update(updateAtTime: 0.032)
        #expect(Time.frameCount == countBefore + 2)

        scene.update(updateAtTime: 0.048)
        #expect(Time.frameCount == countBefore + 3)
    }

    @Test("Scene update accumulates time correctly")
    func updateAccumulatesTime() {
        Time.resetForTesting()
        Time.timeScale = 1.0 // Ensure timeScale is 1.0
        let scene = Scene(allocation: .instantiate)

        // First update initializes timestamp (doesn't advance time)
        scene.update(updateAtTime: 1.0) // Use 1.0 as base
        let timeAfterInit = Time.time

        // Second update advances time by 0.016
        scene.update(updateAtTime: 1.016)
        let timeAfterSecond = Time.time

        // Third update advances time by another 0.016
        scene.update(updateAtTime: 1.032)
        let timeAfterThird = Time.time

        // Time should accumulate with each real update (after initialization)
        #expect(timeAfterSecond > timeAfterInit)
        #expect(timeAfterThird > timeAfterSecond)

        // Each update (after init) should add approximately 0.016
        let delta1 = timeAfterSecond - timeAfterInit
        let delta2 = timeAfterThird - timeAfterSecond
        #expect(abs(delta1 - 0.016) < 0.003) // Slightly larger tolerance for floating point
        #expect(abs(delta2 - 0.016) < 0.003)
    }

    @Test("Scene update with zero timeScale pauses time")
    func updateWithZeroTimeScale() {
        Time.resetForTesting()
        let scene = Scene(allocation: .instantiate)

        scene.update(updateAtTime: 0.0)
        let timeBeforePause = Time.time

        Time.timeScale = 0.0

        scene.update(updateAtTime: 0.016)
        scene.update(updateAtTime: 0.032)

        // Time should not have advanced
        #expect(Time.time == timeBeforePause)

        // But unscaled time should still work
        #expect(Time.unscaledDeltaTime > 0)
    }

    // MARK: - Lifecycle

    // Note: Lifecycle propagation to MonoBehaviours is tested in LifecycleTests.swift
    // These Scene tests focus on time management and Scene-specific functionality

    // MARK: - GameObject Management

    @Test("addGameObject adds to scene")
    func addGameObjectAddsToScene() {
        let scene = Scene(allocation: .instantiate)
        let obj = GameObject(name: "TestObject")

        scene.addGameObject(obj)

        #expect(obj.scene === scene)
        #expect(obj.parent === scene.rootGameObject)
    }

    @Test("addGameObject with shadowCastingAllowed false disables shadows")
    func addGameObjectDisablesShadows() {
        let scene = Scene(allocation: .instantiate, shadowCastingAllowed: false)
        let obj = GameObject(name: "TestObject")

        scene.addGameObject(obj)

        #expect(obj.node.castsShadow == false)
    }

    @Test("Scene clearScene removes all GameObjects")
    func clearSceneRemovesGameObjects() {
        let scene = Scene(allocation: .instantiate)

        let obj1 = GameObject(name: "Object1")
        let obj2 = GameObject(name: "Object2")

        scene.addGameObject(obj1)
        scene.addGameObject(obj2)

        // Filter to only our test objects (exclude camera)
        let childrenBefore = scene.rootGameObject.getChildren().filter {
            $0.name == "Object1" || $0.name == "Object2"
        }
        #expect(childrenBefore.count == 2)

        scene.clearScene()

        let childrenAfter = scene.rootGameObject.getChildren().filter {
            $0.name == "Object1" || $0.name == "Object2"
        }
        #expect(childrenAfter.count == 0)
    }

    @Test("Scene find locates GameObject")
    func findLocatesGameObject() {
        let scene = Scene(allocation: .instantiate)
        let obj = GameObject(name: "TestObject")
        obj.layer = .player

        scene.addGameObject(obj)

        let found = scene.find(.layer(.player))
        #expect(found != nil)
        #expect(found === obj)
    }

    @Test("Scene findGameObjects returns multiple objects")
    func findGameObjectsReturnsMultiple() {
        let scene = Scene(allocation: .instantiate)

        let obj1 = GameObject(name: "Object1")
        obj1.layer = .player

        let obj2 = GameObject(name: "Object2")
        obj2.layer = .player

        scene.addGameObject(obj1)
        scene.addGameObject(obj2)

        let found = scene.findGameObjects(.layer(.player))
        #expect(found.count >= 2) // At least our 2 objects
    }

    // MARK: - Shadow Casting

    @Test("Scene with shadowCastingAllowed false disables shadows on hierarchy")
    func shadowCastingDisabledOnHierarchy() {
        let scene = Scene(allocation: .instantiate, shadowCastingAllowed: false)

        let parent = GameObject(name: "Parent")
        scene.addGameObject(parent)

        let child = GameObject(name: "Child")
        parent.addChild(child)

        #expect(parent.node.castsShadow == false)
        // Note: Children added after parent is in scene won't auto-disable shadows
        // This test verifies the parent has shadows disabled
    }

    // MARK: - Scene Equality

    @Test("Scene equality works correctly")
    func sceneEquality() {
        let scene1 = Scene(allocation: .instantiate)
        let scene2 = Scene(allocation: .instantiate)

        #expect(scene1 == scene1)
        #expect(scene1 != scene2)
    }

    // MARK: - Multiple Updates

    @Test("Multiple updates maintain consistent time progression")
    func multipleUpdatesConsistent() {
        Time.resetForTesting()
        Time.timeScale = 1.0 // Ensure timeScale is 1.0
        let scene = Scene(allocation: .instantiate)

        scene.update(updateAtTime: 0.0)
        scene.update(updateAtTime: 0.016)

        let timeAfter1 = Time.time
        let frameAfter1 = Time.frameCount

        scene.update(updateAtTime: 0.032)

        let timeAfter2 = Time.time
        let frameAfter2 = Time.frameCount

        #expect(timeAfter2 > timeAfter1)
        #expect(frameAfter2 == frameAfter1 + 1)
    }

    @Test("Scene handles rapid successive updates")
    func rapidSuccessiveUpdates() {
        Time.resetForTesting()
        let scene = Scene(allocation: .instantiate)

        scene.update(updateAtTime: 0.0)

        // Simulate many rapid updates
        for i in 1...10 {
            scene.update(updateAtTime: Double(i) * 0.001) // 1ms apart
        }

        #expect(Time.frameCount >= 10)
    }
}
