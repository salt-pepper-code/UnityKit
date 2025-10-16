# UnityKit Testing Guide

This document contains essential information for writing tests in UnityKit. Reference this before creating new test files.

## Scene & GameObject Initialization

### Creating a Test Scene

**For Basic Tests (No Lifecycle Functions):**

```swift
// ✅ CORRECT - Scene requires allocation parameter
let scene = Scene(allocation: .instantiate)  // For tests, use .instantiate
let scene = Scene(allocation: .singleton)     // Alternative

// ❌ WRONG - These don't exist
let scene = Scene(name: "TestScene")
let scene = Scene()
```

**For Tests Requiring Lifecycle Functions (awake, start, update, etc.):**

```swift
// ✅ CORRECT - Create scene with UIWindow for lifecycle testing
@MainActor
func createTestSceneWithView() -> (scene: Scene, window: UIWindow) {
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

    let options = UI.Options(
        rendersContinuously: true,
        allocation: .instantiate
    )

    let view = UI.UIKitView.makeView(
        on: window,
        sceneName: nil,
        options: options
    )

    window.makeKeyAndVisible()

    return (view.sceneHolder!, window)
}

// Usage in tests
@Test("My lifecycle test")
@MainActor
func testLifecycle() throws {
    let (scene, window) = createTestSceneWithView()
    // Test code here...

    // Cleanup
    window.isHidden = true
}
```

**Important:** Lifecycle functions (awake, start, update, fixedUpdate, lateUpdate, preUpdate) require a full rendering context with UIWindow. Basic tests that don't test lifecycle behavior can use `Scene(allocation: .instantiate)` directly.

### Creating GameObjects

```swift
// ✅ CORRECT - Create GameObject then add to scene
let gameObject = GameObject(name: "MyObject")
scene.addGameObject(gameObject)

// Alternative - Create and add as child to rootGameObject
let gameObject = GameObject(name: "MyObject")
scene.rootGameObject.addChild(gameObject)

// ❌ WRONG - No 'in:' parameter exists
let gameObject = GameObject(name: "MyObject", in: scene)
```

### Setting GameObject Properties

```swift
let box = GameObject(name: "Box")
box.layer = .default
box.transform.position = Vector3(10, 0, 0)
scene.addGameObject(box)
```

## Available Layers

GameObject.Layer is an OptionSet with these predefined values:

```swift
.default        // Default layer
.ground         // Ground objects
.player         // Player objects
.environment    // Environment objects
.projectile     // Projectiles
.all           // All layers combined
```

**Note:** There is NO `.ui` layer!

**Important:** Layer filtering uses OptionSet containment (`.contains()`), not equality!
- When searching with `.layer(.all)`, it finds objects on any individual layer
- Combined layers work: `.layer([.default, .player])` finds objects on either layer

## Available Tags

GameObject.Tag is an enum with these values:

```swift
.untagged           // Default untagged state
.mainCamera         // Main camera tag
.custom(String)     // Custom tag with any string value
```

**Usage:**
```swift
gameObject.tag = .custom("Player")
gameObject.tag = .custom("Enemy")
gameObject.tag = .mainCamera
```

**Note:** Unlike layers, tags are exact values, not bit masks!

## Adding Components

Components must be awakened after being added in tests:

```swift
let collider = gameObject.addComponent(BoxCollider.self)
collider?.awake()  // Important: Call awake() for tests
```

## Common Testing Patterns

### Helper Functions for Test Setup

Create helper functions to reduce boilerplate:

```swift
@Suite("My Tests")
struct MyTests {
    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    func createBox(name: String, position: Vector3, in scene: Scene) -> GameObject {
        let box = GameObject(name: name)
        box.transform.position = position
        scene.addGameObject(box)
        let collider = box.addComponent(BoxCollider.self)
        collider?.awake()
        return box
    }
}
```

### Testing Framework

UnityKit uses Swift Testing (not XCTest):

