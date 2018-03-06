import Foundation
import SceneKit

open class View: SCNView {
    
    public static func makeView(onView superview: UIView? = nil, sceneFilename filename: String? = nil) -> View {
        
        let view = View()
        
        if let filename = filename {
            view.sceneHolder = Scene(filename: filename)
        } else {
            view.sceneHolder = Scene()
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
            self.scene = sceneHolder?.scnScene
        }
    }
    
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        Screen.width = self.frame.size.width
        Screen.height = self.frame.size.height
        
        if let scene = self.sceneHolder, let camera = Camera.main(scene) {
            
            camera.calculateFieldOfViews()
        }
    }
}
