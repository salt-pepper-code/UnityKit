import Foundation
import SceneKit

/// A light component that illuminates the scene.
///
/// The `Light` component provides control over scene lighting through various light types including
/// ambient, directional, omni (point), and spot lights. Each light can be configured with properties
/// such as color, intensity, temperature, and shadow casting capabilities.
///
/// ## Overview
///
/// Lights are essential for creating realistic and visually appealing 3D scenes. UnityKit supports
/// all SceneKit light types and provides comprehensive shadow configuration options. Lights can be
/// physically-based with proper intensity values measured in lumens, or use simplified color-based
/// lighting for stylized rendering.
///
/// ## Topics
///
/// ### Creating a Light
///
/// - ``init()``
/// - ``configure(_:)``
///
/// ### Light Properties
///
/// - ``type``
/// - ``color``
/// - ``intensity``
/// - ``temperature``
///
/// ### Shadow Configuration
///
/// - ``castsShadow``
/// - ``shadowColor``
/// - ``shadowRadius``
/// - ``shadowMapSize``
/// - ``shadowSampleCount``
/// - ``shadowMode``
/// - ``shadowBias``
///
/// ### Advanced Shadow Settings
///
/// - ``automaticallyAdjustsShadowProjection``
/// - ``maximumShadowDistance``
/// - ``forcesBackFaceCasters``
/// - ``sampleDistributedShadowMaps``
/// - ``shadowCascadeCount``
/// - ``shadowCascadeSplittingFactor``
///
/// ### Light Type-Specific Settings
///
/// - ``orthographicScale``
/// - ``zRange``
/// - ``attenuationDistance``
/// - ``attenuationFalloffExponent``
/// - ``spotAngle``
///
/// ### Rendering Configuration
///
/// - ``categoryBitMask``
///
/// ### SceneKit Integration
///
/// - ``scnLight``
///
/// ## Example Usage
///
/// ```swift
/// // Create a directional light (like sunlight)
/// let sunLight = gameObject.addComponent(Light.self)
/// sunLight.type = .directional
/// sunLight.intensity = 1000
/// sunLight.temperature = 6500
/// sunLight.castsShadow = true
///
/// // Create a warm spot light
/// let spotLight = lampObject.addComponent(Light.self)
/// spotLight.type = .spot
/// spotLight.color = NSColor.white
/// spotLight.intensity = 800
/// spotLight.temperature = 3200  // Warm indoor lighting
/// spotLight.spotAngle = (inner: 15, outer: 45)
/// spotLight.attenuationDistance = 0...20
///
/// // Create an ambient light for fill lighting
/// let ambient = gameObject.addComponent(Light.self).configure { light in
///     light.type = .ambient
///     light.intensity = 200
///     light.color = NSColor(white: 0.8, alpha: 1.0)
/// }
/// ```
public final class Light: Component {
    override var order: ComponentOrder {
        .priority
    }

    /// The underlying SceneKit light object used for illumination.
    ///
    /// This property provides direct access to the `SCNLight` instance that handles the actual
    /// lighting calculations and rendering.
    public internal(set) var scnLight = SCNLight()

    /// The type of light.
    ///
    /// Determines how the light behaves and illuminates the scene. Available types include:
    /// - `.ambient`: Uniform lighting from all directions
    /// - `.directional`: Parallel rays like sunlight
    /// - `.omni`: Point light radiating in all directions
    /// - `.spot`: Cone-shaped directional light
    /// - `.IES`: Light using IES profile data
    /// - `.probe`: Image-based lighting probe
    ///
    /// **Default value:** `.omni` on iOS 8+ and macOS 10.10+, otherwise `.ambient`
    public var type: SCNLight.LightType {
        get { return self.scnLight.type }
        set { self.scnLight.type = newValue }
    }

    /// The color of the light.
    ///
    /// Specifies the light's color as either an `NSColor` (macOS) or `UIColor` (iOS), or a `CGColor`.
    /// The final light color is the product of this color and the color derived from the light's
    /// ``temperature`` property.
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** White
    public var color: Any {
        get { return self.scnLight.color }
        set { self.scnLight.color = newValue }
    }

    /// The color temperature of the light in Kelvin.
    ///
    /// This property controls the warmth or coolness of the light, simulating real-world lighting
    /// conditions. The renderer multiplies the ``color`` property by the color derived from this
    /// temperature value.
    ///
    /// Common temperature values:
    /// - 1700K: Match flame
    /// - 2400K: Candle flame
    /// - 3200K: Tungsten lamp (warm indoor)
    /// - 5500K: Daylight
    /// - 6500K: Pure white (neutral)
    /// - 9000K: Overcast sky (cool)
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** 6500 (neutral white)
    public var temperature: CGFloat {
        get { return self.scnLight.temperature }
        set { self.scnLight.temperature = newValue }
    }