```swift
import Testing
@testable import UnityKit

@Suite("Feature Name")
struct FeatureTests {
    @Test("Test description")
    func testSomething() throws {
        // Test code
        #expect(value == expected)

        // ✅ PREFER: Use try #require for nil checks
        let result = try #require(optionalValue)
        #expect(result.property == expected)
    }
}
```

**Unwrapping Optionals in Tests:**

```swift
// ✅ CORRECT - Use try #require()
@Test("Test with optional")
func testOptional() throws {
    let hit = try #require(Physics.Raycast(...))
    #expect(hit.distance > 0)
}

// ❌ AVOID - Manual nil checks and force unwrapping
@Test("Test with optional")
func testOptional() {
    let hit = Physics.Raycast(...)
    #expect(hit != nil)
    #expect(hit!.distance > 0)  // Force unwrap
}

// ❌ AVOID - Guard statements
@Test("Test with optional")
func testOptional() {
    let hit = Physics.Raycast(...)
    guard let hit = hit else { return }
    #expect(hit.distance > 0)
}
```

**Why use `try #require()`?**
- Automatically unwraps optionals
- Fails test immediately with clear message if nil
- No need for force unwrapping (`!`) or guard statements
- More idiomatic Swift Testing code

## Time Testing

Time has special testing utilities:

```swift
Time.resetForTesting()  // Reset time state before tests
Time.simulateFrame(realDelta: 0.016)  // Simulate a frame
```

## Available Collider Types

UnityKit provides three collider types:

```swift
BoxCollider       // Box-shaped collider
SphereCollider    // Sphere-shaped collider (has .set(radius:) and .set(center:))
CapsuleCollider   // Capsule-shaped collider (has .set(radius:), .set(height:), .set(center:))
```

All colliders:
- Must call `.awake()` after being added in tests
- Work with `Physics.Raycast()` and `Physics.overlapSphere()`
- Support the fluent `.configure {}` pattern

## Camera Testing

**Important Limitations:**

Camera testing has several constraints due to SceneKit's rendering requirements:

1. **SceneKit Constraints** - Methods like `followTarget()` and `lookAt()` create SceneKit constraints (`SCNLookAtConstraint`, `SCNDistanceConstraint`) that require a full rendering context. Creating these in tests can cause **heap corruption**.
   - ✅ Safe: Test that methods are callable with `nil` targets
   - ✅ Safe: Test property getters/setters
   - ❌ Unsafe: Actually creating constraints on nodes
   - ❌ Unsafe: Creating multiple camera nodes in the same test

2. **Screen/World Conversion** - **CANNOT BE UNIT TESTED**
   - Methods: `ScreenToWorldPoint()`, `WorldToScreenPoint()`, `ScreenPointToRay()`
   - **Problem**: Require `SCNRenderer` which needs a Metal device and full rendering context
   - Creating `SCNRenderer(device: nil, options: nil)` **crashes** in test environments
   - **Solution**: These methods can only be tested in integration/UI tests with actual views
   - ❌ Do NOT attempt to create SCNRenderer in unit tests

3. **Multiple Cameras** - Creating multiple camera components in a single test can cause heap corruption due to SceneKit's internal memory management. Test camera functionality with one camera per test.

## Known Quirks

1. **Component awake()** - Always call `awake()` on components after adding them in tests
2. **Scene allocation** - Always specify `.instantiate` or `.singleton`
3. **Layer masks** - Use the predefined layers only: `.default`, `.ground`, `.player`, `.environment`, `.projectile`, `.all`
4. **GameObject identity** - Use `===` for object identity checks, not `==`
5. **Layer filtering bug** - Fixed in GameObjectSearch.swift to use `.contains()` instead of `==` for OptionSet
6. **Tag values** - Only `.untagged`, `.mainCamera`, and `.custom(String)` exist - no predefined `.player` or `.enemy` tags
7. **Lifecycle super calls** - **ALWAYS call `super.method()` first** when overriding lifecycle methods (awake, start, update, lateUpdate, preUpdate, fixedUpdate) in MonoBehaviour subclasses
8. **Scene default objects** - Scenes may create default objects (like cameras). Filter test results to only include objects you explicitly created:
   ```swift
   let results = GameObject.findGameObjects(.layer(.default), in: scene)
       .filter { $0.name == "MyObject" }
   ```
