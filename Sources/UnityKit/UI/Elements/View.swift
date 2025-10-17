import Foundation
import SceneKit
import SwiftUI

public extension UI {
    /// Configuration options for UnityKit scene rendering and behavior.
    ///
    /// `Options` provides fine-grained control over how your UnityKit scene is rendered and displayed.
    /// These options are passed when creating a ``UI/SwiftUIView`` or ``UI/UIKitView`` and configure
    /// the underlying SceneKit renderer, lighting, camera controls, and scene allocation strategy.
    ///
    /// ## Overview
    ///
    /// The Options struct allows you to customize various aspects of the rendering pipeline including
    /// antialiasing quality, rendering API selection, shadow casting, and visual debugging tools.
    /// Most properties are optional, allowing the framework to use sensible defaults when not specified.
    ///
    /// ## Platform-Specific Defaults
    ///
    /// When nil values are provided, the framework applies different defaults depending on the target:
    /// - **Device (Metal)**: `multisampling4X` antialiasing, Metal rendering API, shadows enabled
    /// - **Simulator (OpenGL ES)**: No antialiasing, OpenGL ES 2.0 API, shadows disabled for performance
    ///
    /// ## Topics
    ///
    /// ### Camera and Interaction
    /// - ``allowsCameraControl``
    ///
    /// ### Lighting and Shadows
    /// - ``autoenablesDefaultLighting``
    /// - ``castShadow``
    ///
    /// ### Rendering Configuration
    /// - ``antialiasingMode``
    /// - ``preferredRenderingAPI``
    /// - ``rendersContinuously``
    /// - ``backgroundColor``
    ///
    /// ### Debugging
    /// - ``showsStatistics``
    ///
    /// ### Scene Management
    /// - ``allocation``
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Minimal configuration with defaults
    /// let options = UI.Options()
    ///
    /// // Custom configuration for production
    /// let productionOptions = UI.Options(
    ///     autoenablesDefaultLighting: true,
    ///     antialiasingMode: .multisampling4X,
    ///     preferredRenderingAPI: .metal,
    ///     backgroundColor: .black,
    ///     allocation: .singleton
    /// )
    ///
    /// // Debug configuration with statistics
    /// let debugOptions = UI.Options(
    ///     allowsCameraControl: true,
    ///     showsStatistics: true,
    ///     rendersContinuously: true
    /// )
    /// ```
    struct Options {
        /// Enables interactive camera control via touch gestures.
        ///
        /// When enabled, users can manipulate the camera using standard gestures:
        /// - Pan to rotate
        /// - Pinch to zoom
        /// - Two-finger drag to translate
        ///
        /// - Note: This is useful during development but typically disabled in production apps
        ///   that implement custom camera controls.
        public let allowsCameraControl: Bool?

        /// Automatically adds default lighting to the scene.
        ///
        /// When enabled, SceneKit adds omnidirectional lighting that illuminates all objects
        /// from all directions. This is useful for quick prototyping but typically disabled
        /// in production in favor of custom lighting setups.
        ///
        /// Default value is `false`.
        public let autoenablesDefaultLighting: Bool?

        /// The antialiasing technique used for rendering.
        ///
        /// Controls how edges are smoothed to reduce jagged appearance. Higher quality
        /// antialiasing improves visual fidelity but impacts performance.
        ///
        /// Common values:
        /// - `.none` - No antialiasing (best performance)
        /// - `.multisampling2X` - Basic antialiasing
        /// - `.multisampling4X` - High quality antialiasing (default on devices)
        ///
        /// - Note: On simulator, defaults to `.none` for performance.
        public let antialiasingMode: SCNAntialiasingMode?

        /// The graphics API used for rendering.
        ///
        /// Specifies which low-level rendering API SceneKit should use.
        ///
        /// - `.metal` - Modern, high-performance API (default on devices)
        /// - `.openGLES2` - Legacy API for compatibility (default on simulator)
        ///
        /// - Note: Metal is preferred for production apps on physical devices.
        public let preferredRenderingAPI: SCNRenderingAPI?

        /// Displays performance statistics overlay.
        ///
        /// When enabled, shows real-time rendering metrics including:
        /// - Frames per second (FPS)
        /// - Draw call count
        /// - Polygon count
        ///
        /// Useful for performance profiling during development.
        public let showsStatistics: Bool?

        /// The background color of the scene view.
        ///
        /// Sets the color shown behind the 3D scene. When `nil`, uses the default
        /// system background color.
        public let backgroundColor: Color?