    /// The intensity of the light.
    ///
    /// This value modulates the light's brightness. When used with physically-based materials,
    /// this corresponds to the luminous flux of the light, expressed in lumens (lm).
    ///
    /// For physically-based rendering, typical values:
    /// - 100-200 lm: Ambient/fill light
    /// - 400-800 lm: Indoor lamps
    /// - 1000-2000 lm: Bright indoor lighting
    /// - 10000+ lm: Sunlight
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** 1000
    public var intensity: CGFloat {
        get { return self.scnLight.intensity }
        set { self.scnLight.intensity = newValue }
    }

    /// The name of the light.
    ///
    /// This property sets both the component name and the underlying SceneKit light's name.
    override public var name: String? {
        didSet {
            self.scnLight.name = self.name
        }
    }

    /// A Boolean value that determines whether the light casts shadows.
    ///
    /// - Note: Shadows are only supported by spot and directional lights.
    ///
    /// **Default value:** `false`
    public var castsShadow: Bool {
        get { return self.scnLight.castsShadow }
        set { self.scnLight.castsShadow = newValue }
    }

    /// The color of shadows cast by this light.
    ///
    /// Specifies the shadow color as either an `NSColor` (macOS) or `UIColor` (iOS), or a `CGColor`.
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    /// - Note: On iOS 9 or earlier and macOS 10.11 or earlier, this defaults to 50% transparent black.
    ///
    /// **Default value:** Black
    public var shadowColor: Any {
        get { return self.scnLight.shadowColor }
        set { self.scnLight.shadowColor = newValue }
    }

    /// The blur radius for shadow edges.
    ///
    /// Higher values create softer, more diffuse shadows.
    ///
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** 3.0
    public var shadowRadius: CGFloat {
        get { return self.scnLight.shadowRadius }
        set { self.scnLight.shadowRadius = newValue }
    }

    /// The size of the shadow map texture.
    ///
    /// Larger shadow maps produce more precise shadows at the cost of performance.
    /// Set to `{0, 0}` to let SceneKit automatically choose an appropriate size.
    ///
    /// **Default value:** `{0, 0}` (automatic)
    public var shadowMapSize: CGSize {
        get { return self.scnLight.shadowMapSize }
        set { self.scnLight.shadowMapSize = newValue }
    }

    /// The number of samples per fragment used to compute shadows.
    ///
    /// Higher values produce smoother shadows at the cost of performance.
    /// A value of `0` lets SceneKit choose a platform-appropriate default.
    ///
    /// **Default value:** 0 (automatic)
    public var shadowSampleCount: Int {
        get { return self.scnLight.shadowSampleCount }
        set { self.scnLight.shadowSampleCount = newValue }
    }

    /// The shadow rendering mode.
    ///
    /// Determines how shadows are rendered. Available modes include forward and deferred rendering.
    ///
    /// **Default value:** `.forward`
    public var shadowMode: SCNShadowMode {
        get { return self.scnLight.shadowMode }
        set { self.scnLight.shadowMode = newValue }
    }

    /// The shadow depth bias to prevent shadow acne artifacts.
    ///
    /// This value is multiplied by an implementation-specific factor to create a constant depth offset,
    /// helping to reduce self-shadowing artifacts.
    ///
    /// **Default value:** 1.0
    public var shadowBias: CGFloat {
        get { return self.scnLight.shadowBias }
        set { self.scnLight.shadowBias = newValue }
    }

    /// A Boolean value that determines whether shadow projection is automatically adjusted.
    ///
    /// When `true`, SceneKit automatically computes optimal shadow projection parameters.
    /// When `false`, you must manually configure shadow projection settings.
    ///
    /// **Default value:** `true`
    public var automaticallyAdjustsShadowProjection: Bool {
        get { return self.scnLight.automaticallyAdjustsShadowProjection }
        set { self.scnLight.automaticallyAdjustsShadowProjection = newValue }
    }

    /// The maximum distance from the camera at which shadows are rendered.
    ///
    /// Shadows beyond this distance are not computed, improving performance for distant objects.
    ///
    /// **Default value:** 100.0
    public var maximumShadowDistance: CGFloat {
        get { return self.scnLight.maximumShadowDistance }
        set { self.scnLight.maximumShadowDistance = newValue }
    }

    /// A Boolean value that determines whether only back faces are rendered as shadow casters.
    ///
    /// Enabling this can help reduce shadow artifacts in certain scenarios.
    ///
    /// **Default value:** `false`
    public var forcesBackFaceCasters: Bool {
        get { return self.scnLight.forcesBackFaceCasters }
        set { self.scnLight.forcesBackFaceCasters = newValue }
    }

    /// A Boolean value that uses sample distribution from main rendering for shadow frustum fitting.
    ///
    /// When enabled, shadow frustums are better fitted to the visible scene, improving shadow quality.
    ///
    /// **Default value:** `false`
    public var sampleDistributedShadowMaps: Bool {
        get { return self.scnLight.sampleDistributedShadowMaps }
        set { self.scnLight.sampleDistributedShadowMaps = newValue }
    }

