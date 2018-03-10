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
                                allocation: Scene.Allocation = .singleton) -> View {

        #if (arch(i386) || arch(x86_64))
            let options = options ?? View.Options(antialiasingMode: .none,
                                preferredRenderingAPI: .openGLES2)
        #else
            let options = options ?? View.Options(antialiasingMode: .multisampling4X,
                                preferredRenderingAPI: .metal)
        #endif

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
        sceneHolder?.update(updateAtTime: time)
    }
}
