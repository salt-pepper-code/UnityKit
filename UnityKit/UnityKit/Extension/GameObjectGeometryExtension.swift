import SceneKit

extension GameObject {
    
    public enum PrimitiveType {
        
        case sphere(radius: CGFloat, name: String?)
        case capsule(capRadius: CGFloat, height: CGFloat, name: String?)
        case cylinder(radius: CGFloat, height: CGFloat, name: String?)
        case cube(width: CGFloat, height: CGFloat, length: CGFloat, chamferRadius: CGFloat, name: String?)
        case plane(width: CGFloat, height: CGFloat, name: String?)
    }
    
    public static func createPrimitive(_ type: PrimitiveType) -> GameObject {
        
        let geometry: SCNGeometry
        let name: String

        switch type {
        case .sphere(let rad, let n):
            geometry = SCNSphere(radius: rad)
            name = n ?? "Sphere"
            
        case .capsule(let rad, let y, let n):
            geometry = SCNCapsule(capRadius: rad, height: y)
            name = n ?? "Capsule"
            
        case .cylinder(let rad, let y, let n):
            geometry = SCNCylinder(radius: rad, height: y)
            name = n ?? "Cylinder"
            
        case .cube(let x, let y, let z, let rad, let n):
            geometry = SCNBox(width: x, height: y, length: z, chamferRadius: rad)
            name = n ?? "Cube"
            
        case .plane(let x, let y, let n):
            geometry = SCNPlane(width: x, height: y)
            name = n ?? "Plane"
        }

        geometry.firstMaterial?.lightingModel = .phong
        
        let gameObject = GameObject(SCNNode(geometry: geometry))
        
        gameObject.name = name
        
        return gameObject
    }
}