        /// Controls continuous rendering vs. on-demand rendering.
        ///
        /// - `true` - Scene renders continuously every frame (default, best for animations)
        /// - `false` - Scene renders only when changes occur (better for static scenes)
        ///
        /// Default value is `true`.
        public let rendersContinuously: Bool?

        /// Enables shadow casting in the scene.
        ///
        /// When enabled, lights can cast shadows from objects. Shadows significantly
        /// enhance visual realism but have a performance cost.
        ///
        /// Default value is `true`.
        ///
        /// - Note: Automatically disabled on simulator for performance.
        public let castShadow: Bool = true

        /// Scene allocation strategy.
        ///
        /// Determines how the scene is managed:
        /// - ``Scene/Allocation/singleton`` - Scene becomes the shared singleton instance
        ///   accessible via `Scene.shared`
        /// - ``Scene/Allocation/instantiate`` - Creates an independent scene instance
        ///
        /// Default value is `.singleton`.
        public let allocation: Scene.Allocation = .singleton

        /// Creates scene configuration options.
        ///
        /// Initialize with custom rendering and behavior settings. All parameters are optional,
        /// allowing you to override only the specific options you need while using sensible
        /// defaults for the rest.
        ///
        /// - Parameters:
        ///   - allowsCameraControl: Enable interactive camera control gestures. Default is `nil`.
        ///   - autoenablesDefaultLighting: Add automatic omnidirectional lighting. Default is `false`.
        ///   - antialiasingMode: Antialiasing quality setting. Default is platform-specific.
        ///   - preferredRenderingAPI: Graphics API to use. Default is platform-specific.
        ///   - showsStatistics: Show performance statistics overlay. Default is `nil`.
        ///   - backgroundColor: Scene background color. Default is `nil` (system default).
        ///   - rendersContinuously: Enable continuous rendering. Default is `true`.
        ///   - castShadow: Enable shadow casting. Default is `true`.
        ///   - allocation: Scene allocation strategy. Default is `.singleton`.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Production configuration
        /// let options = UI.Options(
        ///     autoenablesDefaultLighting: true,
        ///     antialiasingMode: .multisampling4X,
        ///     castShadow: true,
        ///     allocation: .singleton
        /// )
        ///
        /// // Development configuration
        /// let devOptions = UI.Options(
        ///     allowsCameraControl: true,
        ///     showsStatistics: true
        /// )
        /// ```
        public init(
            allowsCameraControl: Bool? = nil,
            autoenablesDefaultLighting: Bool? = false,
            antialiasingMode: SCNAntialiasingMode? = nil,
            preferredRenderingAPI: SCNRenderingAPI? = nil,
            showsStatistics: Bool? = nil,
            backgroundColor: Color? = nil,
            rendersContinuously: Bool? = true,
            castShadow: Bool = true,
            allocation: Scene.Allocation = .singleton
        ) {
            self.allowsCameraControl = allowsCameraControl
            self.autoenablesDefaultLighting = autoenablesDefaultLighting
            self.antialiasingMode = antialiasingMode
            self.preferredRenderingAPI = preferredRenderingAPI
            self.showsStatistics = showsStatistics
            self.backgroundColor = backgroundColor
            self.rendersContinuously = rendersContinuously
        }
    }