9. **Input state** - Call `Input.resetForTesting()` at the start of each Input test to clear state from previous tests

## Testing Critical Framework Code

Priority order for testing:
1. **Physics system** - Raycasting, collisions (breaks gameplay)
2. **Input system** - Keyboard/mouse (breaks interactivity)
3. **Lifecycle** - awake/start/update/lateUpdate (breaks everything)
4. **Core properties** - Rigidbody, Transform changes

## Example Test Template

```swift
import Testing
import SceneKit
@testable import UnityKit

@Suite("Feature Name")
struct FeatureTests {

    func createTestScene() -> Scene {
        return Scene(allocation: .instantiate)
    }

    @Test("Feature works as expected")
    func testFeature() throws {
        let scene = createTestScene()
        let obj = GameObject(name: "TestObject")
        scene.addGameObject(obj)

        // Use try #require for optionals
        let component = try #require(obj.getComponent(SomeComponent.self))
        #expect(component.someProperty == expectedValue)
    }
}
```

## Compilation Errors to Watch For

- `Extra argument 'in' in call` → Remove `in:` parameter from GameObject
- `No exact matches in call to initializer` → Check Scene requires `allocation:`
- `Type 'GameObject.Layer' has no member 'ui'` → Use valid layers only
- Component not initialized → Call `awake()` after adding component

---

## Test Coverage Summary

As of 2025-10-16, UnityKit has comprehensive test coverage for:

1. **Physics System** (`PhysicsTests.swift`)
   - Raycast and RaycastAll functionality
   - Ray-AABB intersection
   - Layer mask filtering
   - Hit information accuracy
   - Edge cases and nil handling

2. **GameObject Search** (`GameObjectSearchTests.swift`)
   - Layer filtering (fixed OptionSet bug)
   - Name searching (exact, contains, startsWith, any)
   - Tag searching
   - Camera and light filtering
   - Hierarchical search
   - Combined search criteria

3. **Colliders** (`ColliderTests.swift`)
   - BoxCollider, SphereCollider, CapsuleCollider
   - Custom dimensions and center offsets
   - Configure pattern
   - Physics.overlapSphere integration
   - Layer mask respect in overlap queries

4. **Camera** (`CameraTests.swift`)
   - Field of view and clipping planes
   - Orthographic mode
   - Culling masks
   - Target following
   - Screen/World coordinate conversion methods

5. **Input System** (`InputTests.swift`)
   - Keyboard state (GetKey, GetKeyDown, GetKeyUp)
   - Mouse button state
   - Mouse position tracking
   - Frame-specific state clearing
   - Multi-key/button handling

6. **Lifecycle Methods** (`LifecycleTests.swift`)
   - awake, start, update, lateUpdate, fixedUpdate, preUpdate
   - Call order verification
   - Disabled/enabled behaviour
   - Hierarchical lifecycle propagation
   - Active/inactive state handling

7. **Rigidbody** (`RigidbodyTests.swift`)
   - Property getters/setters
   - Constraint system (freezePosition, freezeRotation, freezeAll)
   - Velocity and angular velocity factors
   - Direct property assignment

8. **Vector3 & Quaternion** (`Vector3Tests.swift`, `QuaternionTests.swift`)
   - Math operations
   - Extensions and utility functions

9. **Time System** (`TimeTests.swift`)
   - Time scaling
   - Frame simulation
   - Delta time tracking

## Bugs Fixed During Testing

1. **Layer Filtering Bug** (GameObjectSearch.swift:54)
   - **Problem**: Used `==` instead of `.contains()` for OptionSet comparison
   - **Impact**: GameObject.findGameObjects(.layer()) filtered out all objects
   - **Fix**: Changed to `layerMask.contains(gameObject.layer)`

