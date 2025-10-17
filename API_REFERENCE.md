# UnityKit API Reference

**Version:** 1.1.1
**Platform:** iOS 15.0+
**Language:** Swift 5.9+

---

## Table of Contents

1. [Core Architecture](#core-architecture)
2. [Component System](#component-system)
3. [Transform & Hierarchy](#transform--hierarchy)
4. [Physics System](#physics-system)
5. [Graphics & Rendering](#graphics--rendering)
6. [Input System](#input-system)
7. [Time Management](#time-management)
8. [Math & Vectors](#math--vectors)
9. [Audio System](#audio-system)
10. [Debug & Logging](#debug--logging)

---

## Core Architecture

### GameObject

The fundamental class representing interactive objects in a UnityKit scene.

#### Key Methods

```swift
// Creating GameObjects
init()
init(name: String)
init(_ node: SCNNode)
init?(fileName: String, nodeName: String?, bundle: Bundle = .main)
init?(modelPath: String, nodeName: String?, bundle: Bundle = .main)

// Component Management
func addComponent<T: Component>(_ type: T.Type) -> T
func getComponent<T: Component>(_ type: T.Type) -> T?
func getComponents<T: Component>(_ type: T.Type) -> [T]
func getComponentInChild<T: Component>(_ type: T.Type) -> T?
func getComponentsInChild<T: Component>(_ type: T.Type) -> [T]
func removeComponent(_ component: Component)
func removeComponentsOfType(_ type: Component.Type)

// Hierarchy Management
func addChild(_ child: GameObject)
func removeChild(_ child: GameObject)
func getChildren() -> [GameObject]
func getChild(_ index: Int) -> GameObject?
func removeFromParent()
func addToScene(_ scene: Scene)

// State Management
func setActive(_ active: Bool)
func instantiate() -> GameObject
func destroy()

// Searching
static func find(_ type: SearchType, in scene: Scene?) -> GameObject?
static func findGameObjects(_ type: SearchType, in scene: Scene?) -> [GameObject]
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `name` | `String?` | GameObject identifier |
| `tag` | `Tag` | Tag for categorization |
| `layer` | `Layer` | Layer for organization and filtering |
| `transform` | `Transform` | Position, rotation, and scale |
| `renderer` | `Renderer?` | Rendering component if present |
| `node` | `SCNNode` | Underlying SceneKit node |
| `activeSelf` | `Bool` | Local active state |
| `activeInHierarchy` | `Bool` | Computed hierarchy-aware active state |
| `enabled` | `Bool` | Alias for activeSelf |
| `parent` | `GameObject?` | Parent in hierarchy |
| `scene` | `Scene?` | Scene membership |
| `boundingBox` | `BoundingBox` | Axis-aligned bounding box |
| `boundingSphere` | `BoundingSphere` | Bounding sphere |
| `ignoreUpdates` | `Bool` | Skip update cascade for performance |

#### Search Types

```swift
enum SearchType {
    case name(Name)      // .exact, .contains, .startWith, .any
    case tag(Tag)
    case layer(Layer)
    case nameAndTag(Name, Tag)
    case camera(Name)
    case light(Name)
}

enum Tag {
    case untagged
    case mainCamera
    case custom(String)
}

struct Layer: OptionSet {
    static let `default`
    static let ground
    static let player
    static let environment
    static let projectile
    static let all
}
```

### Scene

Manages a collection of GameObjects and their lifecycle.

```swift
class Scene {
    init(_ scene: SCNScene?, allocation: Allocation, shadowCastingAllowed: Bool)

    func addGameObject(_ gameObject: GameObject)
    func clearScene()
    func find(_ type: GameObject.SearchType) -> GameObject?
    func findGameObjects(_ type: GameObject.SearchType) -> [GameObject]

    var scnScene: SCNScene
    var rootGameObject: GameObject
    static var shared: Scene?
}
```

---

## Component System

### Component

Base class for all components that can be attached to GameObjects.

```swift
open class Component: Object, Hashable {
    var gameObject: GameObject?
    var transform: Transform?
    var ignoreUpdates: Bool { get }

    // Lifecycle
    func awake()
    func start()
    func preUpdate()
    func update()
    func fixedUpdate()
    func onDestroy()

    // Management
    func remove()
    func destroy()
    func getComponent<T: Component>(_ type: T.Type) -> T?
    func getComponents<T: Component>(_ type: T.Type) -> [T]
    func addComponent<T: Component>(_ type: T.Type) -> T
}
```

### MonoBehaviour

Base class for creating custom game behaviors and scripts.

```swift
open class MonoBehaviour: Behaviour, Instantiable {
    // Lifecycle Events
    open func onEnable()
    open func onDisable()

    // Physics Callbacks
    open func onCollisionEnter(_ collision: Collision)
    open func onCollisionExit(_ collision: Collision)
    open func onTriggerEnter(_ collider: Collider)
    open func onTriggerExit(_ collider: Collider)

    // Coroutines
    func startCoroutine(_ coroutine: CoroutineClosure, thread: CoroutineThread = .background)
    func queueCoroutine(_ coroutine: Coroutine, thread: CoroutineThread = .main)
}

// Coroutine Types
typealias CoroutineClosure = () -> Void
typealias CoroutineCondition = (TimeInterval) -> Bool
typealias Coroutine = (execute: CoroutineClosure, exitCondition: CoroutineCondition?)

enum CoroutineThread {
    case main
    case background
}
```

#### Example Custom Behavior

```swift
class PlayerController: MonoBehaviour {
    var speed: Float = 5.0

    override func update() {
        if Input.getKey(.w) {
            transform?.position.z += speed * Float(Time.deltaTime)
        }
    }

    override func onCollisionEnter(_ collision: Collision) {
        print("Collision detected!")
    }
}
```

---

## Transform & Hierarchy

### Transform

Controls position, rotation, and scale of GameObjects in 3D space.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `position` | `Vector3` | World space position |
| `localPosition` | `Vector3` | Position relative to parent |
| `orientation` | `Quaternion` | World space rotation (quaternion) |
| `localOrientation` | `Quaternion` | Local rotation (quaternion) |
| `localRotation` | `Vector4` | Local rotation (axis-angle) |
| `localEulerAngles` | `Vector3` | Local Euler angles (degrees) |
| `localScale` | `Vector3` | Scale relative to parent |
| `lossyScale` | `Vector3` | World scale (read-only) |

#### Direction Vectors

```swift
var forward: Vector3   // Positive Z-axis (blue)
var back: Vector3      // Negative Z-axis
var up: Vector3        // Positive Y-axis (green)
var bottom: Vector3    // Negative Y-axis
var right: Vector3     // Positive X-axis (red)
var left: Vector3      // Negative X-axis
```

#### Methods

```swift
func lookAt(_ target: Transform)
func lookAt(_ target: Transform, up: SCNVector3, localFront: SCNVector3)
```

#### Hierarchy Properties

```swift
var parent: Transform?
var children: [Transform]?
var childCount: Int
```

#### Example

```swift
// Position
transform.position = Vector3(0, 5, 0)

// Rotation
transform.localEulerAngles = Vector3(0, 45, 0)

// Scale
transform.localScale = Vector3(2, 2, 2)

// Look at target
transform.lookAt(target.transform)
```

---

## Physics System

### Physics (Static)

Provides raycasting and spatial queries.

```swift
enum Physics {
    // Raycasting
    static func Raycast(
        origin: Vector3,
        direction: Vector3,
        maxDistance: Float = .infinity,
        layerMask: GameObject.Layer = .all,
        in scene: Scene?
    ) -> RaycastHit?

    static func RaycastAll(
        origin: Vector3,
        direction: Vector3,
        maxDistance: Float = .infinity,
        layerMask: GameObject.Layer = .all,
        in scene: Scene?
    ) -> [RaycastHit]

    // Spatial Queries
    static func overlapSphere(
        center: Vector3,
        radius: Float,
        layerMask: GameObject.Layer = .all,
        in scene: Scene?
    ) -> [GameObject]
}

struct RaycastHit {
    var collider: Collider?
    var gameObject: GameObject?
    var point: Vector3
    var distance: Float
    var normal: Vector3
}
```

#### Raycast Example

```swift
// Shoot ray forward from player
let origin = player.transform.position
let direction = player.transform.forward

if let hit = Physics.Raycast(
    origin: origin,
    direction: direction,
    maxDistance: 100,
    layerMask: .environment,
    in: scene
) {
    print("Hit \(hit.gameObject?.name ?? "unknown") at distance \(hit.distance)")
}
```

### Rigidbody

Component for physics simulation.

#### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `mass` | `Float` | `1.0` | Mass in kilograms |
| `useGravity` | `Bool` | `true` | Apply gravity |
| `isKinematic` | `Bool` | `false` | Kinematic mode (no physics) |
| `isStatic` | `Bool` | `false` | Static (immovable) |
| `velocity` | `Vector3` | `.zero` | Linear velocity |
| `angularVelocity` | `Vector3` | `.zero` | Angular velocity |
| `friction` | `CGFloat` | `0.5` | Surface friction |
| `restitution` | `CGFloat` | `0.5` | Bounciness (0-1) |
| `damping` | `CGFloat` | `0.1` | Linear damping |
| `angularDamping` | `CGFloat` | `0.1` | Angular damping |
| `constraints` | `RigidbodyConstraints` | `[]` | Movement/rotation constraints |

#### Methods

```swift
func addForce(_ force: Vector3)
func addTorque(_ torque: Vector4, asImpulse: Bool)
func addExplosionForce(
    explosionForce: Float,
    explosionPosition: Vector3,
    explosionRadius: Float,
    replacePosition: Bool = false
)
func movePosition(_ position: Vector3)
func moveRotation(_ rotation: Quaternion)
func clearAllForces()
```

#### Constraints

```swift
struct RigidbodyConstraints: OptionSet {
    static let freezePositionX
    static let freezePositionY
    static let freezePositionZ
    static let freezeRotationX
    static let freezeRotationY
    static let freezeRotationZ
    static let freezePosition
    static let freezeRotation
    static let freezeAll
}
```

#### Example

```swift
// Create a dynamic physics object
let rb = gameObject.addComponent(Rigidbody.self)
rb.mass = 2.0
rb.useGravity = true

// Apply force (jump)
rb.addForce(Vector3(0, 10, 0))

// Create kinematic character controller
let controller = player.addComponent(Rigidbody.self)
controller.isKinematic = true
controller.constraints = .freezeRotation
```

### Collider

Base class for collision detection.

#### Common Properties

```swift
var isTrigger: Bool
var collideWithLayer: GameObject.Layer?
var contactWithLayer: GameObject.Layer?
```

#### Collider Types

- **BoxCollider** - Box-shaped collision
- **SphereCollider** - Sphere-shaped collision
- **CapsuleCollider** - Capsule-shaped collision
- **MeshCollider** - Mesh-based collision
- **PlaneCollider** - Infinite plane collision

#### Example

```swift
// Physical collider
let collider = gameObject.addComponent(BoxCollider.self)
collider.isTrigger = false
collider.collideWithLayer = [.player, .environment]

// Trigger zone
let trigger = zone.addComponent(SphereCollider.self)
trigger.isTrigger = true
trigger.contactWithLayer = .player
```

---

## Graphics & Rendering

### Camera

Controls scene viewing and rendering.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `scnCamera` | `SCNCamera` | Underlying SceneKit camera |
| `fieldOfView` | `CGFloat` | Field of view in degrees |
| `zNear` | `Double` | Near clipping plane |
| `zFar` | `Double` | Far clipping plane |
| `orthographic` | `Bool` | Use orthographic projection |
| `orthographicSize` | `Double` | Orthographic scale |
| `allowHDR` | `Bool` | Enable HDR rendering |
| `cullingMask` | `GameObject.Layer` | Layers to render |

#### Methods

```swift
func configure(_ closure: (Camera) -> Void)
static func main(in scene: Scene?) -> Camera?
func followTarget(target: SCNNode?, distanceRange: ClosedRange<Float>)
func lookAt(_ target: GameObject, duration: TimeInterval = 0)
func ScreenToWorldPoint(_ point: Vector3, renderer: SCNSceneRenderer) -> Vector3
func WorldToScreenPoint(_ point: Vector3, renderer: SCNSceneRenderer) -> Vector3
func ScreenPointToRay(_ point: Vector2, renderer: SCNSceneRenderer) -> (origin: Vector3, direction: Vector3)
```

#### Example

```swift
let camera = GameObject(name: "MainCamera")
let cam = camera.addComponent(Camera.self)
cam.fieldOfView = 60
cam.allowHDR = true
cam.cullingMask = [.default, .player, .environment]
```

### Light

Provides scene illumination.

#### Light Types

```swift
enum LightType {
    case ambient      // Non-directional, affects all objects
    case omni         // Point light (radiates in all directions)
    case directional  // Sun-like (parallel rays)
    case spot         // Cone-shaped beam
    case IES          // Industry standard profiles
    case probe        // Environment probe
    case area         // Area light
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | `SCNLight.LightType` | Light type |
| `color` | `Any` | Light color (UIColor/NSColor/CGColor) |
| `intensity` | `CGFloat` | Brightness (lumens for PBR) |
| `temperature` | `CGFloat` | Color temperature (1700-9000K) |
| `castsShadow` | `Bool` | Enable shadow casting |
| `shadowColor` | `Any` | Shadow tint |
| `shadowRadius` | `CGFloat` | Shadow softness |
| `shadowMapSize` | `CGSize` | Shadow texture resolution |
| `shadowSampleCount` | `Int` | Shadow quality (samples) |

#### Example

```swift
// Directional sunlight
let sun = GameObject(name: "Sun")
let light = sun.addComponent(Light.self)
light.type = .directional
light.intensity = 1000
light.temperature = 5500
light.castsShadow = true
light.shadowMapSize = CGSize(width: 2048, height: 2048)
```

### Renderer

Controls how GameObjects are rendered.

```swift
class Renderer: Component {
    var materials: [Material]
    var material: Material?
    var shadowCasting: Bool
    var sortingOrder: Int
}
```

---

## Input System

### Input (Static Enum)

Manages keyboard, mouse, and touch input.

#### Keyboard Input

```swift
static func getKey(_ keyCode: KeyCode) -> Bool          // Held down
static func getKeyDown(_ keyCode: KeyCode) -> Bool      // Just pressed
static func getKeyUp(_ keyCode: KeyCode) -> Bool        // Just released
static var anyKey: Bool                                  // Any key held
static var anyKeyDown: Bool                              // Any key pressed
```

#### Mouse Input

```swift
static func getMouseButton(_ button: Int) -> Bool       // Held down
static func getMouseButtonDown(_ button: Int) -> Bool   // Just pressed
static func getMouseButtonUp(_ button: Int) -> Bool     // Just released
static var mousePosition: Vector2                        // Cursor position
```

#### Touch Input

```swift
static var touchCount: Int                               // Active touches
static func getTouch(_ index: Int) -> Touch?            // Get touch by index

class Touch {
    var position: Vector2
    var deltaPosition: Vector2
    var phase: UITouch.Phase
    var tapCount: Int
    var fingerId: Int
}
```

#### Example

```swift
// Keyboard input
if Input.getKey(.w) {
    player.transform.position.z += speed * Float(Time.deltaTime)
}

if Input.getKeyDown(.space) {
    player.jump()
}

// Mouse input
if Input.getMouseButtonDown(0) {
    let ray = camera.ScreenPointToRay(Input.mousePosition, renderer: view)
    // Handle click
}

// Touch input
for i in 0..<Input.touchCount {
    if let touch = Input.getTouch(i) {
        print("Touch at: \(touch.position)")
    }
}
```

---

## Time Management

### Time (Static)

Provides time information for frame-rate independent updates.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `deltaTime` | `TimeInterval` | Time since last frame (scaled) |
| `time` | `TimeInterval` | Total elapsed time (scaled) |
| `unscaledDeltaTime` | `TimeInterval` | Real time since last frame |
| `timeScale` | `Double` | Global time scale multiplier (default: 1.0) |
| `frameCount` | `Int` | Total frames rendered |

#### Example

```swift
// Frame-rate independent movement
override func update() {
    let movement = speed * Float(Time.deltaTime)
    transform?.position.x += movement
}

// Pause game
Time.timeScale = 0.0

// Slow motion
Time.timeScale = 0.5

// Fast forward
Time.timeScale = 2.0

// Resume normal speed
Time.timeScale = 1.0
```

---

## Math & Vectors

### Vector3

3D vector with extensive math operations.

#### Static Constants

```swift
static let zero = Vector3(0, 0, 0)
static let one = Vector3(1, 1, 1)
static let forward = Vector3(0, 0, 1)   // +Z
static let back = Vector3(0, 0, -1)     // -Z
static let up = Vector3(0, 1, 0)        // +Y
static let down = Vector3(0, -1, 0)     // -Y
static let right = Vector3(1, 0, 0)     // +X
static let left = Vector3(-1, 0, 0)     // -X
```

#### Methods

```swift
func normalized() -> Vector3
func magnitude() -> Float
func distance(to: Vector3) -> Float
func dot(_ other: Vector3) -> Float
func cross(_ other: Vector3) -> Vector3
func lerp(to: Vector3, t: Float) -> Vector3
func negated() -> Vector3

// Static utilities
static func Lerp(_ a: Vector3, _ b: Vector3, _ t: Float) -> Vector3
static func Angle(_ from: Vector3, _ to: Vector3) -> Float
static func MoveTowards(_ current: Vector3, _ target: Vector3, _ maxDistance: Float) -> Vector3
static func Min(_ a: Vector3, _ b: Vector3) -> Vector3
static func Max(_ a: Vector3, _ b: Vector3) -> Vector3
static func ClampMagnitude(_ vector: Vector3, _ maxLength: Float) -> Vector3
```

#### Operators

```swift
let a = Vector3(1, 2, 3)
let b = Vector3(4, 5, 6)

let sum = a + b                // Vector addition
let diff = a - b               // Vector subtraction
let scaled = a * 2             // Scalar multiplication
let divided = a / 2            // Scalar division
let dot = a.dot(b)            // Dot product
let cross = a.cross(b)        // Cross product
```

### Vector2

2D vector for screen coordinates and UI.

```swift
struct Vector2 {
    var x: Float
    var y: Float

    static let zero = Vector2(0, 0)
    static let one = Vector2(1, 1)

    func length() -> Float
    func distance(to: Vector2) -> Float
    func toCGPoint() -> CGPoint
}
```

### Quaternion

Rotation representation.

```swift
typealias Quaternion = SCNVector4

extension Quaternion {
    static func euler(_ x: Float, _ y: Float, _ z: Float) -> Quaternion
    func normalized() -> Quaternion
    func toEuler() -> Vector3

    static func Slerp(_ a: Quaternion, _ b: Quaternion, _ t: Float) -> Quaternion
    static func LookRotation(_ forward: Vector3, _ up: Vector3 = Vector3.up) -> Quaternion
    static func difference(from: Vector3, to: Vector3) -> Quaternion
}
```

---

## Audio System

### AudioClip

Audio file resource.

```swift
class AudioClip {
    enum PlayType {
        case playOnce
        case loop
    }

    init?(fileName: String, playType: PlayType, bundle: Bundle = .main)

    var playType: PlayType
    var filename: String
}
```

### AudioSource

3D audio playback component.

```swift
class AudioSource: Component {
    var clip: AudioClip?
    var volume: Float                  // 0.0 to 1.0
    var pitch: Float                   // Playback speed multiplier
    var spatialBlend: Float            // 0 = 2D, 1 = 3D
    var minDistance: Float             // Full volume distance
    var maxDistance: Float             // Silent distance
    var isPlaying: Bool { get }

    func play()
    func pause()
    func stop()
    func configure(_ closure: (AudioSource) -> Void)
}
```

#### Example

```swift
// Load audio clip
let clip = AudioClip(fileName: "explosion.wav", playType: .playOnce)

// Add audio source
let audio = gameObject.addComponent(AudioSource.self)
audio.clip = clip
audio.volume = 0.8
audio.spatialBlend = 1.0  // Full 3D audio
audio.play()
```

---

## Debug & Logging

### Debug (Static Enum)

Logging system with configurable output levels.

#### Log Levels

```swift
struct LogStyle: OptionSet {
    static let debug
    static let info
    static let warning
    static let error
    static let all
    static let none
}
```

#### Methods

```swift
static func set(enable: LogStyle)
static func debug(_ message: String, displayTime: Bool = false)
static func info(_ message: String, displayTime: Bool = false)
static func warning(_ message: String, displayTime: Bool = false)
static func error(_ message: String, displayTime: Bool = false)
static func log(_ message: String, style: LogStyle, displayTime: Bool = false)
```

#### Example

```swift
// Configure logging
Debug.set(enable: [.warning, .error])

// Log messages
Debug.debug("Player position: \(player.transform.position)")
Debug.info("Game started", displayTime: true)
Debug.warning("Low health!")
Debug.error("Failed to load asset")
```

---

## Best Practices

### Performance Optimization

1. **Use `ignoreUpdates`** for static GameObjects:
   ```swift
   staticObject.ignoreUpdates = true
   ```

2. **Prefer `fixedUpdate()` for physics**:
   ```swift
   override func fixedUpdate() {
       rigidbody.addForce(force)
   }
   ```

3. **Cache component references** in `awake()`:
   ```swift
   var rigidbody: Rigidbody!

   override func awake() {
       rigidbody = getComponent(Rigidbody.self)
   }
   ```

4. **Use layer masks** for selective raycasting:
   ```swift
   Physics.Raycast(origin, direction, layerMask: [.player, .environment])
   ```

### Thread Safety

UnityKit is thread-safe for concurrent access:
- GameObject hierarchy operations are protected with concurrent queues
- Component access is synchronized
- Physics queries can be called from any thread

### Lifecycle Order

```
1. GameObject created
2. awake() called on GameObject and all components
3. start() called before first update
4. preUpdate() → update() → fixedUpdate() every frame
5. onDestroy() called when destroyed
```

---

## Quick Reference

### Common Patterns

#### Create and Configure GameObject

```swift
let player = GameObject(name: "Player")
player.addToScene(scene)
player.layer = .player
player.tag = .custom("Player")

let rb = player.addComponent(Rigidbody.self)
rb.mass = 2.0

let collider = player.addComponent(BoxCollider.self)
```

#### Find GameObjects

```swift
// By tag
let camera = GameObject.find(.tag(.mainCamera), in: scene)

// By name
let player = GameObject.find(.name(.exact("Player")), in: scene)

// By layer
let enemies = GameObject.findGameObjects(.layer(.custom("Enemy")), in: scene)
```

#### Input-Driven Movement

```swift
class PlayerController: MonoBehaviour {
    var speed: Float = 5.0

    override func update() {
        var movement = Vector3.zero

        if Input.getKey(.w) { movement.z += 1 }
        if Input.getKey(.s) { movement.z -= 1 }
        if Input.getKey(.a) { movement.x -= 1 }
        if Input.getKey(.d) { movement.x += 1 }

        movement = movement.normalized()
        transform?.position += movement * speed * Float(Time.deltaTime)
    }
}
```

#### Raycasting for Shooting

```swift
if Input.getMouseButtonDown(0) {
    let origin = camera.transform.position
    let direction = camera.transform.forward

    if let hit = Physics.Raycast(origin: origin, direction: direction, maxDistance: 100) {
        hit.gameObject?.destroy()
    }
}
```

---

## Additional Resources

- **README.md** - Getting started guide and examples
- **TESTING_GUIDE.md** - Testing patterns and coverage
- **Source Documentation** - Complete inline API documentation with DocC markup

For more information, see the inline documentation in Xcode (⌥ + Click on any symbol).

---

*Generated for UnityKit 1.1.1*