    /// SwiftUI wrapper for UnityKit scenes.
    ///
    /// `SwiftUIView` is the primary entry point for integrating UnityKit into SwiftUI applications.
    /// It conforms to `UIViewRepresentable` and wraps a ``UI/UIKitView`` to provide seamless
    /// integration with SwiftUI's declarative syntax.
    ///
    /// ## Overview
    ///
    /// Use `SwiftUIView` to embed 3D scenes directly in your SwiftUI views. The view automatically
    /// handles the UIKit-SwiftUI bridging and manages the lifecycle of the underlying scene.
    /// You can load scenes from files or create them programmatically, configure rendering options,
    /// and access the scene for runtime manipulation.
    ///
    /// ## Scene Access
    ///
    /// The ``scene`` property provides direct access to the loaded ``Scene`` instance, allowing you
    /// to add GameObjects, find components, and manipulate the scene at runtime.
    ///
    /// ## Topics
    ///
    /// ### Creating a View
    /// - ``init(sceneName:options:extraLayers:)``
    ///
    /// ### Accessing the Scene
    /// - ``scene``
    ///
    /// ### UIViewRepresentable Conformance
    /// - ``makeUIView(context:)``
    /// - ``updateUIView(_:context:)``
    ///
    /// ## Example
    ///
    /// ```swift
    /// import SwiftUI
    /// import UnityKit
    ///
    /// struct GameView: View {
    ///     var body: some View {
    ///         UI.SwiftUIView(
    ///             sceneName: "MainScene",
    ///             options: UI.Options(
    ///                 autoenablesDefaultLighting: true,
    ///                 showsStatistics: true
    ///             )
    ///         )
    ///         .ignoresSafeArea()
    ///     }
    /// }
    ///
    /// // With scene access
    /// struct InteractiveGameView: View {
    ///     @State private var sceneView = UI.SwiftUIView(sceneName: "Level1")
    ///
    ///     var body: some View {
    ///         VStack {
    ///             sceneView
    ///                 .ignoresSafeArea()
    ///
    ///             Button("Add Cube") {
    ///                 if let scene = sceneView.scene {
    ///                     let cube = GameObject(name: "Cube")
    ///                     cube.addComponent(MeshRenderer.self)
    ///                     scene.addGameObject(cube)
    ///                 }
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    struct SwiftUIView: UIViewRepresentable {
        let sceneView: UI.UIKitView

        /// The active scene being rendered.
        ///
        /// Provides access to the ``Scene`` instance for runtime manipulation. Use this property
        /// to add GameObjects, query components, or modify the scene hierarchy after the view
        /// has been created.
        ///
        /// Returns `nil` if no scene has been loaded.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let view = UI.SwiftUIView(sceneName: "Game")
        /// if let scene = view.scene {
        ///     let player = scene.find(name: "Player")
        ///     player?.transform.position = Vector3(0, 5, 0)
        /// }
        /// ```
        public var scene: Scene? {
            self.sceneView.sceneHolder
        }

        /// Creates a SwiftUI-compatible UnityKit scene view.
        ///
        /// Initializes a new SwiftUI view that renders a UnityKit scene. You can load a scene
        /// from a file by providing a scene name, or create an empty scene by omitting it.
        /// Configuration options control rendering quality and behavior.
        ///
        /// - Parameters:
        ///   - sceneName: Optional name of a scene file to load (without extension). When `nil`,
        ///     creates an empty scene. The scene file should be in your app bundle.
        ///   - options: Rendering and behavior configuration. See ``UI/Options`` for details.
        ///     When `nil`, uses platform-specific defaults.
        ///   - extraLayers: Optional array of custom layer names to register for GameObject
        ///     organization and filtering. Layers allow you to categorize GameObjects for
        ///     selective rendering, raycasting, or logic.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Load a scene from file
        /// UI.SwiftUIView(sceneName: "MainMenu")
        ///
        /// // Empty scene with custom options
        /// UI.SwiftUIView(
        ///     options: UI.Options(
        ///         autoenablesDefaultLighting: true,
        ///         antialiasingMode: .multisampling4X,
        ///         backgroundColor: .black
        ///     )
        /// )
        ///
        /// // Scene with custom layers
        /// UI.SwiftUIView(
        ///     sceneName: "GameLevel",
        ///     options: UI.Options(showsStatistics: true),
        ///     extraLayers: ["Enemy", "Collectible", "Environment"]
        /// )
        /// ```
        public init(
            sceneName: String? = nil,
            options: Options? = nil,
            extraLayers: [String]? = nil
        ) {
            self.sceneView = UI.UIKitView.makeView(
                on: nil,
                sceneName: sceneName,
                options: options,
                extraLayers: extraLayers
            )
        }

        /// Creates the underlying UIKit view.
        ///
        /// Required by `UIViewRepresentable`. This method is called by SwiftUI to create
        /// the UIKit view that will be embedded in the SwiftUI hierarchy.
        ///
        /// - Parameter context: The view's context.
        /// - Returns: The configured ``UI/UIKitView`` instance.
        public func makeUIView(context: Context) -> UI.UIKitView {
            self.sceneView
        }

        /// Updates the UIKit view when SwiftUI state changes.
        ///
        /// Required by `UIViewRepresentable`. Currently a no-op as the view manages its own
        /// state through the UnityKit update loop.
        ///
        /// - Parameters:
        ///   - uiView: The UIKit view to update.
        ///   - context: The view's context.
        public func updateUIView(_ uiView: UI.UIKitView, context: Context) {}
    }
}

