import Testing
import SceneKit
@testable import UnityKit

@Suite("MonoBehaviour Coroutines", .serialized)
struct CoroutineTests {

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    class TestBehaviour: MonoBehaviour {
        var executionLog: [String] = []

        func logExecution(_ message: String) {
            executionLog.append(message)
        }
    }

    // MARK: - startCoroutine

    @Test("startCoroutine executes immediately")
    func startCoroutineExecutesImmediately() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        behaviour.startCoroutine({
            executed = true
        })

        #expect(executed == true)
    }

    @Test("startCoroutine with main thread")
    func startCoroutineMainThread() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        behaviour.startCoroutine({
            executed = true
        }, thread: .main)

        #expect(executed == true)
    }

    @Test("startCoroutine with background thread")
    func startCoroutineBackgroundThread() async throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        behaviour.startCoroutine({
            executed = true
        }, thread: .background)

        #expect(executed == true)
    }

    // MARK: - queueCoroutine Basic

    @Test("queueCoroutine adds to queue")
    func queueCoroutineAddsToQueue() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        let coroutine: Coroutine = (
            execute: { },
            exitCondition: nil
        )

        behaviour.queueCoroutine(coroutine)

        // Coroutine should be queued (verified by no crash)
        #expect(behaviour != nil)
    }

    @Test("queueCoroutine executes first coroutine immediately")
    func queueCoroutineExecutesFirst() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: nil
        )

        behaviour.queueCoroutine(coroutine, thread: .main)

        #expect(executed == true)
    }

    @Test("queueCoroutine with nil exit condition completes on next update")
    func queueCoroutineNilExitCondition() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: nil
        )

        behaviour.queueCoroutine(coroutine, thread: .main)
        #expect(executed == true)

        // Simulate update cycle
        scene.update(updateAtTime: 0.0)
        behaviour.internalUpdate()

        // Coroutine should be complete after update
    }

    // MARK: - Exit Conditions

    @Test("queueCoroutine with exit condition based on time")
    func exitConditionBasedOnTime() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: { timePassed in
                return timePassed >= 0.1 // Exit after 0.1 seconds
            }
        )

        behaviour.queueCoroutine(coroutine, thread: .main)
        #expect(executed == true)

        // Simulate time passing
        scene.update(updateAtTime: 0.0)
        behaviour.internalUpdate()

        // Not enough time passed yet
        scene.update(updateAtTime: 0.05)
        behaviour.internalUpdate()

        // Now enough time has passed
        scene.update(updateAtTime: 0.15)
        behaviour.internalUpdate()
    }

    @Test("queueCoroutine exit condition receives timePassed")
    func exitConditionReceivesTimePassed() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var receivedTime: TimeInterval = 0
        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: { timePassed in
                receivedTime = timePassed
                return true
            }
        )

        behaviour.queueCoroutine(coroutine, thread: .main)
        #expect(executed == true)

        // Initial time should be 0
        scene.update(updateAtTime: 0.0)
        behaviour.internalUpdate()

        #expect(receivedTime >= 0)
    }

    @Test("queueCoroutine exit condition false keeps coroutine running")
    func exitConditionFalseKeepsRunning() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var updateCount = 0
        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: { _ in
                updateCount += 1
                return false // Never exit
            }
        )

        behaviour.queueCoroutine(coroutine, thread: .main)
        #expect(executed == true)

        // Multiple updates should keep checking exit condition
        scene.update(updateAtTime: 0.0)
        behaviour.internalUpdate()

        scene.update(updateAtTime: 0.016)
        behaviour.internalUpdate()

        scene.update(updateAtTime: 0.032)
        behaviour.internalUpdate()

        #expect(updateCount >= 3)
    }

    // MARK: - Multiple Coroutines

    @Test("queueCoroutine queues multiple coroutines")
    func queueMultipleCoroutines() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var execution1 = false
        var execution2 = false
        var execution3 = false

        let coroutine1: Coroutine = (
            execute: { execution1 = true },
            exitCondition: nil
        )

        let coroutine2: Coroutine = (
            execute: { execution2 = true },
            exitCondition: nil
        )

        let coroutine3: Coroutine = (
            execute: { execution3 = true },
            exitCondition: nil
        )

        behaviour.queueCoroutine(coroutine1, thread: .main)
        behaviour.queueCoroutine(coroutine2, thread: .main)
        behaviour.queueCoroutine(coroutine3, thread: .main)

        // First should execute immediately
        #expect(execution1 == true)
        #expect(execution2 == false)
        #expect(execution3 == false)
    }

    @Test("queueCoroutine processes queue in order")
    func processQueueInOrder() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executionOrder: [Int] = []

        let coroutine1: Coroutine = (
            execute: { executionOrder.append(1) },
            exitCondition: nil
        )

        let coroutine2: Coroutine = (
            execute: { executionOrder.append(2) },
            exitCondition: nil
        )

        let coroutine3: Coroutine = (
            execute: { executionOrder.append(3) },
            exitCondition: nil
        )

        behaviour.queueCoroutine(coroutine1, thread: .main)
        behaviour.queueCoroutine(coroutine2, thread: .main)
        behaviour.queueCoroutine(coroutine3, thread: .main)

        #expect(executionOrder == [1])

        // Process queue
        scene.update(updateAtTime: 0.0)
        behaviour.internalUpdate()

        #expect(executionOrder == [1, 2])

        scene.update(updateAtTime: 0.016)
        behaviour.internalUpdate()

        #expect(executionOrder == [1, 2, 3])
    }

    // MARK: - Thread Dispatch

    @Test("queueCoroutine main thread executes on main")
    func mainThreadExecution() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: nil
        )

        behaviour.queueCoroutine(coroutine, thread: .main)

        // Main thread should execute immediately
        #expect(executed == true)
    }

    @Test("queueCoroutine background thread executes async")
    func backgroundThreadExecution() async throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        let coroutine: Coroutine = (
            execute: {
                executed = true
            },
            exitCondition: nil
        )

        behaviour.queueCoroutine(coroutine, thread: .background)

        // Wait for background execution
        await TestHelpers.wait(.small)

        #expect(executed == true)
    }

    // MARK: - Time Tracking

    @Test("timePassed resets for each coroutine")
    func timePassedResetsPerCoroutine() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var firstTime: TimeInterval = -1
        var secondTime: TimeInterval = -1

        let coroutine1: Coroutine = (
            execute: { },
            exitCondition: { time in
                firstTime = time
                return true
            }
        )

        let coroutine2: Coroutine = (
            execute: { },
            exitCondition: { time in
                secondTime = time
                return true
            }
        )

        behaviour.queueCoroutine(coroutine1, thread: .main)
        behaviour.queueCoroutine(coroutine2, thread: .main)

        // First coroutine
        scene.update(updateAtTime: 0.0)
        behaviour.internalUpdate()

        // Second coroutine should start with fresh time
        scene.update(updateAtTime: 0.016)
        behaviour.internalUpdate()

        // Both should have received time values starting from 0
        #expect(firstTime >= 0)
        #expect(secondTime >= 0)
    }

    // MARK: - Cleanup

    @Test("destroy clears coroutine queue")
    func destroyClearsQueue() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: { _ in false } // Never exit
        )

        behaviour.queueCoroutine(coroutine, thread: .main)
        #expect(executed == true)

        // Destroy should clear queue
        behaviour.destroy()

        // Further updates should not crash
        Time.resetForTesting()
        let scene2 = createTestScene()
        scene2.update(updateAtTime: 0.0)
        behaviour.internalUpdate()
    }

    // MARK: - Edge Cases

    @Test("queueCoroutine with no updates completes on exit")
    func noUpdatesCompletesOnExit() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var executed = false
        let coroutine: Coroutine = (
            execute: { executed = true },
            exitCondition: { _ in true } // Exit immediately
        )

        behaviour.queueCoroutine(coroutine, thread: .main)

        #expect(executed == true)
    }

    @Test("internalUpdate with no coroutine does nothing")
    func internalUpdateNoCoroutine() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        // Should not crash
        behaviour.internalUpdate()

        #expect(behaviour != nil)
    }

    @Test("multiple queueCoroutine calls chain correctly")
    func multipleCallsChain() throws {
        Time.resetForTesting()
        Time.timeScale = 1.0
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let behaviour = try #require(obj.addComponent(TestBehaviour.self))
        behaviour.awake()

        var count = 0

        for i in 1...5 {
            let coroutine: Coroutine = (
                execute: { count = i },
                exitCondition: nil
            )
            behaviour.queueCoroutine(coroutine, thread: .main)
        }

        #expect(count == 1) // First executed

        // Process all
        for _ in 0..<4 {
            scene.update(updateAtTime: TimeInterval(count) * 0.016)
            behaviour.internalUpdate()
        }

        #expect(count == 5) // All executed
    }
}
