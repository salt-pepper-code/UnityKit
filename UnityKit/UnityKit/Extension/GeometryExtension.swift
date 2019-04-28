import SceneKit

public enum PrimitiveType {
    
    case sphere(radius: Float, name: String?)
    case capsule(capRadius: Float, height: Float, name: String?)
    case cylinder(radius: Float, height: Float, name: String?)
    case cube(width: Float, height: Float, length: Float, chamferRadius: Float, name: String?)
    case plane(width: Float, height: Float, name: String?)
    case floor(width: Float, length: Float, name: String?)
}

extension GameObject {
    
    public static func createPrimitive(_ type: PrimitiveType) -> GameObject {
        
        let geometry = SCNGeometry.createPrimitive(type)
        let name: String
        
        switch type {
        case let .sphere(_, n):
            name = n ?? "Sphere"
            
        case let .capsule(_, _, n):
            name = n ?? "Capsule"
            
        case let .cylinder(_, _, n):
            name = n ?? "Cylinder"
            
        case let .cube(_, _, _, _, n):
            name = n ?? "Cube"
            
        case let .plane(_, _, n):
            name = n ?? "Plane"
            
        case let .floor(_, _, n):
            name = n ?? "Floor"
        }
        
        geometry.firstMaterial?.lightingModel = .phong
        
        let gameObject = GameObject(SCNNode(geometry: geometry))
        
        gameObject.name = name
        
        return gameObject
    }
}

extension SCNGeometry {
    
    internal static func createPrimitive(_ type: PrimitiveType) -> SCNGeometry {
        
        let geometry: SCNGeometry
        
        switch type {
        case let .sphere(rad, _):
            geometry = SCNSphere(radius: rad.toCGFloat())
            
        case let .capsule(rad, y, _):
            geometry = SCNCapsule(capRadius: rad.toCGFloat(), height: y.toCGFloat())
            
        case let .cylinder(rad, y, _):
            geometry = SCNCylinder(radius: rad.toCGFloat(), height: y.toCGFloat())
            
        case let .cube(x, y, z, rad, _):
            geometry = SCNBox(width: x.toCGFloat(), height: y.toCGFloat(), length: z.toCGFloat(), chamferRadius: rad.toCGFloat())
            
        case let .plane(x, y, _):
            geometry = SCNPlane(width: x.toCGFloat(), height: y.toCGFloat())
            
        case let .floor(x, z, _):
            let floor = SCNFloor()
            floor.width = x.toCGFloat()
            floor.length = z.toCGFloat()
            geometry = floor
        }
        
        return geometry
    }
    
    internal static func vertices(source: SCNGeometrySource) -> [Vector3] {
        guard let value = source.data.withUnsafeBytes({
            $0.baseAddress?.assumingMemoryBound(to: UInt8.self)
        }) else { return [] }
        
        let rawPointer = UnsafeRawPointer(value)
        let strides = stride(from: source.dataOffset,
                             to: source.dataOffset + source.dataStride * source.vectorCount,
                             by: source.dataStride)
        
        return strides.map { (byteOffset) -> Vector3 in
            Vector3(rawPointer.load(fromByteOffset: byteOffset, as: float3.self))
        }
    }
}
