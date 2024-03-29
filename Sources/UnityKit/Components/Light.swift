import Foundation
import SceneKit

/**
 Script interface for light components.
 */
public final class Light: Component {
    override internal var order: ComponentOrder {
        .priority
    }
    internal(set) public var scnLight = SCNLight()

    /**
     Specifies the receiver's type.

     **Defaults to SCNLightTypeOmni on iOS 8 and later, and on macOS 10.10 and later (otherwise defaults to SCNLightTypeAmbient).**
     */
    public var type: SCNLight.LightType {
        get { return scnLight.type }
        set { scnLight.type = newValue }
    }

    /**
     Specifies the receiver's color (NSColor or CGColorRef). Animatable. Defaults to white.

     **The initial value is a NSColor. The renderer multiplies the light's color is by the color derived from the light's temperature.**
     */
    public var color: Any {
        get { return scnLight.color }
        set { scnLight.color = newValue }
    }

    /**
     Specifies the receiver's temperature.

     **This specifies the temperature of the light in Kelvin. The renderer multiplies the light's color by the color derived from the light's temperature. Defaults to 6500 (pure white). Animatable.**
     */
    public var temperature: CGFloat {
        get { return scnLight.temperature }
        set { scnLight.temperature = newValue }
    }

    /**
     Specifies the receiver's intensity.

     **This intensity is used to modulate the light color. When used with a physically-based material, this corresponds to the luminous flux of the light, expressed in lumens (lm). Defaults to 1000. Animatable.**
     */
    public var intensity: CGFloat {
        get { return scnLight.intensity }
        set { scnLight.intensity = newValue }
    }

    /**
     Determines the name of the receiver.
     */
    public override var name: String? {
        didSet {
            scnLight.name = name
        }
    }

    /**
     Determines whether the receiver casts a shadow. Defaults to NO.

     **Shadows are only supported by spot and directional lights.**
     */
    public var castsShadow: Bool {
        get { return scnLight.castsShadow }
        set { scnLight.castsShadow = newValue }
    }

    /**
     Specifies the color (CGColorRef or NSColor) of the shadow casted by the receiver. Defaults to black. Animatable.

     **On iOS 9 or earlier and macOS 10.11 or earlier, this defaults to black 50% transparent.**
     */
    public var shadowColor: Any {
        get { return scnLight.shadowColor }
        set { scnLight.shadowColor = newValue }
    }

    /**
     Specifies the sample radius used to render the receiver’s shadow. Default value is 3.0. Animatable.
     */
    public var shadowRadius: CGFloat {
        get { return scnLight.shadowRadius }
        set { scnLight.shadowRadius = newValue }
    }

    /**
     Specifies the size of the shadow map.

     **The larger the shadow map is the more precise the shadows are but the slower the computation is. If set to {0,0} the size of the shadow map is automatically chosen. Defaults to {0,0}.**
     */
    public var shadowMapSize: CGSize {
        get { return scnLight.shadowMapSize }
        set { scnLight.shadowMapSize = newValue }
    }

    /**
     Specifies the number of sample per fragment to compute the shadow map. Defaults to 0.

     **On macOS 10.11 or earlier, the shadowSampleCount defaults to 16. On iOS 9 or earlier it defaults to 1.0.
     On macOS 10.12, iOS 10 and greater, when the shadowSampleCount is set to 0, a default sample count is chosen depending on the platform.**
     */
    public var shadowSampleCount: Int {
        get { return scnLight.shadowSampleCount }
        set { scnLight.shadowSampleCount = newValue }
    }

    /**
     Specified the mode to use to cast shadows. See above for the available modes and their description. Defaults to SCNShadowModeForward.
     */
    public var shadowMode: SCNShadowMode {
        get { return scnLight.shadowMode }
        set { scnLight.shadowMode = newValue }
    }

    /**
     Specifies the correction to apply to the shadow map to correct acne artefacts. It is multiplied by an implementation-specific value to create a constant depth offset. Defaults to 1.0
     */

    public var shadowBias: CGFloat {
        get { return scnLight.shadowBias }
        set { scnLight.shadowBias = newValue }
    }
    /**
     Specifies if the shadow map projection should be done automatically or manually by the user. Defaults to YES.
     */
    public var automaticallyAdjustsShadowProjection: Bool {
        get { return scnLight.automaticallyAdjustsShadowProjection }
        set { scnLight.automaticallyAdjustsShadowProjection = newValue }
    }