extension UI {
    /// UIKit view controller for rendering UnityKit scenes.
    ///
    /// `UIKitView` is a SceneKit-based view that provides the core rendering and lifecycle
    /// management for UnityKit scenes. It subclasses `SCNView` and implements the full
    /// UnityKit update loop including pre-update, update, fixed update, and physics callbacks.
    ///
    /// ## Overview
    ///
    /// This is the main view class for UIKit-based applications. It handles:
    /// - Scene rendering using SceneKit's renderer
    /// - Unity-style update loops (preUpdate, update, fixedUpdate)
    /// - Physics simulation and collision callbacks
    /// - Touch input processing and gesture recognition
    /// - Camera and screen size management
    ///
    /// While you can create instances directly, it's recommended to use the ``makeView(on:sceneName:options:extraLayers:)``
    /// factory method which handles proper initialization and configuration.
    ///
    /// ## Update Loop
    ///
    /// The view implements three update callbacks that mirror Unity's lifecycle:
    /// - **preUpdate**: Called before rendering each frame
    /// - **update**: Called after rendering each frame, for game logic
    /// - **fixedUpdate**: Called after physics simulation, for physics-related logic
    ///
    /// All updates are thread-safe and execute on the main queue.
    ///
    /// ## Scene Access
    ///
    /// The ``sceneHolder`` property provides access to the active ``Scene``. Setting this
    /// property automatically configures the view's camera and scene graph.
    ///
    /// ## Topics
    ///
    /// ### Creating a View
    /// - ``makeView(on:sceneName:options:extraLayers:)``
    /// - ``init(frame:options:)``
    ///
    /// ### Scene Management
    /// - ``sceneHolder``
    ///
    /// ### Lifecycle Methods
    /// - ``layoutSubviews()``
    ///
    /// ### Renderer Callbacks
    /// - ``renderer(_:willRenderScene:atTime:)``
    /// - ``renderer(_:didRenderScene:atTime:)``
    /// - ``renderer(_:didSimulatePhysicsAtTime:)``
    ///
    /// ### Physics Callbacks
    /// - ``physicsWorld(_:didBegin:)``
    /// - ``physicsWorld(_:didEnd:)``
    ///
    /// ### Touch Input
    /// - ``touchesBegan(_:with:)``
    /// - ``touchesMoved(_:with:)``
    /// - ``touchesEnded(_:with:)``
    /// - ``touchesCancelled(_:with:)``
    ///
    /// ## Example
    ///
    /// ```swift
    /// // UIKit integration in a view controller
    /// class GameViewController: UIViewController {
    ///     var sceneView: UI.UIKitView!
    ///
    ///     override func viewDidLoad() {
    ///         super.viewDidLoad()
    ///
    ///         // Create and configure the view
    ///         sceneView = UI.UIKitView.makeView(
    ///             on: view,
    ///             sceneName: "MainScene",
    ///             options: UI.Options(
    ///                 autoenablesDefaultLighting: true,
    ///                 showsStatistics: true
    ///             )
    ///         )
    ///
    ///         // Access the scene
    ///         if let scene = sceneView.sceneHolder {
    ///             let player = GameObject(name: "Player")
    ///             scene.addGameObject(player)
    ///         }
    ///     }
    /// }
    ///
    /// // Manual creation and setup
    /// let options: [String: Any] = [
    ///     "preferredRenderingAPI": SCNRenderingAPI.metal
    /// ]
    /// let view = UI.UIKitView(frame: .zero, options: options)
    /// view.sceneHolder = Scene(sceneName: "Level1")
    /// view.allowsCameraControl = true
    /// ```
    open class UIKitView: SCNView {
        private class AtomicLock {
            private let lock = DispatchSemaphore(value: 1)
            private var value: Bool = false

            func get() -> Bool {
                self.lock.wait()
                defer { lock.signal() }
                return self.value
            }

            func set(_ newValue: Bool) {
                self.lock.wait()
                defer { lock.signal() }
                self.value = newValue
            }
        }

