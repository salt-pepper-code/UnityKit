import Foundation
import SceneKit
import SwiftUI

extension UI {

    public struct Options {
        public let allowsCameraControl: Bool?
        public let autoenablesDefaultLighting: Bool?
        public let antialiasingMode: SCNAntialiasingMode?
        public let preferredRenderingAPI: SCNRenderingAPI?
        public let showsStatistics: Bool?
        public let backgroundColor: Color?
        public let rendersContinuously: Bool?
        public let castShadow: Bool = true
        public let allocation: Scene.Allocation = .singleton

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
}

extension UI {

    public struct SwiftUIView: UIViewRepresentable {

        let sceneView: UI.UIKitView
        public var scene: Scene? {
            sceneView.sceneHolder
        }

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

        public func makeUIView(context: Context) -> UI.UIKitView {
            sceneView
        }

        public func updateUIView(_ uiView: UI.UIKitView, context: Context) {

        }
    }
}

extension UI {
    open class UIKitView: SCNView {
        private class AtomicLock {
            private let lock = DispatchSemaphore(value: 1)
            private var value: Bool = false

            func get() -> Bool {
                lock.wait()
                defer { lock.signal() }
                return value
            }

            func set(_ newValue: Bool) {
                lock.wait()
                defer { lock.signal() }
                value = newValue
            }
        }

        public var sceneHolder: Scene? {
            didSet {
                guard let scene = sceneHolder
                else { return }

                self.scene = scene.scnScene
                self.pointOfView = Camera.main(in: scene)?.gameObject?.node
                scene.view = self
            }
        }

        public override init(frame: CGRect, options: [String: Any]? = nil) {
            self.lock = Dictionary(uniqueKeysWithValues: Lock.all.map { ($0, AtomicLock()) })
            super.init(frame: .zero, options: options)
            self.delegate = self
        }

        @available(*, unavailable)
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private enum Lock: Int {
            case preUpdate, update, fixed, physicsBegin, physicsEnd
            static let all: [Lock] = [.preUpdate, .update, .fixed, .physicsBegin, .physicsEnd]
        }
        private var lock: [Lock: AtomicLock]

        public static func makeView(
            on superview: UIView? = nil,
            sceneName: String? = nil,
            options: Options? = nil,
            extraLayers: [String]? = nil
        ) -> UIKitView {
            let shadowCastingAllowed: Bool
#if (arch(i386) || arch(x86_64))
            let options = options ?? Options(
                antialiasingMode: SCNAntialiasingMode.none,
                preferredRenderingAPI: .openGLES2
            )
            shadowCastingAllowed = false
            print("Shadows are disabled on the simulator for performance reason, prefer to use a device!")
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

            let view = UIKitView(frame: .zero, options: ["preferredRenderingAPI": options.preferredRenderingAPI ?? SCNRenderingAPI.metal])
            
            options.allowsCameraControl.map { view.allowsCameraControl = $0 }
            options.autoenablesDefaultLighting.map { view.autoenablesDefaultLighting = $0 }
            options.antialiasingMode.map { view.antialiasingMode = $0 }
            options.showsStatistics.map { view.showsStatistics = $0 }
            options.backgroundColor.map { view.backgroundColor = $0 }
            options.rendersContinuously.map { view.rendersContinuously = $0 }

            if let sceneName = sceneName {
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

            if let superview = superview {
                view.frame = superview.bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

                superview.addSubview(view)

                Screen.width = view.frame.size.width
                Screen.height = view.frame.size.height
            }

            return view
        }

        open override func layoutSubviews() {
            super.layoutSubviews()

            Screen.width = frame.size.width
            Screen.height = frame.size.height

            if let scene = sceneHolder,
               let camera = Camera.main(in: scene) {
                camera.calculateFieldOfViews()
            }
        }
    }
}

extension UI.UIKitView: SCNSceneRendererDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard lock[.preUpdate]?.get() == false else { return }
        lock[.preUpdate]?.set(true)
        DispatchQueue.main.async { [weak self] () -> Void in
            self?.sceneHolder?.preUpdate(updateAtTime: time)
            self?.lock[.preUpdate]?.set(false)
        }
    }

    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        guard lock[.update]?.get() == false else { return }
        lock[.update]?.set(true)
        DispatchQueue.main.async { [weak self] () -> Void in
            self?.sceneHolder?.update(updateAtTime: time)
            Input.update()
            self?.lock[.update]?.set(false)
        }
    }

    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        guard lock[.fixed]?.get() == false else { return }
        lock[.fixed]?.set(true)
        DispatchQueue.main.async { [weak self] () -> Void in
            self?.sceneHolder?.fixedUpdate(updateAtTime: time)
            self?.lock[.fixed]?.set(false)
        }
    }
}

extension UI.UIKitView: SCNPhysicsContactDelegate {
    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        guard lock[.physicsBegin]?.get() == false else { return }
        lock[.physicsBegin]?.set(true)
        guard let sceneHolder = sceneHolder
        else { return }

        DispatchQueue.main.async { [weak self] () -> Void in
            GameObject.findObjectsOfType(Collider.self, in: sceneHolder).forEach {
                $0.physicsWorld(world, didBegin: contact)
            }
            self?.lock[.physicsBegin]?.set(false)
        }
    }

    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        guard lock[.physicsEnd]?.get() == false else { return }
        lock[.physicsEnd]?.set(true)
        guard let sceneHolder = sceneHolder
        else { return }

        DispatchQueue.main.async { [weak self] () -> Void in
            GameObject.findObjectsOfType(Collider.self, in: sceneHolder).forEach {
                $0.physicsWorld(world, didEnd: contact)
            }
            self?.lock[.physicsEnd]?.set(false)
        }
    }
}

extension UI.UIKitView: UIGestureRecognizerDelegate {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .began)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .moved)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .ended)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touches = touches.enumerated().map { index, uitouch -> Touch in Touch(uitouch, index: index) }
        Input.stackTouches(touches, phase: .cancelled)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
