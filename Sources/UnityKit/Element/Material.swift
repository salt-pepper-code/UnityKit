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
            return self.getColor(.diffuse)
        }
        set {
            self.setColor(.diffuse, color: newValue)
        }
    }

    public var mainTexture: UIImage? {
        get {
            return self.getTexture(.diffuse)
        }
        set {
            self.setTexture(.diffuse, image: newValue)
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

    /// Create a new instance
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
            return self.scnMaterial.diffuse.contents as? Color
        case .specular:
            return self.scnMaterial.specular.contents as? Color
        case .emission:
            return self.scnMaterial.emission.contents as? Color
        case .reflective:
            return self.scnMaterial.reflective.contents as? Color
        default:
            return nil
        }
    }

    public func setColor(_ name: BasicColorShading, color: Color?) {
        switch name {
        case .diffuse:
            self.scnMaterial.diffuse.contents = color
        case .specular:
            self.scnMaterial.specular.contents = color
        case .emission:
            self.scnMaterial.emission.contents = color
        case .reflective:
            self.scnMaterial.reflective.contents = color
        case .unknown:
            break
        }
    }

    //Texture

    public func getTexture(_ name: BasicTextureShading) -> UIImage? {
        switch name {
        case .diffuse:
            return self.scnMaterial.diffuse.contents as? UIImage
        case .normal:
            return self.scnMaterial.normal.contents as? UIImage
        case .reflective:
            return self.scnMaterial.reflective.contents as? UIImage
        default:
            return nil
        }
    }

    public func setTexture(_ name: BasicTextureShading, image: UIImage?) {
        switch name {
        case .diffuse:
            self.scnMaterial.diffuse.contents = image ?? self.color
        case .normal:
            self.scnMaterial.normal.contents = image ?? self.color
        case .reflective:
            self.scnMaterial.reflective.contents = image ?? self.color
        case .unknown:
            break
        }
    }
}
