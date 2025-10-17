import Foundation
import SceneKit

/// A material that defines the appearance of a 3D object's surface.
///
/// The `Material` class provides a Unity-like interface for configuring how objects appear
/// when rendered. Materials control surface properties such as color, texture, shininess,
/// and how light interacts with the surface.
///
/// ## Overview
///
/// Materials are essential for creating realistic or stylized visuals in 3D scenes. They determine
/// how light reflects off surfaces, what colors and textures appear, and how objects respond to
/// different lighting conditions. UnityKit's `Material` class wraps SceneKit's `SCNMaterial` and
/// provides convenient methods for common material operations.
///
/// ## Topics
///
/// ### Creating Materials
///
/// - ``init()``
/// - ``init(_:lightingModel:)``
/// - ``init(_:)-1ph8y``
/// - ``init(_:)-2xs3c``
///
/// ### Color Properties
///
/// - ``color``
/// - ``BasicColorShading``
/// - ``getColor(_:)``
/// - ``setColor(_:color:)``
///
/// ### Texture Properties
///
/// - ``mainTexture``
/// - ``BasicTextureShading``
/// - ``getTexture(_:)``
/// - ``setTexture(_:image:)``
///
/// ### Material Properties
///
/// - ``doubleSidedGI``
/// - ``scnMaterial``
///
/// ## Example Usage
///
/// ```swift
/// // Create a simple colored material
/// let redMaterial = Material(Color.red)
///
/// // Create a material with custom lighting
/// let metallicMaterial = Material(.physicallyBased)
/// metallicMaterial.color = Color.gray
///
/// // Apply texture to a material
/// let texturedMaterial = Material()
/// texturedMaterial.mainTexture = UIImage(named: "woodTexture")
///
/// // Configure emission for glowing effect
/// let glowingMaterial = Material()
/// glowingMaterial.color = Color.blue
/// glowingMaterial.setColor(.emission, color: Color.cyan)
///
/// // Apply to a GameObject
/// gameObject.material = redMaterial
/// ```
public final class Material: Object {
    /// Color shading types for basic material properties.
    ///
    /// This enumeration defines the different color channels that can be configured
    /// on a material. Each case corresponds to a specific Unity material property name.
    ///
    /// ## Topics
    ///
    /// ### Color Types
    ///
    /// - ``diffuse``
    /// - ``specular``
    /// - ``emission``
    /// - ``reflective``
    /// - ``unknown``
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    /// material.setColor(.diffuse, color: Color.red)
    /// material.setColor(.emission, color: Color.yellow)
    /// material.setColor(.specular, color: Color.white)
    /// ```
    public enum BasicColorShading: String {
        /// The main diffuse color that defines the base appearance of the surface.
        ///
        /// This is the primary color you see when light hits the object. It represents
        /// the color of light that is scattered in all directions.
        case diffuse = "_Color"

        /// The specular highlight color that defines shiny reflections.
        ///
        /// This color appears in bright highlights where light reflects directly toward
        /// the camera. Higher specular values create shinier, more reflective surfaces.
        case specular = "_SpecColor"

        /// The emission color for self-illuminating surfaces.
        ///
        /// Objects with emission color appear to glow, emitting light regardless of
        /// the scene's lighting conditions. Useful for creating light sources, screens,
        /// or magical effects.
        case emission = "_EmissionColor"

        /// The reflective color that tints environmental reflections.
        ///
        /// This color modulates how environmental reflections appear on the surface,
        /// useful for creating metallic or mirror-like materials.
        case reflective = "_ReflectColor"

        /// An unknown or unspecified color type.
        case unknown = ""
    }

    /// Texture shading types for material texture maps.
    ///
    /// This enumeration defines the different texture channels that can be applied
    /// to a material. Each texture type affects a different aspect of the surface appearance.
    ///
    /// ## Topics
    ///
    /// ### Texture Types
    ///
    /// - ``diffuse``
    /// - ``normal``
    /// - ``reflective``
    /// - ``unknown``
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    /// material.setTexture(.diffuse, image: UIImage(named: "brick"))
    /// material.setTexture(.normal, image: UIImage(named: "brickNormal"))
    /// ```
    public enum BasicTextureShading: String {
        /// The main texture that defines the surface color pattern.
        ///
        /// This is the primary texture map that provides color detail across the surface.
        /// Also known as the albedo or base color map.
        case diffuse = "_MainText"

        /// The normal map texture for surface detail.
        ///
        /// Normal maps add the illusion of surface detail without additional geometry
        /// by affecting how light interacts with the surface. They encode surface
        /// orientation information in RGB values.
        case normal = "_BumpMap"

