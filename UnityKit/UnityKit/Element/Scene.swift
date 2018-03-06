import Foundation
import SceneKit

open class Scene {

    public enum Option {
        case instantiate
        case singleton
    }

    private var displayLink : CADisplayLink?
    public let scnScene: SCNScene
    public let rootGameObject: GameObject

    private(set) public static var sharedInstance: Scene?

    public convenience init?(filename: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main, option: Option) {
        
        guard let sceneUrl = searchPathForResource(forResource: filename, withExtension: nil, bundle: bundle)
            else { return nil }

        self.init(sceneUrl: sceneUrl, option: option)
    }
    
    public convenience init?(scenePath: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main, option: Option) {
        
        guard let sceneUrl = bundle.url(forResource: scenePath, withExtension: nil)
            else { return nil }

        self.init(sceneUrl: sceneUrl, option: option)
    }
    
    public convenience init?(sceneUrl: URL, options: [SCNSceneSource.LoadingOption : Any]? = nil, option: Option) {
        
        guard let scene = try? SCNScene(url: sceneUrl, options: options)
            else { return nil }

        self.init(scene, option: option)
    }
    
    public init(_ scene: SCNScene? = nil, option: Option) {
        
        self.scnScene = scene ?? SCNScene()
        
        self.rootGameObject = GameObject(self.scnScene.rootNode)
        
        self.rootGameObject.setScene(self)
        
        if scene == nil || Camera.main(in: self) == nil {
            
            let cameraObject = GameObject()
            cameraObject.tag = .mainCamera
            cameraObject.name = cameraObject.tag.name

            self.rootGameObject.addChild(cameraObject)
            
            cameraObject.transform.position = Vector3(0, 10, 20)
            
            _ = cameraObject.addComponent(Camera.self)
        }

        switch option {
        case .singleton:
            Scene.sharedInstance = self
        case .instantiate:
            Scene.sharedInstance = nil
        }

        self.intialize()
    }
    
    private func intialize() {
        
        guard let displayLink = UIScreen.main.displayLink(withTarget: self, selector: #selector(Scene.handleDisplayLink(_:)))
            else { return }
            
        if #available(iOS 10.0, *) {
            displayLink.preferredFramesPerSecond = 60
        } else {
            displayLink.frameInterval = 1
        }

        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)

        self.displayLink = displayLink
    }
    
    //
    
    private var lastTimeStamp: TimeInterval?
    
    @objc private func handleDisplayLink(_ sender: CADisplayLink) {
        
        if let lastTimeStamp = self.lastTimeStamp {
            
            Time.deltaTime = sender.timestamp - lastTimeStamp

            self.rootGameObject.update()
            self.lastTimeStamp = sender.timestamp
            
        } else {
            
            self.lastTimeStamp = sender.timestamp
            self.rootGameObject.start()
        }
    }
    
    //
    
    public func clearScene() {
        
        let copy = self.rootGameObject.getChilds()
        copy.forEach { destroy($0) }
    }
    
    public func addGameObject(_ gameObject: GameObject) {
        gameObject.addToScene(self)
    }
    
    public func find(_ type: GameObject.SearchType) -> GameObject? {
        return GameObject.find(type, in: self)
    }
    
    public func findGameObjects(_ type: GameObject.SearchType) -> [GameObject] {
        return GameObject.findGameObjects(type, in: self)
    }
}

