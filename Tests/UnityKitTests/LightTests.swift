import Testing
import SceneKit
@testable import UnityKit

@Suite("Light Component")
struct LightTests {

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    // MARK: - Basic Setup

    @Test("Light component can be added to GameObject")
    func lightComponentCanBeAdded() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.gameObject === obj)
        #expect(obj.node.light != nil)
    }

    @Test("Light component creates SCNLight")
    func lightCreatesScnLight() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.scnLight != nil)
        #expect(obj.node.light === light.scnLight)
    }

    // MARK: - Light Type

    @Test("Light type defaults to omni")
    func lightTypeDefaultsToOmni() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.type == .omni)
    }

    @Test("Light type can be set to directional")
    func lightTypeCanBeSetToDirectional() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.type = .directional

        #expect(light.type == .directional)
        #expect(light.scnLight.type == .directional)
    }

    @Test("Light type can be set to spot")
    func lightTypeCanBeSetToSpot() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.type = .spot

        #expect(light.type == .spot)
        #expect(light.scnLight.type == .spot)
    }

    @Test("Light type can be set to ambient")
    func lightTypeCanBeSetToAmbient() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.type = .ambient

        #expect(light.type == .ambient)
        #expect(light.scnLight.type == .ambient)
    }

    // MARK: - Basic Properties

    @Test("Light intensity can be set")
    func lightIntensityCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.intensity = 2000

        #expect(light.intensity == 2000)
        #expect(light.scnLight.intensity == 2000)
    }

    @Test("Light intensity defaults to 1000")
    func lightIntensityDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.intensity == 1000)
    }

    @Test("Light temperature can be set")
    func lightTemperatureCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.temperature = 5000

        #expect(light.temperature == 5000)
        #expect(light.scnLight.temperature == 5000)
    }

    @Test("Light temperature defaults to 6500")
    func lightTemperatureDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.temperature == 6500)
    }

    @Test("Light name can be set")
    func lightNameCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.name = "MainLight"

        #expect(light.name == "MainLight")
        #expect(light.scnLight.name == "MainLight")
    }

    // MARK: - Shadow Properties

    @Test("Light castsShadow defaults to false")
    func castsShadowDefaultsToFalse() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.castsShadow == false)
    }

    @Test("Light castsShadow can be enabled")
    func castsShadowCanBeEnabled() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.castsShadow = true

        #expect(light.castsShadow == true)
        #expect(light.scnLight.castsShadow == true)
    }

    @Test("Light shadowRadius can be set")
    func shadowRadiusCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.shadowRadius = 5.0

        #expect(light.shadowRadius == 5.0)
        #expect(light.scnLight.shadowRadius == 5.0)
    }

    @Test("Light shadowRadius defaults to 3.0")
    func shadowRadiusDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.shadowRadius == 3.0)
    }

    @Test("Light shadowMapSize can be set")
    func shadowMapSizeCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.shadowMapSize = CGSize(width: 1024, height: 1024)

        #expect(light.shadowMapSize == CGSize(width: 1024, height: 1024))
        #expect(light.scnLight.shadowMapSize == CGSize(width: 1024, height: 1024))
    }

    @Test("Light shadowSampleCount can be set")
    func shadowSampleCountCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.shadowSampleCount = 32

        #expect(light.shadowSampleCount == 32)
        #expect(light.scnLight.shadowSampleCount == 32)
    }

    @Test("Light shadowMode can be set")
    func shadowModeCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.shadowMode = .deferred

        #expect(light.shadowMode == .deferred)
        #expect(light.scnLight.shadowMode == .deferred)
    }

    @Test("Light shadowBias can be set")
    func shadowBiasCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.shadowBias = 2.0

        #expect(light.shadowBias == 2.0)
        #expect(light.scnLight.shadowBias == 2.0)
    }

    @Test("Light shadowBias defaults to 1.0")
    func shadowBiasDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.shadowBias == 1.0)
    }

    // MARK: - Advanced Shadow Properties

    @Test("Light automaticallyAdjustsShadowProjection defaults to true")
    func automaticallyAdjustsShadowProjectionDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.automaticallyAdjustsShadowProjection == true)
    }

    @Test("Light automaticallyAdjustsShadowProjection can be disabled")
    func automaticallyAdjustsShadowProjectionCanBeDisabled() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.automaticallyAdjustsShadowProjection = false

        #expect(light.automaticallyAdjustsShadowProjection == false)
        #expect(light.scnLight.automaticallyAdjustsShadowProjection == false)
    }

    @Test("Light maximumShadowDistance can be set")
    func maximumShadowDistanceCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.maximumShadowDistance = 200.0

        #expect(light.maximumShadowDistance == 200.0)
        #expect(light.scnLight.maximumShadowDistance == 200.0)
    }

    @Test("Light maximumShadowDistance defaults to 100.0")
    func maximumShadowDistanceDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.maximumShadowDistance == 100.0)
    }

    @Test("Light forcesBackFaceCasters defaults to false")
    func forcesBackFaceCastersDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.forcesBackFaceCasters == false)
    }

    @Test("Light forcesBackFaceCasters can be enabled")
    func forcesBackFaceCastersCanBeEnabled() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.forcesBackFaceCasters = true

        #expect(light.forcesBackFaceCasters == true)
        #expect(light.scnLight.forcesBackFaceCasters == true)
    }

    @Test("Light sampleDistributedShadowMaps defaults to false")
    func sampleDistributedShadowMapsDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.sampleDistributedShadowMaps == false)
    }

    @Test("Light sampleDistributedShadowMaps can be enabled")
    func sampleDistributedShadowMapsCanBeEnabled() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.sampleDistributedShadowMaps = true

        #expect(light.sampleDistributedShadowMaps == true)
        #expect(light.scnLight.sampleDistributedShadowMaps == true)
    }

    @Test("Light shadowCascadeCount defaults to 1")
    func shadowCascadeCountDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.shadowCascadeCount == 1)
    }

    @Test("Light shadowCascadeCount can be set")
    func shadowCascadeCountCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.shadowCascadeCount = 4

        #expect(light.shadowCascadeCount == 4)
        #expect(light.scnLight.shadowCascadeCount == 4)
    }

    @Test("Light shadowCascadeSplittingFactor defaults to 0.15")
    func shadowCascadeSplittingFactorDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        // Allow for floating point precision
        #expect(abs(light.shadowCascadeSplittingFactor - 0.15) < 0.001)
    }

    @Test("Light shadowCascadeSplittingFactor can be set")
    func shadowCascadeSplittingFactorCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.shadowCascadeSplittingFactor = 0.5

        #expect(light.shadowCascadeSplittingFactor == 0.5)
        #expect(light.scnLight.shadowCascadeSplittingFactor == 0.5)
    }

    // MARK: - Attenuation (Omni/Spot)

    @Test("Light orthographicScale defaults to 1")
    func orthographicScaleDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.orthographicScale == 1.0)
    }

    @Test("Light orthographicScale can be set")
    func orthographicScaleCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.orthographicScale = 2.5

        #expect(light.orthographicScale == 2.5)
        #expect(light.scnLight.orthographicScale == 2.5)
    }

    @Test("Light zRange can be set")
    func zRangeCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.zRange = 1...1000

        #expect(light.zRange.lowerBound == 1)
        #expect(light.zRange.upperBound == 1000)
        #expect(light.scnLight.zNear == 1)
        #expect(light.scnLight.zFar == 1000)
    }

    @Test("Light attenuationDistance defaults to 0...0")
    func attenuationDistanceDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.attenuationDistance.lowerBound == 0)
        #expect(light.attenuationDistance.upperBound == 0)
    }

    @Test("Light attenuationDistance can be set")
    func attenuationDistanceCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.attenuationDistance = 10...100

        #expect(light.attenuationDistance.lowerBound == 10)
        #expect(light.attenuationDistance.upperBound == 100)
        #expect(light.scnLight.attenuationStartDistance == 10)
        #expect(light.scnLight.attenuationEndDistance == 100)
    }

    @Test("Light attenuationFalloffExponent defaults to 2")
    func attenuationFalloffExponentDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.attenuationFalloffExponent == 2.0)
    }

    @Test("Light attenuationFalloffExponent can be set")
    func attenuationFalloffExponentCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.attenuationFalloffExponent = 1.5

        #expect(light.attenuationFalloffExponent == 1.5)
        #expect(light.scnLight.attenuationFalloffExponent == 1.5)
    }

    // MARK: - Spot Light Properties

    @Test("Light spotAngle defaults to inner:0 outer:45")
    func spotAngleDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        #expect(light.spotAngle.inner == 0)
        #expect(light.spotAngle.outer == 45)
    }

    @Test("Light spotAngle can be set")
    func spotAngleCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.spotAngle = (inner: 10, outer: 60)

        #expect(light.spotAngle.inner == 10)
        #expect(light.spotAngle.outer == 60)
        #expect(light.scnLight.spotInnerAngle == 10)
        #expect(light.scnLight.spotOuterAngle == 60)
    }

    // MARK: - Category Bit Mask

    @Test("Light categoryBitMask defaults to all bits set")
    func categoryBitMaskDefaults() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        // Default should be -1 (all bits set)
        #expect(light.categoryBitMask == -1)
    }

    @Test("Light categoryBitMask can be set")
    func categoryBitMaskCanBeSet() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()
        light.categoryBitMask = 0b0001

        #expect(light.categoryBitMask == 0b0001)
        #expect(light.scnLight.categoryBitMask == 0b0001)
    }

    // MARK: - Configure Pattern

    @Test("Light configure pattern works")
    func configurePatternWorks() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        let result = light.configure { light in
            light.type = .directional
            light.intensity = 3000
            light.castsShadow = true
        }

        #expect(result === light)
        #expect(light.type == .directional)
        #expect(light.intensity == 3000)
        #expect(light.castsShadow == true)
    }

    // MARK: - GameObject Integration

    @Test("Light uses existing SCNLight if GameObject already has one")
    func usesExistingScnLight() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "LightObject")
        scene.addGameObject(obj)

        // Pre-create a light on the node
        let existingLight = SCNLight()
        existingLight.intensity = 5000
        obj.node.light = existingLight

        let light = try #require(obj.addComponent(Light.self))
        light.awake()

        // Should use the existing light
        #expect(light.scnLight === existingLight)
        #expect(light.intensity == 5000)
    }
}
