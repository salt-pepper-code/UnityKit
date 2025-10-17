/// Entry point for creating and managing UnityKit scene views.
///
/// `UI` is the main namespace for integrating UnityKit scenes into your iOS applications.
/// It provides both SwiftUI and UIKit interfaces for displaying 3D scenes with full
/// Unity-style component and update loop support.
///
/// ## Overview
///
/// The UI module is the primary way users interact with UnityKit. It bridges the gap between
/// iOS UI frameworks (SwiftUI and UIKit) and UnityKit's GameObject-based scene management,
/// providing a seamless integration experience.
///
/// Choose your integration path:
/// - Use ``SwiftUIView`` for SwiftUI-based applications
/// - Use ``UIKitView`` for UIKit-based applications or UIViewControllers
///
/// Both approaches provide the same underlying functionality, with ``SwiftUIView`` internally
/// wrapping a ``UIKitView`` for compatibility with SwiftUI's declarative syntax.
///
/// ## Key Features
///
/// - **Cross-Framework Support**: Works with both SwiftUI and UIKit
/// - **Scene Loading**: Load pre-built scenes from files or create them programmatically
/// - **Configuration Options**: Fine-tune rendering quality, lighting, and behavior
/// - **Full Lifecycle**: Complete Unity-style update loop with preUpdate, update, and fixedUpdate
/// - **Physics Integration**: Automatic collision detection and physics simulation
/// - **Touch Input**: Built-in touch event handling and gesture recognition
/// - **Platform Optimization**: Automatic optimization for device vs. simulator
///
/// ## Topics
///
/// ### SwiftUI Integration
/// - ``SwiftUIView``
///
/// ### UIKit Integration
/// - ``UIKitView``
/// - ``UIKitView/makeView(on:sceneName:options:extraLayers:)``
///
/// ### Configuration
/// - ``Options``
///
/// ## SwiftUI Example
///
/// ```swift
/// import SwiftUI
/// import UnityKit
///
/// struct GameView: View {
///     var body: some View {
///         UI.SwiftUIView(
///             sceneName: "MainLevel",
///             options: UI.Options(
///                 autoenablesDefaultLighting: true,
///                 antialiasingMode: .multisampling4X,
///                 showsStatistics: false
///             )
///         )
///         .ignoresSafeArea()
///     }
/// }
///
/// // With scene manipulation
/// struct InteractiveView: View {
///     @State private var sceneView = UI.SwiftUIView(sceneName: "Game")
///     @State private var score = 0
///
///     var body: some View {
///         VStack {
///             sceneView.ignoresSafeArea()
///
///             HStack {
///                 Text("Score: \(score)")
///                 Button("Spawn Enemy") {
///                     spawnEnemy()
///                 }
///             }
///             .padding()
///         }
///     }
///
///     func spawnEnemy() {
///         guard let scene = sceneView.scene else { return }
///
///         let enemy = GameObject(name: "Enemy")
///         enemy.transform.position = Vector3(0, 5, 0)
///         enemy.addComponent(MeshRenderer.self)
///         enemy.addComponent(Rigidbody.self)
///         scene.addGameObject(enemy)
///     }
/// }
/// ```
///
/// ## UIKit Example
///
/// ```swift
/// import UIKit
/// import UnityKit
///
/// class GameViewController: UIViewController {
///     var sceneView: UI.UIKitView!
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         // Create and attach the scene view
///         sceneView = UI.UIKitView.makeView(
///             on: view,
///             sceneName: "Level1",
///             options: UI.Options(
///                 autoenablesDefaultLighting: true,
///                 antialiasingMode: .multisampling4X,
///                 backgroundColor: .black
///             ),
///             extraLayers: ["Enemy", "Player", "Pickup"]
///         )
///
///         // Access and manipulate the scene
///         setupScene()
///     }
///
///     func setupScene() {
///         guard let scene = sceneView.sceneHolder else { return }
///
///         // Find existing objects
///         if let player = scene.find(name: "Player") {
///             player.transform.position = Vector3(0, 1, 0)
///         }
///
///         // Add new objects
///         let camera = GameObject(name: "MainCamera")
///         camera.addComponent(Camera.self)
///         camera.transform.position = Vector3(0, 5, 10)
///         scene.addGameObject(camera)
///
///         // Add lighting
///         let light = GameObject(name: "DirectionalLight")
///         let lightComponent = light.addComponent(Light.self)
///         lightComponent.type = .directional
///         scene.addGameObject(light)
///     }
///
///     override func viewWillDisappear(_ animated: Bool) {
///         super.viewWillDisappear(animated)
///         // Scene is automatically cleaned up
///     }
/// }
/// ```
///
/// ## Empty Scene Example
///
/// ```swift
/// // Create an empty scene and populate it programmatically
/// let view = UI.SwiftUIView(
///     options: UI.Options(
///         autoenablesDefaultLighting: false,
///         backgroundColor: .gray
///     )
/// )
///
/// if let scene = view.scene {
///     // Add camera
///     let camera = GameObject(name: "Camera")
///     camera.addComponent(Camera.self)
///     camera.transform.position = Vector3(0, 0, 10)
///     scene.addGameObject(camera)
///
///     // Add a cube
///     let cube = GameObject(name: "Cube")
///     let renderer = cube.addComponent(MeshRenderer.self)
///     renderer.geometry = .box(width: 1, height: 1, length: 1)
///     scene.addGameObject(cube)
///
///     // Add rotation behavior
///     class Rotator: Component {
///         override func update() {
///             transform.rotation += Vector3(0, 1, 0)
///         }
///     }
///     cube.addComponent(Rotator.self)
/// }
/// ```
///
/// ## Scene Loading Example
///
/// ```swift
/// // Load a scene file from your app bundle
/// let view = UI.UIKitView.makeView(
///     on: containerView,
///     sceneName: "MenuScene",  // Loads MenuScene.scn
///     options: UI.Options(
///         rendersContinuously: true,
///         castShadow: true
///     )
/// )
///
/// // Scene files should be added to your Xcode project
/// // and included in your app bundle
/// ```
///
/// ## Advanced Configuration Example
///
/// ```swift
/// // Development configuration with debugging enabled
/// let devOptions = UI.Options(
///     allowsCameraControl: true,
///     autoenablesDefaultLighting: true,
///     antialiasingMode: .multisampling2X,
///     showsStatistics: true,
///     rendersContinuously: true
/// )
///
/// // Production configuration optimized for performance
/// let prodOptions = UI.Options(
///     autoenablesDefaultLighting: false,
///     antialiasingMode: .multisampling4X,
///     preferredRenderingAPI: .metal,
///     backgroundColor: .black,
///     rendersContinuously: true,
///     castShadow: true,
///     allocation: .singleton
/// )
///
/// #if DEBUG
/// let options = devOptions
/// #else
/// let options = prodOptions
/// #endif
///
/// let view = UI.SwiftUIView(sceneName: "Game", options: options)
/// ```
///
/// ## See Also
///
/// - ``Scene``: Core scene management and GameObject container
/// - ``GameObject``: Base class for scene objects
/// - ``Component``: Base class for attaching behavior to GameObjects
/// - ``Camera``: Camera component for rendering perspectives
/// - ``Input``: Touch and gesture input handling
public enum UI {}