        /// Creates a UIKit view for rendering UnityKit scenes.
        ///
        /// Direct initialization is available but ``makeView(on:sceneName:options:extraLayers:)``
        /// is the recommended approach for most use cases.
        ///
        /// - Parameters:
        ///   - frame: The frame rectangle for the view.
        ///   - options: SceneKit initialization options including rendering API preferences.
        override public init(frame: CGRect, options: [String: Any]? = nil) {
            self.lock = Dictionary(uniqueKeysWithValues: Lock.all.map { ($0, AtomicLock()) })
            super.init(frame: .zero, options: options)
            self.delegate = self
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private enum Lock: Int {
            case preUpdate, update, fixed, physicsBegin, physicsEnd
            static let all: [Lock] = [.preUpdate, .update, .fixed, .physicsBegin, .physicsEnd]
        }

        private var lock: [Lock: AtomicLock]

        /// Creates and configures a UnityKit scene view with automatic setup.
        ///
        /// This is the recommended way to create a UIKitView. The method handles all necessary
        /// initialization including scene loading, option configuration, layer registration,
        /// and superview attachment. Platform-specific optimizations are applied automatically.
        ///
        /// - Parameters:
        ///   - superview: Optional parent view to attach to. When provided, the view is added
        ///     as a subview with automatic resizing enabled and screen dimensions are initialized.
        ///   - sceneName: Optional name of a scene file to load (without extension). When `nil`,
        ///     creates an empty scene. Scene files should be in your app bundle.
        ///   - options: Configuration options for rendering and behavior. See ``UI/Options``.
        ///     When `nil`, platform-specific defaults are applied:
        ///     - **Device**: Metal rendering, 4x multisampling, shadows enabled
        ///     - **Simulator**: OpenGL ES 2.0, no antialiasing, shadows disabled
        ///   - extraLayers: Optional array of custom layer names to register. Layers provide
        ///     a way to categorize and filter GameObjects for rendering, raycasting, or logic.
        ///
        /// - Returns: A fully configured UIKitView ready for rendering.
        ///
        /// ## Platform Behavior
        ///
        /// On iOS simulator (x86_64/i386 architectures):
        /// - Shadows are automatically disabled for performance
        /// - OpenGL ES 2.0 is used instead of Metal
        /// - A warning is logged suggesting device usage for full features
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Attach to a view controller's view
        /// class GameViewController: UIViewController {
        ///     var sceneView: UI.UIKitView!
        ///
        ///     override func viewDidLoad() {
        ///         super.viewDidLoad()
        ///
        ///         sceneView = UI.UIKitView.makeView(
        ///             on: view,
        ///             sceneName: "GameLevel",
        ///             options: UI.Options(
        ///                 autoenablesDefaultLighting: true,
        ///                 antialiasingMode: .multisampling4X,
        ///                 showsStatistics: true
        ///             ),
        ///             extraLayers: ["Enemy", "Player", "UI"]
        ///         )
        ///     }
        /// }
        ///
        /// // Create without attaching (manual layout)
        /// let view = UI.UIKitView.makeView(
        ///     sceneName: "Menu",
        ///     options: UI.Options(backgroundColor: .black)
        /// )
        /// // Add to view hierarchy manually
        /// parentView.addSubview(view)
        /// view.frame = parentView.bounds
        ///
        /// // Create empty scene for dynamic content
        /// let emptyView = UI.UIKitView.makeView(
        ///     on: containerView,
        ///     options: UI.Options(rendersContinuously: true)
        /// )
        /// // Populate scene programmatically
        /// if let scene = emptyView.sceneHolder {
        ///     let cube = GameObject(name: "Cube")
        ///     cube.addComponent(MeshRenderer.self)
        ///     scene.addGameObject(cube)
        /// }
        /// ```
        public static func makeView(
            on superview: UIView? = nil,
            sceneName: String? = nil,
            options: Options? = nil,
            extraLayers: [String]? = nil
        ) -> UIKitView {
            let shadowCastingAllowed: Bool
            #if arch(i386) || arch(x86_64)
                let options = options ?? Options(
                    antialiasingMode: SCNAntialiasingMode.none,
                    preferredRenderingAPI: .openGLES2
                )
                shadowCastingAllowed = false
                Debug.warning("Shadows are disabled on the simulator for performance reason, prefer to use a device!")
            #else
                let options = options ?? Options(
                    antialiasingMode: SCNAntialiasingMode.multisampling4X,
                    preferredRenderingAPI: .metal
                )
                shadowCastingAllowed = options.castShadow
            #endif

            extraLayers?.forEach {
                GameObject.Layer.addLayer(with: $0)
            }

            let view = UIKitView(
                frame: .zero,
                options: ["preferredRenderingAPI": options.preferredRenderingAPI ?? SCNRenderingAPI.metal]
            )

            options.allowsCameraControl.map { view.allowsCameraControl = $0 }
            options.autoenablesDefaultLighting.map { view.autoenablesDefaultLighting = $0 }
            options.antialiasingMode.map { view.antialiasingMode = $0 }
            options.showsStatistics.map { view.showsStatistics = $0 }
            options.backgroundColor.map { view.backgroundColor = $0 }
            options.rendersContinuously.map { view.rendersContinuously = $0 }

            if let sceneName {
                view.sceneHolder = Scene(
                    sceneName: sceneName,
                    allocation: options.allocation,
                    shadowCastingAllowed: shadowCastingAllowed
                )
            } else {
                view.sceneHolder = Scene(
                    allocation: options.allocation,
                    shadowCastingAllowed: shadowCastingAllowed
                )
            }

            view.scene?.physicsWorld.contactDelegate = view

            if let superview {
                view.frame = superview.bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                superview.addSubview(view)

                Screen.width = view.frame.size.width
                Screen.height = view.frame.size.height
            }

            return view
        }

        /// The active UnityKit scene being rendered.
        ///
        /// Holds the current ``Scene`` instance that is being displayed in this view.
        /// Setting this property automatically configures the underlying SceneKit scene
        /// and camera system.
        ///
        /// When set, the following occurs automatically:
        /// - The SceneKit scene (`SCNScene`) is assigned from the Scene's scene graph
        /// - The view's point of view is set to the main camera in the scene
        /// - The scene becomes active and begins receiving update callbacks
        ///
        /// Setting to `nil` clears the scene and stops rendering.
        ///
        /// ## Example
        ///
        /// ```swift
        /// let view = UI.UIKitView.makeView()
        ///
        /// // Load and assign a scene
        /// view.sceneHolder = Scene(sceneName: "Level1")
        ///
        /// // Access scene for manipulation
        /// if let scene = view.sceneHolder {
        ///     let enemy = GameObject(name: "Enemy")
        ///     scene.addGameObject(enemy)
        /// }
        ///
        /// // Switch scenes
        /// view.sceneHolder = Scene(sceneName: "Level2")
        ///
        /// // Clear the scene
        /// view.sceneHolder = nil
        /// ```
        public var sceneHolder: Scene? {
            didSet {
                guard let scene = sceneHolder
                else { return }

                self.scene = scene.scnScene
                self.pointOfView = Camera.main(in: scene)?.gameObject?.node
            }
        }

        /// Updates layout and recalculates screen dimensions.
        ///
        /// Called automatically when the view's bounds change. This method updates the
        /// global `Screen` dimensions and recalculates the main camera's field of view
        /// to maintain correct perspective.
        ///
        /// - Note: If you need to respond to layout changes in your game objects, consider
        ///   listening for screen size changes rather than overriding this method.
        ///
        /// ## Example
        ///
        /// ```swift
        /// // Screen dimensions are automatically updated
        /// class GameViewController: UIViewController {
        ///     var sceneView: UI.UIKitView!
        ///
        ///     override func viewWillTransition(
        ///         to size: CGSize,
        ///         with coordinator: UIViewControllerTransitionCoordinator
        ///     ) {
        ///         super.viewWillTransition(to: size, with: coordinator)
        ///
        ///         coordinator.animate(alongsideTransition: { _ in
        ///             // layoutSubviews is called automatically
        ///             // Screen.width and Screen.height are updated
        ///         })
        ///     }
        /// }
        /// ```
        override open func layoutSubviews() {
            super.layoutSubviews()

            Screen.width = frame.size.width
            Screen.height = frame.size.height

            if let scene = sceneHolder,
               let camera = Camera.main(in: scene)
            {
                camera.calculateFieldOfViews()
            }
        }
    }
}

extension UI.UIKitView: SCNSceneRendererDelegate {
    /// Called before rendering each frame.
    ///
    /// This method implements the **preUpdate** phase of UnityKit's update loop. It's called
    /// by SceneKit's renderer immediately before drawing the frame, providing an opportunity
    /// to perform setup or calculations that should occur before rendering.
    ///
    /// The method is thread-safe and uses atomic locking to prevent overlapping updates.
    /// All scene updates are dispatched to the main queue.
    ///
    /// - Parameters:
    ///   - renderer: The SceneKit renderer.
    ///   - scene: The SceneKit scene being rendered.
    ///   - time: The current system time in seconds.
    ///
    /// - Note: This is called automatically by the rendering system. You should not call
    ///   this method directly. Instead, implement preUpdate logic in your ``Component``
    ///   subclasses or ``Scene`` callbacks.
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard lock[.preUpdate]?.get() == false else { return }
        lock[.preUpdate]?.set(true)
        DispatchQueue.main.async { [weak self] () in
            self?.sceneHolder?.preUpdate(updateAtTime: time)
            self?.lock[.preUpdate]?.set(false)
        }
    }

