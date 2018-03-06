import Foundation
import SceneKit

public class Material: Object {
    
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
    
    public var color: UIColor? {
        
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
            return self.scnMaterial.isDoubleSided
        }
        set {
            self.scnMaterial.isDoubleSided = newValue
        }
    }
    
    //
    
    public required init() {
        
        self.scnMaterial = SCNMaterial()
        self.scnMaterial.lightingModel = .phong
        
        super.init()
    }
    
    public required init(_ color: UIColor, lightingModel: SCNMaterial.LightingModel = .phong) {
        
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
    
    public func getColor(_ name: String) -> UIColor? {
        
        switch name {
        case BasicColorShading.diffuse.rawValue:
            return getColor(.diffuse)
        case BasicColorShading.specular.rawValue:
            return getColor(.specular)
        case BasicColorShading.emission.rawValue:
            return getColor(.emission)
        case BasicColorShading.reflective.rawValue:
            return getColor(.reflective)
        default:
            return getColor(.unknown)
        }
    }
    
    public func getColor(_ shading: BasicColorShading) -> UIColor? {
        
        switch shading {
        case .diffuse:
            return self.scnMaterial.diffuse.contents as? UIColor
        case .specular:
            return self.scnMaterial.specular.contents as? UIColor
        case .emission:
            return self.self.scnMaterial.emission.contents as? UIColor
        case .reflective:
            return self.self.scnMaterial.reflective.contents as? UIColor
        default:
            return nil
        }
    }
    
    public func setColor(_ name: String, color: UIColor?) {
        
        switch name {
        case BasicColorShading.diffuse.rawValue:
            setColor(.diffuse, color: color)
        case BasicColorShading.specular.rawValue:
            setColor(.specular, color: color)
        case BasicColorShading.emission.rawValue:
            setColor(.emission, color: color)
        case BasicColorShading.reflective.rawValue:
            setColor(.reflective, color: color)
        default:
            break
        }
    }
    
    public func setColor(_ shading: BasicColorShading, color: UIColor?) {
        
        switch shading {
        case .diffuse:
            self.scnMaterial.diffuse.contents = color
        case .specular:
            self.scnMaterial.specular.contents = color
        case .emission:
            self.self.scnMaterial.emission.contents = color
        case .reflective:
            self.self.scnMaterial.reflective.contents = color
        case .unknown:
            break
        }
    }
    
    //Texture
    
    public func getTexture(_ name: String) -> UIImage? {
        
        switch name {
        case BasicTextureShading.diffuse.rawValue:
            return getTexture(.diffuse)
        case BasicTextureShading.normal.rawValue:
            return getTexture(.normal)
        case BasicTextureShading.reflective.rawValue:
            return getTexture(.reflective)
        default:
            return getTexture(.unknown)
        }
    }
    
    public func getTexture(_ shading: BasicTextureShading) -> UIImage? {
        
        switch shading {
        case .diffuse:
            return self.scnMaterial.diffuse.contents as? UIImage
        case .normal:
            return self.scnMaterial.normal.contents as? UIImage
        case .reflective:
            return self.self.scnMaterial.reflective.contents as? UIImage
        default:
            return nil
        }
    }
    
    public func setTexture(_ name: String, image: UIImage?) {
        
        switch name {
        case BasicTextureShading.diffuse.rawValue:
            setTexture(.diffuse, image: image)
        case BasicTextureShading.normal.rawValue:
            setTexture(.normal, image: image)
        case BasicTextureShading.reflective.rawValue:
            setTexture(.reflective, image: image)
        default:
            break
        }
    }
    
    public func setTexture(_ shading: BasicTextureShading, image: UIImage?) {
        
        switch shading {
        case .diffuse:
            self.scnMaterial.diffuse.contents = color
        case .normal:
            self.scnMaterial.normal.contents = color
        case .reflective:
            self.self.scnMaterial.reflective.contents = color
        case .unknown:
            break
        }
    }
}
