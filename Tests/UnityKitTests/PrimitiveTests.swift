import SceneKit
import Testing
@testable import UnityKit

@Suite("Primitive Geometry")
struct PrimitiveTests {
    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - Floor Primitive Tests

    @Test("Floor primitive is centered at origin")
    func floorIsCentered() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20), name: "TestFloor")
        scene.addGameObject(floor)

        #expect(floor.transform.position == Vector3(0, 0, 0))

        #expect(floor.node.geometry != nil)

        guard let geometry = floor.node.geometry,
              let vertexSource = geometry.sources(for: .vertex).first else {
            Issue.record("Failed to get vertex source from floor")
            return
        }

        let vertices = SCNGeometry.vertices(source: vertexSource)

        var minX: Float = .infinity
        var maxX: Float = -.infinity
        var minZ: Float = .infinity
        var maxZ: Float = -.infinity

        for vertex in vertices {
            minX = min(minX, vertex.x)
            maxX = max(maxX, vertex.x)
            minZ = min(minZ, vertex.z)
            maxZ = max(maxZ, vertex.z)
        }

        let centerX = (minX + maxX) / 2
        let centerZ = (minZ + maxZ) / 2

        #expect(abs(centerX) < 0.01)
        #expect(abs(centerZ) < 0.01)
    }

    @Test("Floor primitive is rotated to be horizontal")
    func floorIsHorizontal() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20), name: "TestFloor")
        scene.addGameObject(floor)

        // Floor should be rotated -90 degrees on X-axis to lie flat on XZ plane
        // Use small tolerance for floating point comparison
        #expect(abs(floor.transform.localEulerAngles.x - (-90)) < 0.01)
        #expect(abs(floor.transform.localEulerAngles.y) < 0.01)
        #expect(abs(floor.transform.localEulerAngles.z) < 0.01)
    }

    @Test("Floor primitive has correct dimensions")
    func floorHasCorrectDimensions() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20), name: "TestFloor")
        scene.addGameObject(floor)

        guard let plane = floor.node.geometry as? SCNPlane else {
            Issue.record("Floor geometry should be SCNPlane")
            return
        }

        // Floor uses SCNPlane with width and height (length) parameters
        #expect(plane.width == 10.0)
        #expect(plane.height == 20.0)
    }

    @Test("Floor primitive has correct name")
    func floorHasCorrectName() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20), name: "MyFloor")
        scene.addGameObject(floor)

        #expect(floor.name == "MyFloor")
    }

    @Test("Floor primitive uses default name when not specified")
    func floorUsesDefaultName() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20))
        scene.addGameObject(floor)

        #expect(floor.name == "Floor")
    }

    @Test("Floor primitive is centered on XZ plane")
    func floorIsCenteredOnXZPlane() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20), name: "TestFloor")
        scene.addGameObject(floor)

        let boundingBox = floor.node.boundingBox

        let center = Vector3(
            (boundingBox.min.x + boundingBox.max.x) / 2,
            (boundingBox.min.y + boundingBox.max.y) / 2,
            (boundingBox.min.z + boundingBox.max.z) / 2
        )

        #expect(abs(center.x) < 0.01)
        #expect(abs(center.y) < 0.01)
        #expect(abs(center.z) < 0.01)
    }

    @Test("Floor vertices are positioned symmetrically around origin")
    func floorVerticesAreSymmetric() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20), name: "TestFloor")
        scene.addGameObject(floor)

        guard let geometry = floor.node.geometry,
              let vertexSource = geometry.sources(for: .vertex).first else {
            Issue.record("Failed to get vertex source from floor")
            return
        }

        let vertices = SCNGeometry.vertices(source: vertexSource)

        #expect(vertices.count == 4)

        // Floor is created as SCNPlane(width=10, height=20) then rotated -90° on X
        // Before rotation: vertices are in XY plane with X for width, Y for height
        // So we check X and Y dimensions, not X and Z
        var minX: Float = .infinity
        var maxX: Float = -.infinity
        var minY: Float = .infinity
        var maxY: Float = -.infinity

        for vertex in vertices {
            minX = min(minX, vertex.x)
            maxX = max(maxX, vertex.x)
            minY = min(minY, vertex.y)
            maxY = max(maxY, vertex.y)
        }

        // Vertices should be symmetric around origin
        #expect(abs(minX + maxX) < 0.01)
        #expect(abs(minY + maxY) < 0.01)

        // Check actual vertex extents
        let actualWidth = maxX - minX
        let actualHeight = maxY - minY

        // IMPORTANT: SCNPlane vertices are in normalized unit space (±0.5 = 1.0 unit)
        // The actual world-space dimensions come from the geometry's width/height properties
        // Vertices span from -0.5 to +0.5 (1.0 unit total) regardless of plane dimensions
        #expect(abs(actualWidth - 1.0) < 0.01, "Vertices should span 1.0 unit in X (normalized space)")
        #expect(abs(actualHeight - 1.0) < 0.01, "Vertices should span 1.0 unit in Y (normalized space)")

        // Verify the geometry specification has the correct dimensions
        guard let plane = floor.node.geometry as? SCNPlane else {
            Issue.record("Floor should use SCNPlane geometry")
            return
        }

        #expect(Float(plane.width) == 10.0, "SCNPlane width property should be 10")
        #expect(Float(plane.height) == 20.0, "SCNPlane height property should be 20")
    }

    @Test("Floor vertices lie in XY plane at Z=0 (before rotation)")
    func floorVerticesAtZZero() throws {
        let scene = self.createTestScene()

        let floor = GameObject.createPrimitive(.floor(width: 10, length: 20), name: "TestFloor")
        scene.addGameObject(floor)

        guard let geometry = floor.node.geometry,
              let vertexSource = geometry.sources(for: .vertex).first else {
            Issue.record("Failed to get vertex source from floor")
            return
        }

        let vertices = SCNGeometry.vertices(source: vertexSource)

        // SCNPlane vertices are in the XY plane (Z=0) before rotation
        // After -90° rotation on X, the plane becomes horizontal on XZ
        for vertex in vertices {
            #expect(abs(vertex.z) < 0.01, "Vertex Z should be 0 (in local space before rotation)")
        }
    }

    // MARK: - Other Primitive Tests

    @Test("Sphere primitive can be created")
    func sphereCanBeCreated() throws {
        let scene = self.createTestScene()

        let sphere = GameObject.createPrimitive(.sphere(radius: 1.0), name: "TestSphere")
        scene.addGameObject(sphere)

        #expect(sphere.node.geometry != nil)
        #expect(sphere.name == "TestSphere")
    }

    @Test("Cube primitive can be created")
    func cubeCanBeCreated() throws {
        let scene = self.createTestScene()

        let cube = GameObject.createPrimitive(
            .cube(width: 1, height: 1, length: 1, chamferRadius: 0),
            name: "TestCube"
        )
        scene.addGameObject(cube)

        #expect(cube.node.geometry != nil)
        #expect(cube.name == "TestCube")
    }

    @Test("Plane primitive can be created")
    func planeCanBeCreated() throws {
        let scene = self.createTestScene()

        let plane = GameObject.createPrimitive(.plane(width: 10, height: 10), name: "TestPlane")
        scene.addGameObject(plane)

        #expect(plane.node.geometry != nil)
        #expect(plane.name == "TestPlane")
    }

    @Test("Plane primitive is vertical (not rotated)")
    func planeIsVertical() throws {
        let scene = self.createTestScene()

        let plane = GameObject.createPrimitive(.plane(width: 10, height: 10), name: "TestPlane")
        scene.addGameObject(plane)

        // Plane should NOT be rotated (unlike floor)
        #expect(plane.transform.localEulerAngles == Vector3(0, 0, 0))
    }
}
