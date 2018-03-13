
import SceneKit

extension Array {
    public mutating func appendContentsOf(newElements: [Element]) {
        newElements.forEach {
            self.append($0)
        }
    }
}

public class Collider: Component {

    private var colliderGameObject: GameObject?
    public var displayCollider: Bool = false {
        didSet {
            constructBody()
        }
    }
    private var physicsShape: SCNPhysicsShape?
    internal var physicsBodyType: SCNPhysicsBodyType = .kinematic

    internal static func getAllColliders(in gameObject: GameObject) -> [Collider] {

        var colliders = [Collider]()
        colliders.appendContentsOf(newElements: gameObject.getComponents(BoxCollider.self))
        colliders.appendContentsOf(newElements: gameObject.getComponents(PlaneCollider.self))
        return colliders
    }

    private func getAllPhysicsShapes() -> [SCNPhysicsShape]? {

        guard let gameObject = gameObject
            else { return nil }

        return Collider.getAllColliders(in: gameObject)
            .flatMap { (collider) -> SCNPhysicsShape? in collider.physicsShape }
    }

    public override func awake() {
        constructBody()
    }

    internal func constructBody() {
        fatalError("constructBody has not been implemented")
    }

    internal func createVisibleCollider(_ geometry: SCNGeometry) {

        colliderGameObject?.destroy()
        colliderGameObject = nil

        if displayCollider {
            let collider = GameObject(SCNNode(geometry: geometry)).setColor(.blue).setOpacity(0.3)
            gameObject?.addChild(collider)
            colliderGameObject = collider
        }
    }

    fileprivate func updatePhysicsShape(_ physicsShape: SCNPhysicsShape) {

        guard let gameObject = gameObject
            else { return }

        self.physicsShape = physicsShape

        var physicsShape = physicsShape

        if let physicsShapes = getAllPhysicsShapes(),
            physicsShapes.count > 1 {

            physicsShape = SCNPhysicsShape(shapes: physicsShapes, transforms: nil)
        }

        let useGravity: Bool

        if let rigidBody = gameObject.getComponent(RigidBody.self) {
            useGravity = rigidBody.useGravity
            physicsBodyType = rigidBody.isKinematic ? .kinematic : .dynamic
        } else {
            useGravity = true
        }

        let physicsBody = SCNPhysicsBody(type: physicsBodyType, shape: physicsShape)
        physicsBody.isAffectedByGravity = useGravity

        gameObject.node.physicsBody = physicsBody
    }
}

public class BoxCollider: Collider {

    override func constructBody() {

        guard let gameObject = gameObject
            else { return }

        let boundingBox = gameObject.node.boundingBox * gameObject.transform.localScale
        let vertices = [Vector3(boundingBox.min.x, boundingBox.min.y, boundingBox.min.z),
                        Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.min.z),
                        Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.min.z),
                        Vector3(boundingBox.max.x, boundingBox.min.y, boundingBox.min.z),
                        Vector3(boundingBox.max.x, boundingBox.min.y, boundingBox.max.z),
                        Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.max.z),
                        Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.max.z),
                        Vector3(boundingBox.min.x, boundingBox.min.y, boundingBox.max.z)]

        let indices: [Int16] = [0, 1, 2,
                                0, 2, 3,
                                3, 2, 5,
                                3, 5, 4,
                                5, 2, 1,
                                5, 1, 6,
                                3, 4, 7,
                                3, 7, 0,
                                0, 7, 6,
                                0, 6, 1,
                                4, 5, 6,
                                4, 6, 7]

        let normals = [Vector3(0, 0, 1),
                       Vector3(0, 0, 1),
                       Vector3(0, 0, 1),
                       Vector3(0, 0, 1),
                       Vector3(0, 0, 1),
                       Vector3(0, 0, 1),
                       Vector3(0, 0, 1),
                       Vector3(0, 0, 1)]

        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Vector3>.size)
        let vertexSource = SCNGeometrySource(data: vertexData,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Vector3>.size)

        let normalData = Data(bytes: normals, count: normals.count * MemoryLayout<Vector3>.size)
        let normalSource = SCNGeometrySource(data: normalData,
                                             semantic: .normal,
                                             vectorCount: normals.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Vector3>.size)



        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int16>.size)
        let element = SCNGeometryElement(data: indexData,
                                         primitiveType: .triangles,
                                         primitiveCount: indices.count / 3,
                                         bytesPerIndex: MemoryLayout<Int16>.size)

        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])

        updatePhysicsShape(SCNPhysicsShape(geometry: geometry))
        createVisibleCollider(geometry)
    }
}

public class PlaneCollider: Collider {

    override func constructBody() {

        guard let gameObject = gameObject
            else { return }

        let boundingBox = gameObject.node.boundingBox * gameObject.transform.localScale
        let vertices = [Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.min.z), //1 //0
                        Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.min.z), //2 //1
                        Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.max.z), //5 //2
                        Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.max.z)] //6 //3

        let indices: [Int16] = [2, 1, 0,
                                3, 2, 0]

        let normals = [Vector3(0, 1, 1),
                       Vector3(0, 1, 1),
                       Vector3(0, 1, 1),
                       Vector3(0, 1, 1)]

        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Vector3>.size)
        let vertexSource = SCNGeometrySource(data: vertexData,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Vector3>.size)

        let normalData = Data(bytes: normals, count: normals.count * MemoryLayout<Vector3>.size)
        let normalSource = SCNGeometrySource(data: normalData,
                                             semantic: .normal,
                                             vectorCount: normals.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<Vector3>.size)



        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int16>.size)
        let element = SCNGeometryElement(data: indexData,
                                         primitiveType: .triangles,
                                         primitiveCount: indices.count / 3,
                                         bytesPerIndex: MemoryLayout<Int16>.size)

        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])

        updatePhysicsShape(SCNPhysicsShape(geometry: geometry))
        createVisibleCollider(geometry)
    }
}
