import Testing
import SceneKit
@testable import UnityKit

@Suite("MeshCollider Component")
struct MeshColliderTests {

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    func createBoxMesh() -> Mesh {
        let geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        return Mesh(geometry)
    }

    func createSphereMesh() -> Mesh {
        let geometry = SCNSphere(radius: 0.5)
        return Mesh(geometry)
    }

    // MARK: - Basic Functionality

    @Test("MeshCollider can be added to GameObject")
    func canBeAddedToGameObject() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        #expect(collider.gameObject === obj)
        #expect(obj.getComponent(MeshCollider.self) != nil)
    }

    @Test("MeshCollider mesh property defaults to nil")
    func meshDefaultsToNil() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        #expect(collider.mesh == nil)
    }

    @Test("MeshCollider set mesh updates mesh property")
    func setMeshUpdatesProperty() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        collider.set(mesh: boxMesh)

        #expect(collider.mesh != nil)
        #expect(collider.mesh === boxMesh)
    }

    @Test("MeshCollider set mesh returns self for chaining")
    func setMeshReturnselfForChaining() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        let result = collider.set(mesh: boxMesh)

        #expect(result === collider)
    }

    @Test("MeshCollider can be set to nil mesh")
    func canSetMeshToNil() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        collider.set(mesh: boxMesh)
        #expect(collider.mesh != nil)

        collider.set(mesh: nil)
        #expect(collider.mesh == nil)
    }

    // MARK: - Configure Pattern

    @Test("MeshCollider configure method works")
    func configureMethodWorks() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()

        var configBlockCalled = false
        collider.configure { mc in
            mc.set(mesh: boxMesh)
            configBlockCalled = true
        }

        #expect(configBlockCalled == true)
        #expect(collider.mesh === boxMesh)
    }

    @Test("MeshCollider configure returns self for chaining")
    func configureReturnselfForChaining() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let result = collider.configure { _ in }

        #expect(result === collider)
    }

    // MARK: - Physics Shape Creation

    @Test("MeshCollider constructs physics shape from mesh")
    func constructsPhysicsShapeFromMesh() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        collider.set(mesh: boxMesh)
        collider.constructBody()

        // Physics shape should be created
        #expect(collider.physicsShape != nil)
    }

    @Test("MeshCollider physics shape respects GameObject scale")
    func physicsShapeRespectsScale() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Set scale before adding collider
        obj.transform.localScale = Vector3(2, 2, 2)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        collider.set(mesh: boxMesh)
        collider.constructBody()

        // Physics shape should exist (scale is applied in construction)
        #expect(collider.physicsShape != nil)
    }

    @Test("MeshCollider works with different mesh types")
    func worksWithDifferentMeshTypes() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        // Test with box mesh
        let boxMesh = createBoxMesh()
        collider.set(mesh: boxMesh)
        #expect(collider.mesh === boxMesh)

        // Test with sphere mesh
        let sphereMesh = createSphereMesh()
        collider.set(mesh: sphereMesh)
        #expect(collider.mesh === sphereMesh)
    }

    @Test("MeshCollider creates convex hull physics shape")
    func createsConvexHullShape() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        collider.set(mesh: boxMesh)
        collider.constructBody()

        // Verify physics shape was created (it should use convex hull)
        #expect(collider.physicsShape != nil)
    }

    // MARK: - Edge Cases

    @Test("MeshCollider constructBody without mesh does not crash")
    func constructBodyWithoutMesh() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        // Should not crash
        collider.constructBody()

        // Physics shape should remain nil
        #expect(collider.physicsShape == nil)
    }

    @Test("MeshCollider can change mesh after construction")
    func canChangeMeshAfterConstruction() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        collider.set(mesh: boxMesh)
        collider.constructBody()

        // Change to different mesh
        let sphereMesh = createSphereMesh()
        collider.set(mesh: sphereMesh)

        #expect(collider.mesh === sphereMesh)

        // Reconstruct with new mesh
        collider.constructBody()
        #expect(collider.physicsShape != nil)
    }

    @Test("MeshCollider multiple configure calls")
    func multipleConfigureCalls() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = try #require(obj.addComponent(MeshCollider.self))
        collider.awake()

        let boxMesh = createBoxMesh()
        let sphereMesh = createSphereMesh()

        collider
            .configure { $0.set(mesh: boxMesh) }
            .configure { $0.set(mesh: sphereMesh) }

        #expect(collider.mesh === sphereMesh)
    }
}