        /// The reflective texture for environmental reflections.
        ///
        /// This texture can be a cubemap or image that defines what the surface reflects,
        /// useful for creating metallic or glass-like materials.
        case reflective = "_Cube"

        /// An unknown or unspecified texture type.
        case unknown = ""
    }

    /// The underlying SceneKit material that handles rendering.
    ///
    /// This property provides direct access to the `SCNMaterial` instance for advanced
    /// configuration. While most common operations can be performed through the `Material`
    /// class's methods, this property allows full control over SceneKit's material properties.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    /// material.scnMaterial.shininess = 0.8
    /// material.scnMaterial.transparency = 0.5
    /// material.scnMaterial.blendMode = .alpha
    /// ```
    public let scnMaterial: SCNMaterial

    /// The main color of the material's surface.
    ///
    /// This property provides convenient access to the diffuse color, which is the primary
    /// color visible on the material. Setting this property is equivalent to calling
    /// `setColor(.diffuse, color: newValue)`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    /// material.color = Color.blue
    ///
    /// // Read the current color
    /// if let currentColor = material.color {
    ///     print("Material color: \(currentColor)")
    /// }
    /// ```
    public var color: Color? {
        get {
            return self.getColor(.diffuse)
        }
        set {
            self.setColor(.diffuse, color: newValue)
        }
    }

    /// The main texture image applied to the material's surface.
    ///
    /// This property provides convenient access to the diffuse texture map. The texture
    /// defines color and pattern details across the surface. Setting this property is
    /// equivalent to calling `setTexture(.diffuse, image: newValue)`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    ///
    /// // Apply a texture from an image file
    /// material.mainTexture = UIImage(named: "brickWall")
    ///
    /// // Apply a procedurally generated texture
    /// let size = CGSize(width: 256, height: 256)
    /// UIGraphicsBeginImageContext(size)
    /// // ... draw into context ...
    /// material.mainTexture = UIGraphicsGetImageFromCurrentImageContext()
    /// UIGraphicsEndImageContext()
    /// ```
    public var mainTexture: UIImage? {
        get {
            return self.getTexture(.diffuse)
        }
        set {
            self.setTexture(.diffuse, image: newValue)
        }
    }

    /// Whether the material is rendered on both sides of the geometry.
    ///
    /// When set to `true`, the material appears on both the front and back faces of the
    /// geometry. This is useful for thin objects like paper, leaves, or walls where both
    /// sides should be visible. By default, only the front faces are rendered (when `false`).
    ///
    /// - Note: Enabling double-sided rendering has a performance cost as it doubles the
    ///   number of fragments that need to be rendered.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a double-sided plane for a flag
    /// let flagMaterial = Material()
    /// flagMaterial.mainTexture = UIImage(named: "flag")
    /// flagMaterial.doubleSidedGI = true
    ///
    /// // Single-sided material for solid objects (default)
    /// let boxMaterial = Material()
    /// boxMaterial.doubleSidedGI = false
    /// ```
    public var doubleSidedGI: Bool {
        get {
            return self.scnMaterial.isDoubleSided
        }
        set {
            self.scnMaterial.isDoubleSided = newValue
        }
    }

    /// Creates a new material with default Phong lighting.
    ///
    /// This initializer creates a material with default settings using the Phong lighting model,
    /// which provides smooth shading with diffuse and specular reflections. The material has no
    /// initial color or texture set.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    /// material.color = Color.white
    /// material.mainTexture = UIImage(named: "texture")
    /// ```
    public required init() {
        self.scnMaterial = SCNMaterial()
        self.scnMaterial.lightingModel = .phong

        super.init()
    }

    /// Creates a new material with the specified color and lighting model.
    ///
    /// This is the most common way to create a simple colored material. The lighting model
    /// determines how the material responds to scene lighting.
    ///
    /// - Parameters:
    ///   - color: The diffuse color for the material's surface.
    ///   - lightingModel: The lighting algorithm to use. Defaults to `.phong` for smooth shading.
    ///     Other options include `.physicallyBased` for PBR rendering, `.constant` for unlit
    ///     materials, `.blinn`, and `.lambert`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a red material with Phong lighting
    /// let redMaterial = Material(Color.red)
    ///
    /// // Create a blue material with physically-based rendering
    /// let pbrMaterial = Material(Color.blue, lightingModel: .physicallyBased)
    ///
    /// // Create an unlit green material (not affected by lights)
    /// let unlitMaterial = Material(Color.green, lightingModel: .constant)
    ///
    /// // Create a gold metallic material
    /// let goldMaterial = Material(Color(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
    ///                             lightingModel: .physicallyBased)
    /// goldMaterial.scnMaterial.metalness.contents = 1.0
    /// goldMaterial.scnMaterial.roughness.contents = 0.2
    /// ```
    public required init(_ color: Color, lightingModel: SCNMaterial.LightingModel = .phong) {
        self.scnMaterial = SCNMaterial()
        self.scnMaterial.lightingModel = lightingModel

        super.init()

        self.setColor(.diffuse, color: color)
    }

