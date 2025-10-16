import Testing
import SceneKit
@testable import UnityKit

@Suite("ParticleSystem Component")
struct ParticleSystemTests {

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - Basic Setup

    @Test("ParticleSystem component can be added to GameObject")
    func particleSystemCanBeAdded() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        #expect(particleSystem.gameObject === obj)
    }

    @Test("ParticleSystem starts with nil scnParticleSystem")
    func particleSystemStartsNil() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        #expect(particleSystem.scnParticleSystem == nil)
    }

    // MARK: - Execute Block

    @Test("execute block is called with scnParticleSystem")
    func executeBlockCalled() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        var blockCalled = false
        particleSystem.execute { system in
            blockCalled = true
            #expect(system == nil)
        }

        #expect(blockCalled == true)
    }

    @Test("execute block returns self for chaining")
    func executeBlockReturnsChaining() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        let result = particleSystem.execute { _ in }

        #expect(result === particleSystem)
    }

    @Test("execute block can be chained")
    func executeBlockCanBeChained() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        var count = 0
        particleSystem
            .execute { _ in count += 1 }
            .execute { _ in count += 10 }
            .execute { _ in count += 100 }

        #expect(count == 111)
    }

    // MARK: - Execute After

    @Test("executeAfter block is called after delay")
    func executeAfterBlockCalled() async throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        var blockCalled = false
        particleSystem.executeAfter(milliseconds: 10) { system in
            blockCalled = true
            #expect(system == nil)
        }

        #expect(blockCalled == false)

        // Wait for the block to execute
        await TestHelpers.wait(.long)

        #expect(blockCalled == true)
    }

    @Test("executeAfter returns self for chaining")
    func executeAfterReturnsChaining() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        let result = particleSystem.executeAfter(milliseconds: 10) { _ in }

        #expect(result === particleSystem)
    }

    // MARK: - onDestroy

    @Test("onDestroy clears scnParticleSystem")
    func onDestroyClearsSystem() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

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
    func onDestoryRemovesFromNode() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

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
    func onDestroyWithNilDoesNotCrash() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        #expect(particleSystem.scnParticleSystem == nil)

        // Should not crash
        particleSystem.onDestroy()

        #expect(particleSystem.scnParticleSystem == nil)
    }

    // MARK: - Load (Limited Testing)

    @Test("load with invalid file returns self")
    func loadInvalidFileReturnsSelf() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        let result = particleSystem.load(
            fileName: "NonExistentFile.scnp",
            loops: false
        )

        #expect(result === particleSystem)
        #expect(particleSystem.scnParticleSystem == nil)
    }

    // MARK: - Integration

    @Test("Execute and executeAfter can be chained")
    func executeAndExecuteAfterChain() async throws {
        let scene = createTestScene()
        let obj = GameObject(name: "ParticleObject")
        scene.addGameObject(obj)

        let particleSystem = try #require(obj.addComponent(ParticleSystem.self))
        particleSystem.awake()

        var immediateExecuted = false
        var delayedExecuted = false

        particleSystem
            .execute { _ in immediateExecuted = true }
            .executeAfter(milliseconds: 10) { _ in delayedExecuted = true }

        #expect(immediateExecuted == true)
        #expect(delayedExecuted == false)

        await TestHelpers.wait(.long)

        #expect(delayedExecuted == true)
    }

    @Test("Multiple components work independently")
    func multipleComponentsIndependent() throws {
        let scene = createTestScene()
        let obj1 = GameObject(name: "Particle1")
        let obj2 = GameObject(name: "Particle2")
        scene.addGameObject(obj1)
        scene.addGameObject(obj2)

        let ps1 = try #require(obj1.addComponent(ParticleSystem.self))
        let ps2 = try #require(obj2.addComponent(ParticleSystem.self))
        ps1.awake()
        ps2.awake()

        let system1 = SCNParticleSystem()
        let system2 = SCNParticleSystem()

        ps1.scnParticleSystem = system1
        ps2.scnParticleSystem = system2

        #expect(ps1.scnParticleSystem !== ps2.scnParticleSystem)
    }
}
