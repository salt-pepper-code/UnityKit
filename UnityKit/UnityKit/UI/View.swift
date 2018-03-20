import Foundation
import SceneKit

open class View: SCNView {

    public struct Options {

        let allowsCameraControl: Bool?
        let autoenablesDefaultLighting: Bool?
        let antialiasingMode: SCNAntialiasingMode?
        let preferredRenderingAPI: SCNRenderingAPI?
        let showsStatistics: Bool?
        let backgroundColor: Color?
        let rendersContinuously: Bool?

        init(allowsCameraControl: Bool? = nil,
             autoenablesDefaultLighting: Bool? = false,
             antialiasingMode: SCNAntialiasingMode? = nil,
             preferredRenderingAPI: SCNRenderingAPI? = nil,
             showsStatistics: Bool? = nil,
             backgroundColor: Color? = nil,
             rendersContinuously: Bool? = true) {

            self.allowsCameraControl = allowsCameraControl
            self.autoenablesDefaultLighting = autoenablesDefaultLighting
            self.antialiasingMode = antialiasingMode
            self.preferredRenderingAPI = preferredRenderingAPI
            self.showsStatistics = showsStatistics
            self.backgroundColor = backgroundColor
            self.rendersContinuously = rendersContinuously
        }
    }

    public override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: .zero, options: options)
        self.delegate = self
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public static func makeView(on superview: UIView? = nil,
                                sceneName: String? = nil,
                                options: View.Options? = nil,
                                allocation: Scene.Allocation = .singleton,
                                extraLayers: [String]? = nil) -> View {

        #if (arch(i386) || arch(x86_64))
            let options = options ?? View.Options(antialiasingMode: .none,
                                preferredRenderingAPI: .openGLES2)
        #else
            let options = options ?? View.Options(antialiasingMode: .multisampling4X,
                                preferredRenderingAPI: .metal)
        #endif

        extraLayers?.forEach {
            GameObject.Layer.addLayer(with: $0)
        }

        let view = View(frame: .zero, options: ["preferredRenderingAPI": options.preferredRenderingAPI ?? SCNRenderingAPI.metal])

        options.allowsCameraControl.map { view.allowsCameraControl = $0 }
        options.autoenablesDefaultLighting.map { view.autoenablesDefaultLighting = $0 }
        options.antialiasingMode.map { view.antialiasingMode = $0 }
        options.showsStatistics.map { view.showsStatistics = $0 }
        options.backgroundColor.map { view.backgroundColor = $0 }
        options.rendersContinuously.map { view.rendersContinuously = $0 }

        if let sceneName = sceneName {
            view.sceneHolder = Scene(sceneName: sceneName, allocation: allocation)
        } else {
            view.sceneHolder = Scene(allocation: allocation)
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
    
    public var sceneHolder: Scene? {
        
        didSet {
            guard let scene = sceneHolder
                else { return }

            self.scene = scene.scnScene
            self.pointOfView = Camera.main(in: scene)?.gameObject?.node
        }
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

extension View: SCNSceneRendererDelegate {

    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

        DispatchQueue.main.async { () -> Void in
            self.sceneHolder?.update(updateAtTime: time)
            Input.endUpdateTouches()
        }
    }

    public func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {

        DispatchQueue.main.async { () -> Void in
            self.sceneHolder?.fixedUpdate(updateAtTime: time)
        }
    }
}

extension View: SCNPhysicsContactDelegate {

    public func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {

        guard let sceneHolder = sceneHolder
            else { return }

        DispatchQueue.main.async { () -> Void in
            GameObject.findObjectsOfType(Collider.self, in: sceneHolder).forEach {
                $0.physicsWorld(world, didBegin: contact)
            }
        }
    }

    public func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {

        guard let sceneHolder = sceneHolder
            else { return }

        DispatchQueue.main.async { () -> Void in
            GameObject.findObjectsOfType(Collider.self, in: sceneHolder).forEach {
                $0.physicsWorld(world, didEnd: contact)
            }
        }
    }
}

extension View {

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        Input.setTouches(
            touches.enumerated().map { (index, uitouch) -> Touch in
                Touch(uitouch, index: index)
        })

        Input.preUpdateTouches(.began)
    }

    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        Input.preUpdateTouches(.moved)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        Input.preUpdateTouches(.ended)
    }

    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

        Input.preUpdateTouches(.cancelled)
    }
}
