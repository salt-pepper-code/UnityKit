import SceneKit
import Testing
@testable import UnityKit

@Suite("Physics Raycasting")
struct PhysicsTests {
    // MARK: - Helper to create test scene

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    func addBox(name: String, position: Vector3, to scene: Scene, layer: GameObject.Layer = .default) -> GameObject {
        // Create a box with actual geometry so it has a valid bounding box
        let boxGeometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.name = name

        let box = GameObject(boxNode)
        box.layer = layer
        box.transform.position = position
        scene.addGameObject(box)
        _ = box.addComponent(BoxCollider.self)
        return box
    }

    // MARK: - Basic Raycast Tests

    @Test("Raycast hits box directly in front")
    func raycastHitsBoxInFront() throws {
        let scene = self.createTestScene()
        let box = self.addBox(name: "Box", position: Vector3(0, 0, 10), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        ))

        #expect(hit.gameObject === box)
        #expect(hit.distance > 0)
    }

    @Test("Raycast misses box to the side")
    func raycastMissesBox() {
        let scene = self.createTestScene()
        _ = self.addBox(name: "Box", position: Vector3(10, 0, 10), to: scene)

        let hit = Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        )

        #expect(hit == nil)
    }

    @Test("Raycast respects maxDistance")
    func raycastRespectsMaxDistance() throws {
        let scene = self.createTestScene()
        _ = self.addBox(name: "Box", position: Vector3(0, 0, 100), to: scene)

        // Raycast with maxDistance too short
        let missHit = Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            maxDistance: 50,
            in: scene
        )

        #expect(missHit == nil)

        // Raycast with maxDistance long enough
        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            maxDistance: 150,
            in: scene
        ))

        #expect(hit.distance > 0)
    }

    @Test("Raycast finds closest object when multiple in path")
    func raycastFindsClosest() throws {
        let scene = self.createTestScene()
        let nearBox = self.addBox(name: "NearBox", position: Vector3(0, 0, 10), to: scene)
        _ = self.addBox(name: "FarBox", position: Vector3(0, 0, 20), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        ))

        #expect(hit.gameObject === nearBox)
        #expect(hit.distance < 15)
    }

    // MARK: - RaycastAll Tests

    @Test("RaycastAll returns all hits sorted by distance")
    func raycastAllReturnsSortedHits() {
        let scene = self.createTestScene()
        let box1 = self.addBox(name: "Box1", position: Vector3(0, 0, 30), to: scene)
        let box2 = self.addBox(name: "Box2", position: Vector3(0, 0, 10), to: scene)
        let box3 = self.addBox(name: "Box3", position: Vector3(0, 0, 20), to: scene)

        let hits = Physics.RaycastAll(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        )

        // Filter out non-box objects (like the default camera)
        let boxHits = hits.filter { hit in
            hit.gameObject?.name?.starts(with: "Box") ?? false
        }

        #expect(boxHits.count == 3, "Expected 3 box hits, got \(boxHits.count). Total hits: \(hits.count)")
        guard boxHits.count >= 3 else { return }
        #expect(boxHits[0].gameObject === box2)
        #expect(boxHits[1].gameObject === box3)
        #expect(boxHits[2].gameObject === box1)
        #expect(boxHits[0].distance < boxHits[1].distance)
        #expect(boxHits[1].distance < boxHits[2].distance)
    }

    @Test("RaycastAll respects maxDistance")
    func raycastAllRespectsMaxDistance() {
        let scene = self.createTestScene()
        let box1 = self.addBox(name: "Box1", position: Vector3(0, 0, 10), to: scene)
        let box2 = self.addBox(name: "Box2", position: Vector3(0, 0, 50), to: scene)
        _ = self.addBox(name: "Box3", position: Vector3(0, 0, 100), to: scene)

        let hits = Physics.RaycastAll(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            maxDistance: 60,
            in: scene
        )

        // Filter out non-box objects (like the default camera)
        let boxHits = hits.filter { hit in
            hit.gameObject?.name?.starts(with: "Box") ?? false
        }

        #expect(boxHits.count == 2, "Expected 2 box hits, got \(boxHits.count). Total hits: \(hits.count)")
        guard boxHits.count >= 2 else { return }
        #expect(boxHits[0].gameObject === box1)
        #expect(boxHits[1].gameObject === box2)
    }

    // MARK: - Ray Direction Tests

    @Test("Raycast normalizes direction vector")
    func raycastNormalizesDirection() throws {
        let scene = self.createTestScene()
        let box = self.addBox(name: "Box", position: Vector3(0, 0, 10), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 100),
            in: scene
        ))

        #expect(hit.gameObject === box)
    }

    @Test("Raycast works in negative direction")
    func raycastNegativeDirection() throws {
        let scene = self.createTestScene()
        let box = self.addBox(name: "Box", position: Vector3(0, 0, -10), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, -1),
            in: scene
        ))

        #expect(hit.gameObject === box)
    }

    @Test("Raycast works at 45 degree angle")
    func raycastDiagonal() throws {
        let scene = self.createTestScene()
        let box = self.addBox(name: "Box", position: Vector3(10, 10, 10), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(1, 1, 1).normalized(),
            in: scene
        ))

        #expect(hit.gameObject === box)
    }

    // MARK: - Hit Information Tests

    @Test("RaycastHit contains correct information")
    func raycastHitInformation() throws {
        let scene = self.createTestScene()
        let box = self.addBox(name: "TestBox", position: Vector3(0, 0, 10), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        ))

        #expect(hit.gameObject === box)
        #expect(hit.collider != nil)
        #expect(hit.distance > 0)
        #expect(hit.point.z > 0)
    }

    @Test("RaycastHit normal points away from hit surface")
    func raycastHitNormal() throws {
        let scene = self.createTestScene()
        let box = self.addBox(name: "Box", position: Vector3(0, 0, 10), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        ))

        #expect(hit.gameObject === box)
        // Normal should point back toward ray origin (negative Z)
        #expect(hit.normal.z < 0)
    }

    // MARK: - Edge Cases

    @Test("Raycast from origin (0,0,0)")
    func raycastFromOrigin() throws {
        let scene = self.createTestScene()
        let box = self.addBox(name: "Box", position: Vector3(5, 0, 0), to: scene)

        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(1, 0, 0),
            in: scene
        ))

        #expect(hit.gameObject === box)
    }

    @Test("Raycast with no colliders returns nil")
    func raycastEmptyScene() {
        let scene = self.createTestScene()

        let hit = Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        )

        #expect(hit == nil)
    }

    @Test("Raycast with nil scene returns nil")
    func raycastNilScene() {
        let hit = Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: nil
        )

        #expect(hit == nil)
    }

    @Test("RaycastAll with no colliders returns empty array")
    func raycastAllEmptyScene() {
        let scene = self.createTestScene()

        let hits = Physics.RaycastAll(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            in: scene
        )

        #expect(hits.isEmpty)
    }

    // MARK: - Layer Mask Tests

    @Test("Raycast respects layer mask")
    func raycastLayerMask() throws {
        let scene = self.createTestScene()

        // Create box on default layer
        let box1 = self.addBox(name: "Box1", position: Vector3(0, 0, 10), to: scene, layer: .default)

        // Create box on player layer (closer)
        _ = self.addBox(name: "Box2", position: Vector3(0, 0, 5), to: scene, layer: .player)

        // Raycast with default layer only (should hit box1, not box2)
        let hit = try #require(Physics.Raycast(
            origin: Vector3(0, 0, 0),
            direction: Vector3(0, 0, 1),
            layerMask: .default,
            in: scene
        ))

        #expect(hit.gameObject === box1)
    }
}
