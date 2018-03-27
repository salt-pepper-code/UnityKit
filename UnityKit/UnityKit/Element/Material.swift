import Foundation
import SceneKit

public final class Material: Object {
    
    public enum BasicColorShading: String {
        
        case diffuse = "_Color"
        case specular = "_SpecColor"
        case emission = "_EmissionColor"
        case reflective = "_ReflectColor"
        case unknown = ""
    }
    
    public enum BasicTextureShading: String {
        
        case diffuse = "_MainText"
        case normal = "_BumpMap"
        case reflective = "_Cube"
        case unknown = ""
    }
    
    public let scnMaterial: SCNMaterial
    
    public var color: Color? {
        
        get {
            return getColor(.diffuse)
        }
        set {
            setColor(.diffuse, color: newValue)
        }
    }
    
    public var mainTexture: UIImage? {
        
        get {
            return getTexture(.diffuse)
        }
        set {
            setTexture(.diffuse, image: newValue)
        }
    }
    
    public var doubleSidedGI: Bool {
        
        get {
            return scnMaterial.isDoubleSided
        }
        set {
            scnMaterial.isDoubleSided = newValue
        }
    }
    
    //
    
    public required init() {
        
        self.scnMaterial = SCNMaterial()
        self.scnMaterial.lightingModel = .phong
        
        super.init()
    }
    
    public required init(_ color: Color, lightingModel: SCNMaterial.LightingModel = .phong) {
        
        self.scnMaterial = SCNMaterial()
        self.scnMaterial.lightingModel = lightingModel
        
        super.init()
        
        self.setColor(.diffuse, color: color)
    }
    
    public init(_ scnMaterial: SCNMaterial) {
        
        self.scnMaterial = scnMaterial
        
        super.init()
    }
    
    public init(_ lightingModel: SCNMaterial.LightingModel) {
        
        self.scnMaterial = SCNMaterial()
        self.scnMaterial.lightingModel = lightingModel
        
        super.init()
    }
    
    //Color

    public func getColor(_ name: BasicColorShading) -> Color? {
        
        switch name {
        case .diffuse:
            return scnMaterial.diffuse.contents as? Color
        case .specular:
            return scnMaterial.specular.contents as? Color
        case .emission:
            return scnMaterial.emission.contents as? Color
        case .reflective:
            return scnMaterial.reflective.contents as? Color
        default:
            return nil
        }
    }
    
    public func setColor(_ name: BasicColorShading, color: Color?) {
        
        switch name {
        case .diffuse:
            scnMaterial.diffuse.contents = color
        case .specular:
            scnMaterial.specular.contents = color
        case .emission:
            scnMaterial.emission.contents = color
        case .reflective:
            scnMaterial.reflective.contents = color
        case .unknown:
            break
        }
    }

    //Texture
    
    public func getTexture(_ name: BasicTextureShading) -> UIImage? {
        
        switch name {
        case .diffuse:
            return scnMaterial.diffuse.contents as? UIImage
        case .normal:
            return scnMaterial.normal.contents as? UIImage
        case .reflective:
            return scnMaterial.reflective.contents as? UIImage
        default:
            return nil
        }
    }

    public func setTexture(_ name: BasicTextureShading, image: UIImage?) {
        
        switch name {
        case .diffuse:
            scnMaterial.diffuse.contents = color
        case .normal:
            scnMaterial.normal.contents = color
        case .reflective:
            scnMaterial.reflective.contents = color
        case .unknown:
            break
        }
    }
}