    /// Creates a material by wrapping an existing SceneKit material.
    ///
    /// This initializer allows you to use a pre-configured `SCNMaterial` with UnityKit's
    /// `Material` interface. Useful when working with materials loaded from scene files
    /// or created through advanced SceneKit APIs.
    ///
    /// - Parameter scnMaterial: An existing `SCNMaterial` instance to wrap.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Wrap an existing SceneKit material
    /// let scnMat = SCNMaterial()
    /// scnMat.diffuse.contents = Color.purple
    /// scnMat.lightingModel = .physicallyBased
    /// let material = Material(scnMat)
    ///
    /// // Access material loaded from a scene
    /// if let sceneNode = SCNScene(named: "model.scn")?.rootNode.childNode(withName: "mesh", recursively: true),
    ///    let loadedMaterial = sceneNode.geometry?.firstMaterial {
    ///     let material = Material(loadedMaterial)
    ///     // Now use with UnityKit's Material interface
    ///     material.setColor(.emission, color: Color.yellow)
    /// }
    /// ```
    public init(_ scnMaterial: SCNMaterial) {
        self.scnMaterial = scnMaterial

        super.init()
    }

    /// Creates a new material with the specified lighting model.
    ///
    /// This initializer creates a material configured with a specific lighting model but no
    /// initial color. Useful when you want to set up the rendering approach before configuring
    /// colors and textures.
    ///
    /// - Parameter lightingModel: The lighting algorithm to use for rendering this material.
    ///
    /// ## Lighting Models
    ///
    /// - `.phong`: Smooth shading with specular highlights (default)
    /// - `.blinn`: Similar to Phong but with different specular calculation
    /// - `.lambert`: Simple diffuse lighting without specular highlights
    /// - `.constant`: Unlit, shows colors without any lighting calculations
    /// - `.physicallyBased`: Modern PBR rendering with metalness and roughness
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a PBR material for realistic rendering
    /// let pbrMaterial = Material(.physicallyBased)
    /// pbrMaterial.color = Color.gray
    /// pbrMaterial.scnMaterial.metalness.contents = 0.8
    /// pbrMaterial.scnMaterial.roughness.contents = 0.3
    ///
    /// // Create an unlit material for UI elements
    /// let uiMaterial = Material(.constant)
    /// uiMaterial.color = Color.white
    /// uiMaterial.mainTexture = UIImage(named: "buttonTexture")
    ///
    /// // Create a Lambert material for simple diffuse shading
    /// let simpleMaterial = Material(.lambert)
    /// simpleMaterial.color = Color.brown
    /// ```
    public init(_ lightingModel: SCNMaterial.LightingModel) {
        self.scnMaterial = SCNMaterial()
        self.scnMaterial.lightingModel = lightingModel

        super.init()
    }

    // MARK: - Color Management

    /// Retrieves the color for a specific shading type.
    ///
    /// Use this method to read color values for different material properties such as diffuse,
    /// specular, emission, and reflective colors. Returns `nil` if no color is set or if the
    /// shading type is unknown.
    ///
    /// - Parameter name: The type of color shading to retrieve.
    /// - Returns: The color for the specified shading type, or `nil` if not set.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material(Color.red)
    /// material.setColor(.specular, color: Color.white)
    /// material.setColor(.emission, color: Color.yellow)
    ///
    /// // Retrieve colors
    /// if let diffuseColor = material.getColor(.diffuse) {
    ///     print("Diffuse color: \(diffuseColor)") // red
    /// }
    ///
    /// if let specularColor = material.getColor(.specular) {
    ///     print("Specular color: \(specularColor)") // white
    /// }
    ///
    /// if let emissionColor = material.getColor(.emission) {
    ///     print("Emission color: \(emissionColor)") // yellow
    /// }
    /// ```
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

