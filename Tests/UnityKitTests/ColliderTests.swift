import Testing
import SceneKit
@testable import UnityKit

@Suite("Collider Components")
struct ColliderTests {

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - SphereCollider Tests

    @Test("SphereCollider can be added to GameObject")
    func addSphereCollider() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "Sphere")
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        collider.awake()

        #expect(obj.getComponent(SphereCollider.self) != nil)
        #expect(obj.getComponent(Collider.self) != nil)
    }

    @Test("SphereCollider uses custom radius when set")
    func sphereColliderCustomRadius() throws {
        let scene = createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        collider.set(radius: 5.0)
        collider.awake()

        #expect(collider.radius == 5.0)
    }

    @Test("SphereCollider can set center offset")
    func sphereColliderCenter() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "Sphere")
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        let centerOffset = Vector3(1, 2, 3)
        collider.set(center: centerOffset)
        collider.awake()

        #expect(collider.center == centerOffset)
    }

    @Test("SphereCollider configure method works")
    func sphereColliderConfigure() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "Sphere")
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        collider.configure { sphere in
            sphere.set(radius: 3.0)
            sphere.set(center: Vector3(0, 1, 0))
        }
        collider.awake()

        #expect(collider.radius == 3.0)
        #expect(collider.center == Vector3(0, 1, 0))
    }

    @Test("SphereCollider is detected by Physics.overlapSphere")
    func sphereColliderPhysicsDetection() throws {
        let scene = createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "SphereObject"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(5, 0, 0)
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        collider.awake()

        // Should be detected when overlapping
        let overlapping = Physics.overlapSphere(
            position: Vector3(5, 0, 0),
            radius: 2.0,
            in: scene
        )

        #expect(overlapping.count >= 1)
        #expect(overlapping.contains(where: { $0 === collider }))
    }

    // MARK: - CapsuleCollider Tests

    @Test("CapsuleCollider can be added to GameObject")
    func addCapsuleCollider() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "Capsule")
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.awake()

        #expect(obj.getComponent(CapsuleCollider.self) != nil)
        #expect(obj.getComponent(Collider.self) != nil)
    }

    @Test("CapsuleCollider uses custom radius and height when set")
    func capsuleColliderCustomDimensions() throws {
        let scene = createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 4, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.set(radius: 1.5)
        collider.set(height: 5.0)
        collider.awake()

        #expect(collider.radius == 1.5)
        #expect(collider.height == 5.0)
    }

    @Test("CapsuleCollider can set center offset")
    func capsuleColliderCenter() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "Capsule")
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        let centerOffset = Vector3(0, 1, 0)
        collider.set(center: centerOffset)
        collider.awake()

        #expect(collider.center == centerOffset)
    }

    @Test("CapsuleCollider configure method works")
    func capsuleColliderConfigure() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "Capsule")
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.configure { capsule in
            capsule.set(radius: 0.5)
            capsule.set(height: 2.0)
            capsule.set(center: Vector3(0, 0.5, 0))
        }
        collider.awake()

        #expect(collider.radius == 0.5)
        #expect(collider.height == 2.0)
        #expect(collider.center == Vector3(0, 0.5, 0))
    }

    @Test("CapsuleCollider is detected by Physics.overlapSphere")
    func capsuleColliderPhysicsDetection() throws {
        let scene = createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "CapsuleObject"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(10, 0, 0)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.awake()

        // Should be detected when overlapping
        let overlapping = Physics.overlapSphere(
            position: Vector3(10, 0, 0),
            radius: 2.0,
            in: scene
        )

        #expect(overlapping.count >= 1)
        #expect(overlapping.contains(where: { $0 === collider }))
    }

    // MARK: - BoxCollider Tests (for completeness)

    @Test("BoxCollider can be added to GameObject")
    func addBoxCollider() throws {
        let scene = createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.awake()

        #expect(obj.getComponent(BoxCollider.self) != nil)
        #expect(obj.getComponent(Collider.self) != nil)
    }

    @Test("BoxCollider is detected by Physics.Raycast")
    func boxColliderRaycastDetection() throws {
        let scene = createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(0, 0, 10)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.awake()

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        ))

        #expect(hit.collider === collider)
        #expect(hit.gameObject === obj)
    }

    // MARK: - Physics.overlapSphere Tests

    @Test("Physics.overlapSphere finds multiple colliders")
    func overlapSphereMultipleColliders() {
        let scene = createTestScene()

        // Create three objects at different positions
        for i in 0..<3 {
            let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.name = "Box\(i)"

            let obj = GameObject(boxNode)
            obj.transform.position = Vector3(Float(i), 0, 0)
            scene.addGameObject(obj)

            let collider = obj.addComponent(BoxCollider.self)
            collider.awake()
        }

        // Overlap sphere centered at (1, 0, 0) with radius 2
        // Should detect boxes at (0,0,0), (1,0,0), and (2,0,0)
        let overlapping = Physics.overlapSphere(
            position: Vector3(1, 0, 0),
            radius: 2.0,
            in: scene
        )

        #expect(overlapping.count == 3)
    }

    @Test("Physics.overlapSphere respects layer mask")
    func overlapSphereLayerMask() {
        let scene = createTestScene()

        // Create object on default layer
        let boxGeometry1 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode1 = SCNNode(geometry: boxGeometry1)
        boxNode1.name = "DefaultBox"
        let obj1 = GameObject(boxNode1)
        obj1.layer = .default
        obj1.transform.position = Vector3(0, 0, 0)
        scene.addGameObject(obj1)
        let collider1 = obj1.addComponent(BoxCollider.self)
        collider1.awake()

        // Create object on player layer
        let boxGeometry2 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode2 = SCNNode(geometry: boxGeometry2)
        boxNode2.name = "PlayerBox"
        let obj2 = GameObject(boxNode2)
        obj2.layer = .player
        obj2.transform.position = Vector3(1, 0, 0)
        scene.addGameObject(obj2)
        let collider2 = obj2.addComponent(BoxCollider.self)
        collider2.awake()

        // Search only default layer
        let defaultResults = Physics.overlapSphere(
            position: Vector3(0.5, 0, 0),
            radius: 2.0,
            layerMask: .default,
            in: scene
        )

        #expect(defaultResults.count == 1)
        #expect(defaultResults.first?.gameObject?.name == "DefaultBox")

        // Search only player layer
        let playerResults = Physics.overlapSphere(
            position: Vector3(0.5, 0, 0),
            radius: 2.0,
            layerMask: .player,
            in: scene
        )

        #expect(playerResults.count == 1)
        #expect(playerResults.first?.gameObject?.name == "PlayerBox")

        // Search all layers
        let allResults = Physics.overlapSphere(
            position: Vector3(0.5, 0, 0),
            radius: 2.0,
            layerMask: .all,
            in: scene
        ).filter { $0.gameObject?.name == "DefaultBox" || $0.gameObject?.name == "PlayerBox" }

        #expect(allResults.count == 2)
    }

    @Test("Physics.overlapSphere with nil scene returns empty")
    func overlapSphereNilScene() {
        let results = Physics.overlapSphere(
            position: Vector3(0, 0, 0),
            radius: 1.0,
            in: nil
        )

        #expect(results.isEmpty)
    }

    @Test("Physics.overlapSphere with no overlaps returns empty")
    func overlapSphereNoOverlaps() {
        let scene = createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "FarBox"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(100, 0, 0)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.awake()

        // Search far from the object
        let results = Physics.overlapSphere(
            position: Vector3(0, 0, 0),
            radius: 1.0,
            in: scene
        )

        #expect(results.isEmpty)
    }
}