    /// Called after rendering each frame.
    ///
    /// This method implements the **update** phase of UnityKit's update loop. It's called
    /// by SceneKit's renderer immediately after drawing the frame, and is the primary
    /// location for game logic updates.
    ///
    /// During this phase:
    /// - Scene's update method is called, triggering all Component updates
    /// - Input system is updated to process queued touch events
    ///
    /// The method is thread-safe and uses atomic locking to prevent overlapping updates.
    /// All updates are dispatched to the main queue.
    ///
    /// - Parameters:
    ///   - renderer: The SceneKit renderer.
    ///   - scene: The SceneKit scene that was rendered.
    ///   - time: The current system time in seconds.
    ///
    /// - Note: This is called automatically by the rendering system. You should not call
    ///   this method directly. Instead, implement update logic in your ``Component``
    ///   subclasses or ``Scene`` callbacks.
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard lock[.update]?.get() == false else { return }
        lock[.update]?.set(true)
        DispatchQueue.main.async { [weak self] () in
            self?.sceneHolder?.update(updateAtTime: time)
            Input.update()
            self?.lock[.update]?.set(false)
        }
    }

    /// Called after physics simulation completes.
    ///
    /// This method implements the **fixedUpdate** phase of UnityKit's update loop. It's called
    /// by SceneKit's renderer after the physics world has been simulated, making it the
    /// appropriate place for physics-related logic and calculations.
    ///
    /// Use fixedUpdate for:
    /// - Applying forces and impulses to rigidbodies
    /// - Physics-based movement
    /// - Reading physics state after simulation
    ///
    /// The method is thread-safe and uses atomic locking to prevent overlapping updates.
    /// All updates are dispatched to the main queue.
    ///
    /// - Parameters:
    ///   - renderer: The SceneKit renderer.
    ///   - time: The current system time in seconds.
    ///
    /// - Note: This is called automatically by the physics system. You should not call
    ///   this method directly. Instead, implement fixedUpdate logic in your ``Component``
    ///   subclasses or ``Scene`` callbacks.
    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        guard lock[.fixed]?.get() == false else { return }
        lock[.fixed]?.set(true)
        DispatchQueue.main.async { [weak self] () in
            self?.sceneHolder?.fixedUpdate(updateAtTime: time)
            self?.lock[.fixed]?.set(false)
        }
    }
}

