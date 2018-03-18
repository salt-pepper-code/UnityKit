
import SceneKit

public final class PlaneCollider: Collider {

    override func constructBody() {

        guard let gameObject = gameObject,
            let name = gameObject.name
            else { return }

        let boundingBox = gameObject.node.boundingBox
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
        geometry.name = name + "PlaneCollider"

        physicsShape = SCNPhysicsShape(geometry: geometry,
                                       options: [.scale: gameObject.transform.localScale.x])
    }
}