    /// The number of shadow map cascades.
    ///
    /// Cascaded shadow maps improve shadow quality at varying distances from the camera.
    /// Valid range is 1-4.
    ///
    /// **Default value:** 1
    public var shadowCascadeCount: Int {
        get { return self.scnLight.shadowCascadeCount }
        set { self.scnLight.shadowCascadeCount = newValue }
    }

    /// The cascade splitting factor between linear and logarithmic distribution.
    ///
    /// A value of `0` uses linear splitting, `1` uses logarithmic splitting.
    /// Values in between interpolate between the two methods.
    ///
    /// **Default value:** 0.15
    public var shadowCascadeSplittingFactor: CGFloat {
        get { return self.scnLight.shadowCascadeSplittingFactor }
        set { self.scnLight.shadowCascadeSplittingFactor = newValue }
    }

    /// The orthographic scale for shadow map rendering from directional lights.
    ///
    /// This controls the size of the area covered by the shadow map for directional lights.
    ///
    /// - Note: This property only applies to directional lights.
    ///
    /// **Default value:** 1.0
    public var orthographicScale: CGFloat {
        get { return self.scnLight.orthographicScale }
        set { self.scnLight.orthographicScale = newValue }
    }

    /// The near and far clipping range for the light's shadow projection.
    ///
    /// This range defines the depth bounds for shadow rendering. Objects outside this range
    /// won't cast shadows.
    public var zRange: ClosedRange<CGFloat> {
        get { return self.scnLight.zNear...self.scnLight.zFar }
        set {
            self.scnLight.zNear = newValue.lowerBound
            self.scnLight.zFar = newValue.upperBound
        }
    }

    /// The distance range over which light attenuation occurs.
    ///
    /// Defines the start and end distances for light falloff. Between these distances,
    /// the light's intensity decreases according to the ``attenuationFalloffExponent``.
    ///
    /// - Note: This property only applies to omni (point) and spot lights.
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** `0...0` (no attenuation)
    public var attenuationDistance: ClosedRange<CGFloat> {
        get { return self.scnLight.attenuationStartDistance...self.scnLight.attenuationEndDistance }
        set {
            self.scnLight.attenuationStartDistance = newValue.lowerBound
            self.scnLight.attenuationEndDistance = newValue.upperBound
        }
    }

    /// The falloff exponent for light attenuation.
    ///
    /// Controls how light intensity decreases with distance:
    /// - `0`: Constant (no falloff)
    /// - `1`: Linear falloff
    /// - `2`: Quadratic falloff (physically accurate)
    ///
    /// - Note: This property only applies to omni (point) and spot lights.
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** 2.0
    public var attenuationFalloffExponent: CGFloat {
        get { return self.scnLight.attenuationFalloffExponent }
        set { self.scnLight.attenuationFalloffExponent = newValue }
    }

    /// The inner and outer cone angles for spot lights.
    ///
    /// - The inner angle defines where the light reaches full strength.
    /// - The outer angle defines where the light begins to fall off.
    /// - Between these angles, the light intensity transitions smoothly.
    ///
    /// - Note: This property only applies to spot lights.
    /// - Note: The value is animatable through SceneKit's animation system.
    ///
    /// **Default value:** `(inner: 0, outer: 45)`
    public var spotAngle: (inner: CGFloat, outer: CGFloat) {
        get { return (self.scnLight.spotInnerAngle, self.scnLight.spotOuterAngle) }
        set {
            self.scnLight.spotInnerAngle = newValue.inner
            self.scnLight.spotOuterAngle = newValue.outer
        }
    }

    /// The category bit mask that determines which nodes are lit by this light.
    ///
    /// Only nodes with a matching category bit mask will be illuminated by this light.
    ///
    /// **Default value:** All bits set (lights all objects)
    public var categoryBitMask: Int {
        get { return self.scnLight.categoryBitMask }
        set { self.scnLight.categoryBitMask = newValue }
    }

    /// The game object this component is attached to.
    ///
    /// A component is always attached to a game object. When set, this property synchronizes
    /// the light with the game object's SceneKit node.
    override public var gameObject: GameObject? {
        didSet {
            guard let node = gameObject?.node,
                  node.light != scnLight
            else { return }

            node.light.map { self.scnLight = $0 }
        }
    }

    /// Configures the light using a closure.
    ///
    /// This method provides a convenient way to configure multiple light properties
    /// in a single call using a configuration closure.
    ///
    /// - Parameter configurationBlock: A closure that receives the light instance for configuration.
    /// - Returns: The light instance for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let light = gameObject.addComponent(Light.self).configure { light in
    ///     light.type = .spot
    ///     light.intensity = 1000
    ///     light.castsShadow = true
    ///     light.spotAngle = (inner: 20, outer: 50)
    /// }
    /// ```
    @discardableResult public func configure(_ configurationBlock: (Light) -> Void) -> Light {
        configurationBlock(self)
        return self
    }

    override public func awake() {
        guard let node = gameObject?.node,
              node.light == nil
        else { return }

        node.light = self.scnLight
    }
}