extension UI.UIKitView: SCNPhysicsContactDelegate {
    /// Called when two physics bodies begin making contact.
    ///
    /// This method is invoked by SceneKit's physics engine when two objects with colliders
    /// start touching. It forwards the collision event to all ``Collider`` components in
    /// the scene, allowing them to respond to collision events.
    ///
    /// The method is thread-safe and ensures only one physics begin event is processed at
    /// a time. All collision callbacks are dispatched to the main queue.
    ///
    /// - Parameters:
    ///   - world: The physics world where the contact occurred.
    ///   - contact: Information about the contact including the colliding bodies, contact
    ///     points, and collision impulse.
    ///
    /// - Note: This is called automatically by the physics system. You should not call
    ///   this method directly. Instead, implement collision logic in your ``Collider``
    ///   subclasses by overriding `physicsWorld(_:didBegin:)`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a custom Collider component
    /// class PlayerCollider: Collider {
    ///     override func physicsWorld(
    ///         _ world: SCNPhysicsWorld,
    ///         didBegin contact: SCNPhysicsContact
    ///     ) {
    ///         if let other = contact.nodeB.gameObject {
    ///             print("Player collided with \(other.name)")
    ///         }
    ///     }
    /// }
    /// ```
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard lock[.physicsBegin]?.get() == false else { return }
        lock[.physicsBegin]?.set(true)
        guard let sceneHolder
        else { return }

