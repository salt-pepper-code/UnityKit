import SceneKit

/**
 A box-shaped primitive collider.
 */
public final class BoxCollider: Collider {
    public private(set) var size: Vector3Nullable?
    public private(set) var center: Vector3Nullable?

    @discardableResult public func set(size: Vector3Nullable?) -> BoxCollider {
        self.size = size
        return self
    }

    @discardableResult public func set(center: Vector3Nullable?) -> BoxCollider {
        self.center = center
        return self
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
     - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (BoxCollider) -> Void) -> BoxCollider {
        configurationBlock(self)
        return self
    }

    override func constructBody() {
        guard let gameObject,
              let name = gameObject.name
        else { return }

        var boundingBox = gameObject.node.boundingBox
        let boundingCenter = Volume.boundingCenter(boundingBox)

        if let x = size?.x {
            boundingBox.min.x = boundingCenter.x - (x / 2)
            boundingBox.max.x = boundingCenter.x + (x / 2)
        }
        if let y = size?.y {
            boundingBox.min.y = boundingCenter.y - (y / 2)
            boundingBox.max.y = boundingCenter.y + (y / 2)
        }
        if let z = size?.z {
            boundingBox.min.z = boundingCenter.z - (z / 2)
            boundingBox.max.z = boundingCenter.z + (z / 2)
        }

        if let center {
            boundingBox = Volume.moveCenter(boundingBox, center: center)
        }

        let vertices = [
            Vector3(boundingBox.min.x, boundingBox.min.y, boundingBox.min.z),
            Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.min.z),
            Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.min.z),
            Vector3(boundingBox.max.x, boundingBox.min.y, boundingBox.min.z),
            Vector3(boundingBox.max.x, boundingBox.min.y, boundingBox.max.z),
            Vector3(boundingBox.max.x, boundingBox.max.y, boundingBox.max.z),
            Vector3(boundingBox.min.x, boundingBox.max.y, boundingBox.max.z),
            Vector3(boundingBox.min.x, boundingBox.min.y, boundingBox.max.z),
        ]

        let indices: [Int16] = [
            0, 1, 2,
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
            4, 6, 7,
        ]

        let normals = [
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
            Vector3(0, 0, 1),
        ]

        let vertexData = Data(bytes: vertices, count: vertices.count * MemoryLayout<Vector3>.size)
        let vertexSource = SCNGeometrySource(
            data: vertexData,
            semantic: .vertex,
            vectorCount: vertices.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Vector3>.size
        )

        let normalData = Data(bytes: normals, count: normals.count * MemoryLayout<Vector3>.size)
        let normalSource = SCNGeometrySource(
            data: normalData,
            semantic: .normal,
            vectorCount: normals.count,
            usesFloatComponents: true,
            componentsPerVector: 3,
            bytesPerComponent: MemoryLayout<Float>.size,
            dataOffset: 0,
            dataStride: MemoryLayout<Vector3>.size
        )

        let indexData = Data(bytes: indices, count: indices.count * MemoryLayout<Int16>.size)
        let element = SCNGeometryElement(
            data: indexData,
            primitiveType: .triangles,
            primitiveCount: indices.count / 3,
            bytesPerIndex: MemoryLayout<Int16>.size
        )

        let geometry = SCNGeometry(sources: [vertexSource, normalSource], elements: [element])
        geometry.name = name + "BoxCollider"

        physicsShape = SCNPhysicsShape(
            geometry: geometry,
            options: [
                .type: SCNPhysicsShape.ShapeType.boundingBox,
                .scale: gameObject.transform.localScale.x,
            ]
        )
    }
}