2. **Time Testing Helpers Unavailable** (Time.swift)
   - **Problem**: Testing helpers wrapped in `#if DEBUG` which wasn't defined in tests
   - **Impact**: resetForTesting() and simulateFrame() were unavailable
   - **Fix**: Removed `#if DEBUG` conditional compilation

3. **Object Cache Crash** (Object.swift)
   - **Problem**: Using `T.init()` as dictionary key created unnecessary instances
   - **Impact**: Camera initialization crashed when adding component
   - **Fix**: Changed to ObjectIdentifier(T.self) for type-based keys
   - **Improvement**: Added thread-safe DispatchQueue for cache operations

4. **Thread Safety - Component Management** (Object.swift)
   - **Problem**: `components` array accessed from multiple threads without synchronization
   - **Impact**: Random `EXC_BAD_ACCESS` crashes when tests run concurrently
   - **Fix**: Added concurrent DispatchQueue with barrier writes for all component operations
   - **Operations protected**: addComponent, removeComponent, getComponent, getComponents

5. **Thread Safety - Children Management** (GameObject.swift)
   - **Problem**: `children` array accessed from multiple threads without synchronization
   - **Impact**: Random crashes during concurrent GameObject hierarchy manipulation
   - **Fix**: Added concurrent DispatchQueue with barrier writes for all child operations
   - **Operations protected**: addChild, removeChild, getChild, getChildren, all update loops

**Last Updated:** 2025-10-16

---

## Running Tests

UnityKit uses UIKit and requires iOS simulator to run tests. **Do not use `swift test`** as it runs on macOS and will fail with UIKit import errors.

### Run All Tests

```bash
xcodebuild test -scheme UnityKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### Run Specific Test Suite

```bash
xcodebuild test -scheme UnityKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:UnityKitTests/TransformTests
```

### Available Test Suites

#### CRITICAL Tests (2025-10-16)
- `TransformTests` - Transform component (position, rotation, scale, direction vectors, lookAt) - **✅ 25 tests**
- `SceneTests` - Scene management (initialization, time management, GameObject management) - **✅ 21 tests** (serialized)
- `GameObjectHierarchyTests` - GameObject hierarchy (active state, parent/child, instantiation) - **✅ 29 tests**
- `MeshColliderTests` - MeshCollider (physics shapes, mesh assignment, convex hull) - **✅ 14 tests**
- `PlaneColliderTests` - PlaneCollider (geometry generation, vertices, normals, indices) - **✅ 17 tests**
- `CoroutineTests` - MonoBehaviour coroutines (queuing, execution, exit conditions, threading) - **✅ 18 tests** (serialized)

#### HIGH Priority Component Tests (2025-10-16)
- `LightTests` - Light component (25+ properties: shadows, attenuation, spot angles, etc.) - **✅ 45 tests**
- `ParticleSystemTests` - ParticleSystem lifecycle (load, execute, destroy) - **✅ 13 tests**

#### MEDIUM Priority Utility Tests (2025-10-16)
- `Vector2Tests` - Vector2 math operations (arithmetic, conversions, distance, length) - **✅ 43 tests**
- `VolumeTests` - Bounding box operations (size, center, addition, multiplication) - **✅ 27 tests**

#### Core Framework Tests
- `PhysicsTests` - Physics raycasting and overlap queries
- `ColliderTests` - Box, Sphere, Capsule colliders
- `GameObjectSearchTests` - GameObject search by layer/tag/name
- `CameraTests` - Camera component properties
- `InputTests` - Keyboard and mouse input
- `LifecycleTests` - MonoBehaviour lifecycle methods
- `RigidbodyTests` - Rigidbody properties and constraints
- `TimeTests` - Time system and scaling
- `Vector3Tests` - Vector3 math operations
- `QuaternionTests` - Quaternion utilities

**Note:** SceneTests and CoroutineTests use `.serialized` to avoid parallel execution issues with global state (Time singleton and coroutine queue management).

**Total New Tests Added (2025-10-16):** 252 tests covering CRITICAL, HIGH, and MEDIUM priority framework functionality
