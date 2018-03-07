import Foundation
import SceneKit

open class View: SCNView {
    
    public static func makeView(on superview: UIView? = nil, sceneFilename filename: String? = nil, option: Scene.Option = .singleton) -> View {
        
        let view = View()
        
        if let filename = filename {
            view.sceneHolder = Scene(filename: filename, option: option)
        } else {
            view.sceneHolder = Scene(option: option)
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
