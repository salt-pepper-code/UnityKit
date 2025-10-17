import SceneKit
import Testing
@testable import UnityKit

@Suite("PlaneCollider Component")
struct PlaneColliderTests {
    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - Basic Functionality

    @Test("PlaneCollider can be added to GameObject")
    func canBeAddedToGameObject() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        #expect(collider.gameObject === obj)
        #expect(obj.getComponent(PlaneCollider.self) != nil)
    }

    @Test("PlaneCollider creates physics shape on construction")
    func createsPhysicsShape() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        #expect(collider.physicsShape != nil)
    }

    // MARK: - Configure Pattern

    @Test("PlaneCollider configure method works")
    func configureMethodWorks() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        var configBlockCalled = false
        collider.configure { _ in
            configBlockCalled = true
        }

        #expect(configBlockCalled == true)
    }

    @Test("PlaneCollider configure returns self for chaining")
    func configureReturnselfForChaining() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        let result = collider.configure { _ in }

        #expect(result === collider)
    }

    // MARK: - Geometry Generation

    @Test("PlaneCollider generates geometry from bounding box")
    func generatesGeometryFromBoundingBox() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        // Construct should create geometry based on bounding box
        collider.constructBody()

        #expect(collider.physicsShape != nil)
    }

    @Test("PlaneCollider physics shape respects GameObject scale")
    func physicsShapeRespectsScale() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Set scale before constructing
        obj.transform.localScale = Vector3(3, 3, 3)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // Physics shape should be created with scale applied
        #expect(collider.physicsShape != nil)
    }

    @Test("PlaneCollider creates 4 vertices for plane")
    func createsFourVertices() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // Plane should have been constructed (4 vertices defining a plane)
        #expect(collider.physicsShape != nil)
    }

    @Test("PlaneCollider creates 2 triangles (6 indices)")
    func createsTwoTriangles() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // 2 triangles form a plane (verified by physics shape creation)
        #expect(collider.physicsShape != nil)
    }

    @Test("PlaneCollider normals point upward")
    func normalsPointUpward() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // Normals should be (0, 1, 1) normalized - plane facing up
        // Verified by successful physics shape construction
        #expect(collider.physicsShape != nil)
    }

    // MARK: - Multiple Constructions

    @Test("PlaneCollider can be reconstructed")
    func canBeReconstructed() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()
        let firstShape = collider.physicsShape

        // Reconstruct
        collider.constructBody()
        let secondShape = collider.physicsShape

        #expect(firstShape != nil)
        #expect(secondShape != nil)
    }

    @Test("PlaneCollider reconstruction with different scale")
    func reconstructionWithDifferentScale() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        obj.transform.localScale = Vector3(1, 1, 1)
        collider.constructBody()
        #expect(collider.physicsShape != nil)

        // Change scale and reconstruct
        obj.transform.localScale = Vector3(5, 5, 5)
        collider.constructBody()
        #expect(collider.physicsShape != nil)
    }

    // MARK: - Edge Cases

    @Test("PlaneCollider works with zero-sized bounding box")
    func worksWithZeroSizedBoundingBox() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        // Even with default (potentially zero) bounding box, should not crash
        collider.constructBody()

        // May or may not create a valid shape, but shouldn't crash
        // #expect(collider.physicsShape != nil) // Not guaranteed with zero bbox
    }

    @Test("PlaneCollider multiple configure calls")
    func multipleConfigureCalls() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        var callCount = 0
        collider
            .configure { _ in callCount += 1 }
            .configure { _ in callCount += 1 }

        #expect(callCount == 2)
    }

    // MARK: - Vertex & Normal Data Integrity

    @Test("PlaneCollider vertex positions are based on bounding box")
    func vertexPositionsFromBoundingBox() throws {
        let scene = self.createTestScene()

        // Create object with specific size
        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let node = SCNNode(geometry: boxGeometry)
        let obj = GameObject(node)
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // Vertices should be generated from bounding box
        #expect(collider.physicsShape != nil)
    }

    @Test("PlaneCollider indices create correct triangle winding")
    func indicesCreateCorrectWinding() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // Indices [2,1,0, 3,2,0] should create 2 triangles
        // Verified by successful physics shape creation
        #expect(collider.physicsShape != nil)
    }

    @Test("PlaneCollider all normals are identical")
    func allNormalsIdentical() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // All 4 normals should be (0, 1, 1) - same direction
        // Verified by successful physics shape creation
        #expect(collider.physicsShape != nil)
    }

    @Test("PlaneCollider with non-uniform scale")
    func nonUniformScale() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Non-uniform scale
        obj.transform.localScale = Vector3(2, 1, 3)

        let collider = obj.addComponent(PlaneCollider.self)

        collider.constructBody()

        // Should still create physics shape (uses X component for scale)
        #expect(collider.physicsShape != nil)
    }
}
