import Foundation
import SceneKit

open class Scene {
    
    private var displayLink : CADisplayLink?
    public let scnScene: SCNScene
    public let rootGameObject: GameObject
    
    public convenience init?(filename: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main) {
        
        guard let sceneUrl = searchPathForResource(forResource: filename, withExtension: nil, bundle: bundle)
            else { return nil }

        self.init(sceneUrl: sceneUrl)
    }
    
    public convenience init?(scenePath: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main) {
        
        guard let sceneUrl = bundle.url(forResource: scenePath, withExtension: nil)
            else { return nil }

        self.init(sceneUrl: sceneUrl)
    }
    
    public convenience init?(sceneUrl: URL, options: [SCNSceneSource.LoadingOption : Any]? = nil) {
        
        guard let scene = try? SCNScene(url: sceneUrl, options: options)
            else { return nil }

        self.init(scene)
    }
    
    public init(_ scene: SCNScene? = nil) {
        
        self.scnScene = scene ?? SCNScene()
        
        self.rootGameObject = GameObject(self.scnScene.rootNode)
        
        self.rootGameObject.setScene(self)
        
        if scene == nil || Camera.main(self) == nil {
            
            let cameraObject = GameObject()
            cameraObject.name = GameObject.Tags.mainCamera.rawValue
            cameraObject.tag = GameObject.Tags.mainCamera.rawValue
            
            self.rootGameObject.addChild(cameraObject)
            
            cameraObject.transform.position = Vector3(0, 10, 20)
            
            _ = cameraObject.addComponent(Camera.self)
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
        return GameObject.find(type, inScene: self)
    }
    
    public func findGameObjects(_ type: GameObject.SearchType) -> [GameObject] {
        return GameObject.findGameObjects(type, inScene: self)
    }
}