    /**
     Specifies the maximum distance from the viewpoint from which the shadows for the receiver light won't be computed. Defaults to 100.0.
     */
    public var maximumShadowDistance: CGFloat {
        get { return scnLight.maximumShadowDistance }
        set { scnLight.maximumShadowDistance = newValue }
    }

    /**
     Render only back faces of the shadow caster when enabled. Defaults to NO.
     This is a behavior change from previous releases.
     */
    public var forcesBackFaceCasters: Bool {
        get { return scnLight.forcesBackFaceCasters }
        set { scnLight.forcesBackFaceCasters = newValue }
    }

    /**
     Use the sample distribution of the main rendering to better fit the shadow frusta. Defaults to NO.
     */
    public var sampleDistributedShadowMaps: Bool {
        get { return scnLight.sampleDistributedShadowMaps }
        set { scnLight.sampleDistributedShadowMaps = newValue }
    }

    /**
     Specifies the number of distinct shadow maps that will be computed for the receiver light. Defaults to 1. Maximum is 4.
     */
    public var shadowCascadeCount: Int {
        get { return scnLight.shadowCascadeCount }
        set { scnLight.shadowCascadeCount = newValue }
    }

    /**
     Specifies a factor to interpolate between linear splitting (0) and logarithmic splitting (1). Defaults to 0.15.
     */
    public var shadowCascadeSplittingFactor: CGFloat {
        get { return scnLight.shadowCascadeSplittingFactor }
        set { scnLight.shadowCascadeSplittingFactor = newValue }
    }

    /**
     Specifies the orthographic scale used to render from the directional light into the shadow map. Defaults to 1.

     **This is only applicable for directional lights.**
     */
    public var orthographicScale: CGFloat {
        get { return scnLight.orthographicScale }
        set { scnLight.orthographicScale = newValue }
    }

    public var zRange: ClosedRange<CGFloat> {
        get { return scnLight.zNear...scnLight.zFar }
        set {
            scnLight.zNear = newValue.lowerBound
            scnLight.zFar = newValue.upperBound
        }
    }

    /**
     The distance at which the attenuation starts and ends (Omni or Spot light types only). Animatable. Defaults to 0.
     */
    public var attenuationDistance: ClosedRange<CGFloat> {
        get { return scnLight.attenuationStartDistance...scnLight.attenuationEndDistance }
        set {
            scnLight.attenuationStartDistance = newValue.lowerBound
            scnLight.attenuationEndDistance = newValue.upperBound
        }
    }

    /**
     Specifies the attenuation between the start and end attenuation distances. 0 means a constant attenuation, 1 a linear attenuation and 2 a quadratic attenuation, but any positive value will work (Omni or Spot light types only). Animatable. Defaults to 2.
     */
    public var attenuationFalloffExponent: CGFloat {
        get { return scnLight.attenuationFalloffExponent }
        set { scnLight.attenuationFalloffExponent = newValue }
    }

    /**
     The angle in degrees between the spot direction and the lit element below/after which the lighting is at full strength. Animatable. Inner defaults to 0. Outer defaults to 45 degrees.
     */
    public var spotAngle: (inner: CGFloat, outer: CGFloat) {
        get { return (scnLight.spotInnerAngle, scnLight.spotOuterAngle) }
        set {
            scnLight.spotInnerAngle = newValue.inner
            scnLight.spotOuterAngle = newValue.outer
        }
    }

    /**
     Determines the node categories that will be lit by the receiver. Defaults to all bit set.
     */
    public var categoryBitMask: Int {
        get { return scnLight.categoryBitMask }
        set { scnLight.categoryBitMask = newValue }
    }

    public override var gameObject: GameObject? {
        didSet {
            guard let node = gameObject?.node,
                  node.light != scnLight
            else { return }

            node.light.map { scnLight = $0 }
        }
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
     - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (Light) -> Void) -> Light {
        configurationBlock(self)
        return self
    }

    public override func awake() {
        guard let node = gameObject?.node,
              node.light == nil
        else { return }

        node.light = scnLight
    }
}
