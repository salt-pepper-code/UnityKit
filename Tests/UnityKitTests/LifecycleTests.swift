import Foundation
import SceneKit
import Testing
import UIKit
@testable import UnityKit

@Suite("Lifecycle Methods")
struct LifecycleTests {
    // MARK: - Test MonoBehaviour for Lifecycle

    class TestBehaviour: MonoBehaviour {
        var callOrder: [String] = []

        override func awake() {
            super.awake()
            self.callOrder.append("awake")
        }

        override func start() {
            super.start()
            self.callOrder.append("start")
        }

        override func preUpdate() {
            super.preUpdate()
            self.callOrder.append("preUpdate")
        }

        override func update() {
            super.update()
            self.callOrder.append("update")
        }

        override func fixedUpdate() {
            super.fixedUpdate()
            self.callOrder.append("fixedUpdate")
        }
    }

    @Test("Complete lifecycle sequence verification")
    @MainActor
    func completeLifecycleSequence() async throws {
        // Create a window and view for rendering
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        let options = UI.Options(
            rendersContinuously: true,
            allocation: .instantiate
        )

        let view = UI.UIKitView.makeView(
            on: window,
            sceneName: nil,
            options: options
        )

        guard let scene = view.sceneHolder else {
            Issue.record("Failed to create scene")
            return
        }

        // Add GameObject with test behaviour
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)
        let behaviour = obj.addComponent(TestBehaviour.self)

        // Make window visible to trigger rendering
        window.makeKeyAndVisible()

        // Wait for render loop to execute multiple frames
        await TestHelpers.wait(.long)

        let callOrder = behaviour.callOrder

        // Verify all methods were called
        #expect(callOrder.contains("awake"), "awake should be called")
        #expect(callOrder.contains("start"), "start should be called")
        #expect(callOrder.contains("preUpdate"), "preUpdate should be called")
        #expect(callOrder.contains("update"), "update should be called")
        #expect(callOrder.contains("fixedUpdate"), "fixedUpdate should be called")

        // Verify correct order: awake → start → preUpdate → update
        if let awakeIdx = callOrder.firstIndex(of: "awake"),
           let startIdx = callOrder.firstIndex(of: "start"),
           let preUpdateIdx = callOrder.firstIndex(of: "preUpdate"),
           let updateIdx = callOrder.firstIndex(of: "update")
        {
            #expect(awakeIdx < startIdx)
            #expect(startIdx < preUpdateIdx)
            #expect(preUpdateIdx < updateIdx)
        }

        // Cleanup
        window.isHidden = true
    }

    @Test("Component added after delay has lifecycle called")
    @MainActor
    func componentAddedAfterDelay() async throws {
        // Create a window and view for rendering
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        let options = UI.Options(
            rendersContinuously: true,
            allocation: .instantiate
        )

        let view = UI.UIKitView.makeView(
            on: window,
            sceneName: nil,
            options: options
        )

        guard let scene = view.sceneHolder else {
            Issue.record("Failed to create scene")
            return
        }

        // Add GameObject initially without the test behaviour
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Make window visible to trigger rendering
        window.makeKeyAndVisible()

        // Wait 200ms to simulate some time passing
        await TestHelpers.wait(.long)

        // NOW add the component after the delay
        let behaviour = obj.addComponent(TestBehaviour.self)

        // Wait for lifecycle methods to be called
        await TestHelpers.wait(.long)

        let callOrder = behaviour.callOrder

        // Verify all lifecycle methods were called
        #expect(callOrder.contains("awake"), "awake should be called even when added after delay")
        #expect(callOrder.contains("start"), "start should be called even when added after delay")
        #expect(callOrder.contains("preUpdate"), "preUpdate should be called even when added after delay")
        #expect(callOrder.contains("update"), "update should be called even when added after delay")
        #expect(callOrder.contains("fixedUpdate"), "fixedUpdate should be called even when added after delay")

        // Verify correct order: awake → start → preUpdate → update
        if let awakeIdx = callOrder.firstIndex(of: "awake"),
           let startIdx = callOrder.firstIndex(of: "start"),
           let preUpdateIdx = callOrder.firstIndex(of: "preUpdate"),
           let updateIdx = callOrder.firstIndex(of: "update")
        {
            #expect(awakeIdx < startIdx, "awake should come before start")
            #expect(startIdx < preUpdateIdx, "start should come before preUpdate")
            #expect(preUpdateIdx < updateIdx, "preUpdate should come before update")
        }

        // Cleanup
        window.isHidden = true
    }
}
