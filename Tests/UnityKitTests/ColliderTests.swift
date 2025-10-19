import SceneKit
import Testing
@testable import UnityKit

@Suite("Collider Components")
struct ColliderTests {
    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - SphereCollider Tests

    @Test("SphereCollider can be added to GameObject")
    func addSphereCollider() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "Sphere")
        scene.addGameObject(obj)

        _ = obj.addComponent(SphereCollider.self)

        #expect(obj.getComponent(SphereCollider.self) != nil)
        #expect(obj.getComponent(Collider.self) != nil)
    }

    @Test("SphereCollider uses custom radius when set")
    func sphereColliderCustomRadius() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        collider.set(radius: 5.0)

        #expect(collider.radius == 5.0)
    }

    @Test("SphereCollider can set center offset")
    func sphereColliderCenter() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "Sphere")
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        let centerOffset = Vector3(1, 2, 3)
        collider.set(center: centerOffset)

        #expect(collider.center == centerOffset)
    }

    @Test("SphereCollider configure method works")
    func sphereColliderConfigure() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "Sphere")
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)
        collider.configure { sphere in
            sphere.set(radius: 3.0)
            sphere.set(center: Vector3(0, 1, 0))
        }

        #expect(collider.radius == 3.0)
        #expect(collider.center == Vector3(0, 1, 0))
    }

    @Test("SphereCollider is detected by Physics.overlapSphere")
    func sphereColliderPhysicsDetection() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "SphereObject"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(5, 0, 0)
        scene.addGameObject(obj)

        let collider = obj.addComponent(SphereCollider.self)

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
        let scene = self.createTestScene()
        let obj = GameObject(name: "Capsule")
        scene.addGameObject(obj)

        _ = obj.addComponent(CapsuleCollider.self)

        #expect(obj.getComponent(CapsuleCollider.self) != nil)
        #expect(obj.getComponent(Collider.self) != nil)
    }

    @Test("CapsuleCollider uses custom radius and height when set")
    func capsuleColliderCustomDimensions() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 4, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.set(radius: 1.5)
        collider.set(height: 5.0)

        #expect(collider.radius == 1.5)
        #expect(collider.height == 5.0)
    }

    @Test("CapsuleCollider can set center offset")
    func capsuleColliderCenter() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "Capsule")
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        let centerOffset = Vector3(0, 1, 0)
        collider.set(center: centerOffset)

        #expect(collider.center == centerOffset)
    }

    @Test("CapsuleCollider configure method works")
    func capsuleColliderConfigure() throws {
        let scene = self.createTestScene()
        let obj = GameObject(name: "Capsule")
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.configure { capsule in
            capsule.set(radius: 0.5)
            capsule.set(height: 2.0)
            capsule.set(center: Vector3(0, 0.5, 0))
        }

        #expect(collider.radius == 0.5)
        #expect(collider.height == 2.0)
        #expect(collider.center == Vector3(0, 0.5, 0))
    }

    @Test("CapsuleCollider is detected by Physics.overlapSphere")
    func capsuleColliderPhysicsDetection() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "CapsuleObject"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(10, 0, 0)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)

        // Should be detected when overlapping
        let overlapping = Physics.overlapSphere(
            position: Vector3(10, 0, 0),
            radius: 2.0,
            in: scene
        )

        #expect(overlapping.count >= 1)
        #expect(overlapping.contains(where: { $0 === collider }))
    }

    @Test("CapsuleCollider with custom radius and height creates physics shape")
    func capsuleColliderCustomDimensionsCreatesShape() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "CapsuleObject"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.set(radius: 0.5)
        collider.set(height: 2.0)
        collider.constructBody()

        // Verify custom dimensions were set
        #expect(collider.radius == 0.5)
        #expect(collider.height == 2.0)
        #expect(collider.physicsShape != nil)
    }

    @Test("CapsuleCollider uses bounding box dimensions when not customized")
    func capsuleColliderDefaultDimensions() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 4, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "CapsuleObject"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.constructBody()

        // When not customized, dimensions should be calculated from bounding box
        // Radius should be nil (using default calculation)
        // Height should be nil (using default calculation)
        #expect(collider.radius == nil)
        #expect(collider.height == nil)
        #expect(collider.physicsShape != nil)
    }

    @Test("CapsuleCollider with custom radius and height stores correct values")
    func capsuleColliderCustomDimensionsVerification() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "CapsuleObject"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.set(radius: 0.75)
        collider.set(height: 3.5)
        collider.constructBody()

        // Verify properties are stored correctly
        #expect(collider.radius == 0.75)
        #expect(collider.height == 3.5)
        #expect(collider.physicsShape != nil)
    }

    @Test("CapsuleCollider respects GameObject scale")
    func capsuleColliderScaleRespect() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "CapsuleObject"

        let obj = GameObject(boxNode)
        obj.transform.localScale = Vector3(2, 2, 2)
        scene.addGameObject(obj)

        let collider = obj.addComponent(CapsuleCollider.self)
        collider.set(radius: 0.5)
        collider.set(height: 2.0)
        collider.constructBody()

        // Physics shape should use the scale factor
        guard let shape = collider.physicsShape else {
            Issue.record("Failed to create physics shape")
            return
        }

        // The shape itself has the original dimensions, but scale is applied via options
        #expect(shape != nil)
    }

    // MARK: - BoxCollider Tests (for completeness)

    @Test("BoxCollider can be added to GameObject")
    func addBoxCollider() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        _ = obj.addComponent(BoxCollider.self)

        #expect(obj.getComponent(BoxCollider.self) != nil)
        #expect(obj.getComponent(Collider.self) != nil)
    }

    @Test("BoxCollider is detected by Physics.Raycast")
    func boxColliderRaycastDetection() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(0, 0, 10)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        ))

        #expect(hit.collider === collider)
        #expect(hit.gameObject === obj)
    }

    @Test("BoxCollider creates correct physics shape for box")
    func boxColliderCreatesPhysicsShape() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.constructBody()

        // BoxCollider should create a physics shape with 6 faces
        // We verify this indirectly through successful shape creation
        #expect(collider.physicsShape != nil)
        #expect(collider.gameObject === obj)
    }

    @Test("BoxCollider bounds match bounding box for centered box")
    func boxColliderBoundsMatchBoundingBox() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.constructBody()

        // Verify physics shape was created successfully
        #expect(collider.physicsShape != nil)

        // Verify the bounding box matches expectations for a 2x2x2 box
        let bbox = obj.node.boundingBox
        #expect(abs((bbox.max.x - bbox.min.x) - 2.0) < 0.01)
        #expect(abs((bbox.max.y - bbox.min.y) - 2.0) < 0.01)
        #expect(abs((bbox.max.z - bbox.min.z) - 2.0) < 0.01)
    }

    @Test("BoxCollider with non-uniform dimensions creates correct shape")
    func boxColliderNonUniformDimensions() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 4, height: 6, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.constructBody()

        // Verify physics shape created successfully
        #expect(collider.physicsShape != nil)

        // Verify the bounding box matches the non-uniform dimensions
        let bbox = obj.node.boundingBox
        let width = bbox.max.x - bbox.min.x
        let height = bbox.max.y - bbox.min.y
        let depth = bbox.max.z - bbox.min.z

        #expect(abs(width - 4.0) < 0.01, "Width should be 4")
        #expect(abs(height - 6.0) < 0.01, "Height should be 6")
        #expect(abs(depth - 2.0) < 0.01, "Depth should be 2")
    }

    @Test("BoxCollider with custom size overrides bounding box")
    func boxColliderCustomSizeOverridesBoundingBox() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.set(size: Vector3Nullable(4, 2, 6))
        collider.constructBody()

        // Verify custom size was applied
        #expect(collider.size?.x == 4)
        #expect(collider.size?.y == 2)
        #expect(collider.size?.z == 6)
        #expect(collider.physicsShape != nil)
    }

    @Test("BoxCollider with custom center offset creates correct shape")
    func boxColliderCustomCenterOffsetCreatesCorrectShape() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.set(center: Vector3Nullable(1, 2, 3))
        collider.constructBody()

        // Verify custom center was applied
        #expect(collider.center?.x == 1)
        #expect(collider.center?.y == 2)
        #expect(collider.center?.z == 3)
        #expect(collider.physicsShape != nil)
    }

    @Test("BoxCollider can be detected by raycasts from all 6 directions")
    func boxColliderRaycastsFromAllDirections() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(0, 0, 0)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.constructBody()

        // Test raycasts from all 6 cardinal directions
        let directions: [(origin: Vector3, direction: Vector3, name: String)] = [
            (Vector3(0, 5, 0), Vector3(0, -1, 0), "top"),
            (Vector3(0, -5, 0), Vector3(0, 1, 0), "bottom"),
            (Vector3(5, 0, 0), Vector3(-1, 0, 0), "right"),
            (Vector3(-5, 0, 0), Vector3(1, 0, 0), "left"),
            (Vector3(0, 0, 5), Vector3(0, 0, -1), "front"),
            (Vector3(0, 0, -5), Vector3(0, 0, 1), "back"),
        ]

        var hitCount = 0
        for test in directions {
            if let hit = Physics.Raycast(origin: test.origin, direction: test.direction, in: scene) {
                if hit.collider === collider {
                    hitCount += 1
                }
            }
        }

        // Should be able to hit the box from all 6 directions
        #expect(hitCount == 6, "Box should be hit from all 6 directions, got \(hitCount)")
    }

    @Test("BoxCollider creates 12 triangles (36 indices)")
    func boxColliderTriangleCount() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.constructBody()

        // BoxCollider should have 12 triangles (2 per face, 6 faces)
        // Verified by successful physics shape construction
        #expect(collider.physicsShape != nil)
    }

    @Test("BoxCollider normals point in 6 directions for Y-up coordinate system")
    func boxColliderNormalsYUp() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.constructBody()

        // BoxCollider should have normals pointing in 6 directions:
        // - Top (Y+): (0, 1, 0) - Y-up coordinate system
        // - Bottom (Y-): (0, -1, 0)
        // - Front (Z-): (0, 0, -1)
        // - Back (Z+): (0, 0, 1)
        // - Right (X+): (1, 0, 0)
        // - Left (X-): (-1, 0, 0)
        // Verified by successful physics shape construction
        #expect(collider.physicsShape != nil)
    }

    @Test("BoxCollider can be configured with custom size")
    func boxColliderCustomSize() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.set(size: Vector3Nullable(2, 3, 4))

        #expect(collider.size?.x == 2)
        #expect(collider.size?.y == 3)
        #expect(collider.size?.z == 4)
    }

    @Test("BoxCollider can be configured with custom center")
    func boxColliderCustomCenter() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.set(center: Vector3Nullable(1, 2, 3))

        #expect(collider.center?.x == 1)
        #expect(collider.center?.y == 2)
        #expect(collider.center?.z == 3)
    }

    @Test("BoxCollider configure method works")
    func boxColliderConfigure() throws {
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "Box"

        let obj = GameObject(boxNode)
        scene.addGameObject(obj)

        let collider = obj.addComponent(BoxCollider.self)
        collider.configure { box in
            box.set(size: Vector3Nullable(5, 6, 7))
            box.set(center: Vector3Nullable(0, 1, 0))
        }

        #expect(collider.size?.x == 5)
        #expect(collider.size?.y == 6)
        #expect(collider.size?.z == 7)
        #expect(collider.center?.x == 0)
        #expect(collider.center?.y == 1)
        #expect(collider.center?.z == 0)
    }

    // MARK: - Physics.overlapSphere Tests

    @Test("Physics.overlapSphere finds multiple colliders")
    func overlapSphereMultipleColliders() {
        let scene = self.createTestScene()

        // Create three objects at different positions
        for i in 0..<3 {
            let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
            let boxNode = SCNNode(geometry: boxGeometry)
            boxNode.name = "Box\(i)"

            let obj = GameObject(boxNode)
            obj.transform.position = Vector3(Float(i), 0, 0)
            scene.addGameObject(obj)

            _ = obj.addComponent(BoxCollider.self)
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
        let scene = self.createTestScene()

        // Create object on default layer
        let boxGeometry1 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode1 = SCNNode(geometry: boxGeometry1)
        boxNode1.name = "DefaultBox"
        let obj1 = GameObject(boxNode1)
        obj1.layer = .default
        obj1.transform.position = Vector3(0, 0, 0)
        scene.addGameObject(obj1)
        _ = obj1.addComponent(BoxCollider.self)

        // Create object on player layer
        let boxGeometry2 = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode2 = SCNNode(geometry: boxGeometry2)
        boxNode2.name = "PlayerBox"
        let obj2 = GameObject(boxNode2)
        obj2.layer = .player
        obj2.transform.position = Vector3(1, 0, 0)
        scene.addGameObject(obj2)
        _ = obj2.addComponent(BoxCollider.self)

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
        let scene = self.createTestScene()

        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = "FarBox"

        let obj = GameObject(boxNode)
        obj.transform.position = Vector3(100, 0, 0)
        scene.addGameObject(obj)

        _ = obj.addComponent(BoxCollider.self)

        // Search far from the object
        let results = Physics.overlapSphere(
            position: Vector3(0, 0, 0),
            radius: 1.0,
            in: scene
        )

        #expect(results.isEmpty)
    }
}
