import SceneKit

public enum PrimitiveType {
    case sphere(
        radius: Float,
        name: String? = nil
    )
    case capsule(
        capRadius: Float,
        height: Float,
        name: String? = nil
    )
    case cylinder(
        radius: Float,
        height: Float,
        name: String? = nil
    )
    case cube(
        width: Float,
        height: Float,
        length: Float,
        chamferRadius: Float,
        name: String? = nil
    )
    case plane(
        width: Float,
        height: Float,
        name: String? = nil
    )
    case floor(
        width: Float,
        length: Float,
        name: String? = nil
    )

    var name: String {
        switch self {
        case .sphere(_, let n):
            return n ?? "Sphere"

        case .capsule(_, _, let n):
            return n ?? "Capsule"

        case .cylinder(_, _, let n):
            return n ?? "Cylinder"

        case .cube(_, _, _, _, let n):
            return n ?? "Cube"

        case .plane(_, _, let n):
            return n ?? "Plane"

        case .floor(_, _, let n):
            return n ?? "Floor"
        }
    }
}

public extension GameObject {
    static func createPrimitive(_ type: PrimitiveType) -> GameObject {
        let geometry = SCNGeometry.createPrimitive(type)
        geometry.firstMaterial?.lightingModel = .phong

        let gameObject = GameObject(SCNNode(geometry: geometry))

        gameObject.name = type.name

        return gameObject
    }
}

extension SCNGeometry {
    static func createPrimitive(_ type: PrimitiveType) -> SCNGeometry {
        let geometry: SCNGeometry

        switch type {
        case .sphere(let rad, _):
            geometry = SCNSphere(radius: rad.toCGFloat())

        case .capsule(let rad, let y, _):
            geometry = SCNCapsule(capRadius: rad.toCGFloat(), height: y.toCGFloat())

        case .cylinder(let rad, let y, _):
            geometry = SCNCylinder(radius: rad.toCGFloat(), height: y.toCGFloat())

        case .cube(let x, let y, let z, let rad, _):
            geometry = SCNBox(
                width: x.toCGFloat(),
                height: y.toCGFloat(),
                length: z.toCGFloat(),
                chamferRadius: rad.toCGFloat()
            )

        case .plane(let x, let y, _):
            geometry = SCNPlane(width: x.toCGFloat(), height: y.toCGFloat())

        case .floor(let x, let z, _):
            let floor = SCNFloor()
            floor.width = x.toCGFloat()
            floor.length = z.toCGFloat()
            geometry = floor
        }

        return geometry
    }

    static func vertices(source: SCNGeometrySource) -> [Vector3] {
        guard let value = source.data.withUnsafeBytes({
            $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
        }) else { return [] }

        let rawPointer = UnsafeRawPointer(value)
        let strides = stride(
            from: source.dataOffset,
            to: source.dataOffset + source.dataStride * source.vectorCount,
            by: source.dataStride
        )

        return strides.map { byteOffset -> Vector3 in
            Vector3(rawPointer.load(fromByteOffset: byteOffset, as: SIMD3<Float>.self))
        }
    }
}
