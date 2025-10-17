import SceneKit
import Testing
import UIKit
@testable import UnityKit

@Suite("ParticleSystem Component")
struct ParticleSystemTests {
    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    @MainActor
    func createTestSceneWithView() -> (scene: Scene, window: UIWindow) {
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

        window.makeKeyAndVisible()

        return (view.sceneHolder!, window)
    }

    // MARK: - Basic Setup

    @Test("ParticleSystem component can be added to GameObject")
    func particleSystemCanBeAdded() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        #expect(particleSystem.gameObject === obj)
    }

    @Test("ParticleSystem starts with nil scnParticleSystem")
    func particleSystemStartsNil() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        #expect(particleSystem.scnParticleSystem == nil)
    }

    // MARK: - Execute Block

    @Test("execute block is called with scnParticleSystem")
    func executeBlockCalled() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        var blockCalled = false
        particleSystem.execute { system in
            blockCalled = true
            #expect(system == nil)
        }

        #expect(blockCalled == true)
    }

    @Test("execute block returns self for chaining")
    func executeBlockReturnsChaining() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        let result = particleSystem.execute { _ in }

        #expect(result === particleSystem)
    }

    @Test("execute block can be chained")
    func executeBlockCanBeChained() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        var count = 0
        particleSystem
            .execute { _ in count += 1 }
            .execute { _ in count += 10 }
            .execute { _ in count += 100 }

        #expect(count == 111)
    }

    // MARK: - Execute After

    @Test("executeAfter block is called after delay")
    @MainActor
    func executeAfterBlockCalled() async throws {
        let (scene, window) = self.createTestSceneWithView()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        var blockCalled = false
        particleSystem.executeAfter(milliseconds: 10) { system in
            blockCalled = true
            #expect(system == nil)
        }

        #expect(blockCalled == false)

        // Wait for the block to execute
        await TestHelpers.wait(.long)

        #expect(blockCalled == true)

        // Cleanup
        window.isHidden = true
    }

    @Test("executeAfter returns self for chaining")
    func executeAfterReturnsChaining() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        let result = particleSystem.executeAfter(milliseconds: 10) { _ in }

        #expect(result === particleSystem)
    }

    // MARK: - onDestroy

    @Test("onDestroy clears scnParticleSystem")
    func onDestroyClearsSystem() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        // Create a mock particle system
        let scnSystem = SCNParticleSystem()
        particleSystem.scnParticleSystem = scnSystem
        obj.node.addParticleSystem(scnSystem)

        #expect(particleSystem.scnParticleSystem != nil)

        // Destroy
        particleSystem.onDestroy()

        #expect(particleSystem.scnParticleSystem == nil)
    }

    @Test("onDestroy removes particle system from node")
    func onDestoryRemovesFromNode() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        // Create a mock particle system
        let scnSystem = SCNParticleSystem()
        particleSystem.scnParticleSystem = scnSystem
        obj.node.addParticleSystem(scnSystem)

        #expect(obj.node.particleSystems?.count == 1)

        // Destroy
        particleSystem.onDestroy()

        #expect(obj.node.particleSystems?.count == 0)
    }

    @Test("onDestroy with nil scnParticleSystem does not crash")
    func onDestroyWithNilDoesNotCrash() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        #expect(particleSystem.scnParticleSystem == nil)

        // Should not crash
        particleSystem.onDestroy()

        #expect(particleSystem.scnParticleSystem == nil)
    }

    // MARK: - Load (Limited Testing)

    @Test("load with invalid file returns self")
    func loadInvalidFileReturnsSelf() {
        let scene = self.createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        let result = particleSystem.load(
            fileName: "NonExistentFile.scnp",
            loops: false
        )

        #expect(result === particleSystem)
        #expect(particleSystem.scnParticleSystem == nil)
    }

    // MARK: - Integration

    @Test("Execute and executeAfter can be chained")
    @MainActor
    func executeAndExecuteAfterChain() async throws {
        let (scene, window) = self.createTestSceneWithView()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = obj.addComponent(ParticleSystem.self)

        var immediateExecuted = false
        var delayedExecuted = false

        particleSystem
            .execute { _ in immediateExecuted = true }
            .executeAfter(milliseconds: 10) { _ in delayedExecuted = true }

        #expect(immediateExecuted == true)
        #expect(delayedExecuted == false)

        await TestHelpers.wait(.long)

        #expect(delayedExecuted == true)

        // Cleanup
        window.isHidden = true
    }

    @Test("Multiple components work independently")
    func multipleComponentsIndependent() {
        let scene = self.createTestScene()
        let obj1 = GameObject(name: "Particle1")
        let obj2 = GameObject(name: "Particle2")
        scene.addGameObject(obj1)
        scene.addGameObject(obj2)

        let ps1 = obj1.addComponent(ParticleSystem.self)
        let ps2 = obj2.addComponent(ParticleSystem.self)

        let system1 = SCNParticleSystem()
        let system2 = SCNParticleSystem()

        ps1.scnParticleSystem = system1
        ps2.scnParticleSystem = system2

        #expect(ps1.scnParticleSystem !== ps2.scnParticleSystem)
    }
}