        DispatchQueue.main.async { [weak self] () in
            for item in GameObject.findObjectsOfType(Collider.self, in: sceneHolder) {
                item.physicsWorld(world, didBegin: contact)
            }
            self?.lock[.physicsBegin]?.set(false)
        }
    }

    /// Called when two physics bodies stop making contact.
    ///
    /// This method is invoked by SceneKit's physics engine when two objects with colliders
    /// separate after being in contact. It forwards the separation event to all ``Collider``
    /// components in the scene.
    ///
    /// The method is thread-safe and ensures only one physics end event is processed at
    /// a time. All separation callbacks are dispatched to the main queue.
    ///
    /// - Parameters:
    ///   - world: The physics world where the contact ended.
    ///   - contact: Information about the contact that ended, including the bodies that
    ///     were in contact.
    ///
    /// - Note: This is called automatically by the physics system. You should not call
    ///   this method directly. Instead, implement separation logic in your ``Collider``
    ///   subclasses by overriding `physicsWorld(_:didEnd:)`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // In a custom Collider component
    /// class TriggerZone: Collider {
    ///     override func physicsWorld(
    ///         _ world: SCNPhysicsWorld,
    ///         didEnd contact: SCNPhysicsContact
    ///     ) {
    ///         if let other = contact.nodeB.gameObject {
    ///             print("\(other.name) left the trigger zone")
    ///         }
    ///     }
    /// }
    /// ```
    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard lock[.physicsEnd]?.get() == false else { return }
        lock[.physicsEnd]?.set(true)
        guard let sceneHolder
        else { return }

        DispatchQueue.main.async { [weak self] () in
            for item in GameObject.findObjectsOfType(Collider.self, in: sceneHolder) {
                item.physicsWorld(world, didEnd: contact)
            }
            self?.lock[.physicsEnd]?.set(false)
        }
    }
}

extension UI.UIKitView: UIGestureRecognizerDelegate {
    /// Called when one or more fingers touch down on the view.
    ///
    /// Captures the initial touch events and forwards them to UnityKit's ``Input`` system.
    /// The touches are converted to UnityKit ``Touch`` objects and queued for processing
    /// in the next update cycle.
    ///
    /// - Parameters:
    ///   - touches: A set of UITouch instances representing the new touches.
    ///   - event: The event to which the touches belong.
    ///
    /// - Note: Touch data is processed during the update phase via `Input.update()`.
    ///   Access touches in your components using `Input.touches` or `Input.GetTouch()`.
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .began)
    }

    /// Called when one or more fingers move on the view.
    ///
    /// Captures touch movement events and forwards them to UnityKit's ``Input`` system.
    /// This is called continuously as fingers move across the screen.
    ///
    /// - Parameters:
    ///   - touches: A set of UITouch instances representing the moving touches.
    ///   - event: The event to which the touches belong.
    ///
    /// - Note: Movement data can be accessed via `Input.touches` to track gestures,
    ///   drag operations, or continuous input.
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .moved)
    }

    /// Called when one or more fingers lift from the view.
    ///
    /// Captures touch end events when fingers are released from the screen and forwards
    /// them to UnityKit's ``Input`` system.
    ///
    /// - Parameters:
    ///   - touches: A set of UITouch instances representing the ended touches.
    ///   - event: The event to which the touches belong.
    ///
    /// - Note: This is the normal completion of a touch sequence. Use this to detect
    ///   taps, releases, or the end of drag operations.
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .ended)
    }

    /// Called when the system cancels touch events.
    ///
    /// Captures touch cancellation events (e.g., incoming phone call, system gesture) and
    /// forwards them to UnityKit's ``Input`` system. Cancelled touches should be treated
    /// similarly to ended touches but indicate an interrupted gesture.
    ///
    /// - Parameters:
    ///   - touches: A set of UITouch instances representing the cancelled touches.
    ///   - event: The event to which the touches belong.
    ///
    /// - Note: Always handle cancelled touches to avoid leaving your app in an
    ///   inconsistent state when gestures are interrupted.
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .cancelled)
    }

    /// Determines whether a gesture recognizer should require another to fail.
    ///
    /// Always returns `false`, allowing all gestures to be recognized independently
    /// without requiring other gesture recognizers to fail first.
    ///
    /// - Parameters:
    ///   - gestureRecognizer: The gesture recognizer asking about the relationship.
    ///   - otherGestureRecognizer: The other gesture recognizer.
    /// - Returns: Always `false`.
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return false
    }

    /// Determines whether two gesture recognizers should recognize simultaneously.
    ///
    /// Always returns `true`, enabling multiple gesture recognizers to work together.
    /// This allows complex multi-touch interactions and prevents gesture conflicts.
    ///
    /// - Parameters:
    ///   - gestureRecognizer: The gesture recognizer asking about simultaneous recognition.
    ///   - otherGestureRecognizer: The other gesture recognizer.
    /// - Returns: Always `true`.
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