    /// Sets the color for a specific shading type.
    ///
    /// Use this method to configure different color properties of the material. Each shading
    /// type controls a different aspect of how the material appears under lighting.
    ///
    /// - Parameters:
    ///   - name: The type of color shading to set.
    ///   - color: The color to apply, or `nil` to clear the color.
    ///
    /// ## Shading Types
    ///
    /// - **diffuse**: The main surface color that appears under normal lighting
    /// - **specular**: The color of shiny highlights (bright spots where light reflects)
    /// - **emission**: Self-illumination color that glows regardless of lighting
    /// - **reflective**: Tint color for environmental reflections
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    ///
    /// // Set the base color to red
    /// material.setColor(.diffuse, color: Color.red)
    ///
    /// // Add white specular highlights for shininess
    /// material.setColor(.specular, color: Color.white)
    ///
    /// // Make it glow with orange emission
    /// material.setColor(.emission, color: Color.orange)
    ///
    /// // Tint reflections with blue
    /// material.setColor(.reflective, color: Color(red: 0.5, green: 0.5, blue: 1.0, alpha: 1.0))
    ///
    /// // Create a neon sign material
    /// let neonSign = Material(.constant)
    /// neonSign.setColor(.diffuse, color: Color.black)
    /// neonSign.setColor(.emission, color: Color(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0))
    ///
    /// // Create a metallic gold material
    /// let gold = Material(.physicallyBased)
    /// gold.setColor(.diffuse, color: Color(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0))
    /// gold.setColor(.specular, color: Color(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0))
    /// ```
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

    // MARK: - Texture Management

    /// Retrieves the texture image for a specific shading type.
    ///
    /// Use this method to read texture images applied to different material channels such as
    /// diffuse (base color), normal (surface detail), and reflective (environment) textures.
    /// Returns `nil` if no texture is set or if the shading type is unknown.
    ///
    /// - Parameter name: The type of texture shading to retrieve.
    /// - Returns: The texture image for the specified shading type, or `nil` if not set.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    /// material.setTexture(.diffuse, image: UIImage(named: "brick"))
    /// material.setTexture(.normal, image: UIImage(named: "brickNormal"))
    ///
    /// // Retrieve textures
    /// if let diffuseTexture = material.getTexture(.diffuse) {
    ///     print("Diffuse texture size: \(diffuseTexture.size)")
    /// }
    ///
    /// if let normalMap = material.getTexture(.normal) {
    ///     print("Normal map applied: \(normalMap)")
    /// }
    ///
    /// // Check if a texture is set
    /// let hasReflectiveTexture = material.getTexture(.reflective) != nil
    /// ```
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

    /// Sets the texture image for a specific shading type.
    ///
    /// Use this method to apply texture images to different material channels. Textures add
    /// visual detail and realism to 3D surfaces. When a texture is removed (`nil` is passed),
    /// the material falls back to using its color value.
    ///
    /// - Parameters:
    ///   - name: The type of texture shading to set.
    ///   - image: The texture image to apply, or `nil` to remove the texture and use color instead.
    ///
    /// ## Texture Types
    ///
    /// - **diffuse**: The main color texture providing surface color and pattern details
    /// - **normal**: A normal map that simulates surface bumps and details without adding geometry
    /// - **reflective**: An environment map or cubemap for realistic reflections
    ///
    /// ## Example
    ///
    /// ```swift
    /// let material = Material()
    ///
    /// // Apply a brick texture
    /// material.setTexture(.diffuse, image: UIImage(named: "brickColor"))
    ///
    /// // Add normal map for surface detail
    /// material.setTexture(.normal, image: UIImage(named: "brickNormal"))
    ///
    /// // Create a textured wood material
    /// let woodMaterial = Material()
    /// woodMaterial.setTexture(.diffuse, image: UIImage(named: "woodGrain"))
    /// woodMaterial.setTexture(.normal, image: UIImage(named: "woodNormal"))
    /// woodMaterial.scnMaterial.roughness.contents = 0.7
    ///
    /// // Create a metallic surface with environment reflections
    /// let metalMaterial = Material(.physicallyBased)
    /// metalMaterial.setTexture(.diffuse, image: UIImage(named: "metalPlate"))
    /// metalMaterial.setTexture(.reflective, image: UIImage(named: "environmentCubemap"))
    /// metalMaterial.scnMaterial.metalness.contents = 1.0
    /// metalMaterial.scnMaterial.roughness.contents = 0.2
    ///
    /// // Remove a texture and use color instead
    /// material.setTexture(.diffuse, image: nil) // Falls back to material.color
    ///
    /// // Load texture from file
    /// if let texturePath = Bundle.main.path(forResource: "stone", ofType: "png"),
    ///    let textureImage = UIImage(contentsOfFile: texturePath) {
    ///     material.setTexture(.diffuse, image: textureImage)
    /// }
    ///
    /// // Apply procedural texture
    /// let proceduralTexture = generateCheckerboardTexture(size: 512)
    /// material.setTexture(.diffuse, image: proceduralTexture)
    /// ```
    ///
    /// - Note: When setting a texture to `nil`, the material reverts to using the corresponding
    ///   color value. For example, clearing the diffuse texture makes the material use its `color` property.
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
