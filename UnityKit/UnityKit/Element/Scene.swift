import Foundation
import SceneKit

open class Scene {

    public enum Allocation {
        case instantiate
        case singleton
    }

    public let scnScene: SCNScene
    public let rootGameObject: GameObject

    private(set) public static var sharedInstance: Scene?

    public convenience init?(sceneName: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main, allocation: Allocation) {

        guard let sceneUrl = searchPathForResource(for: sceneName, extension: nil, bundle: bundle)
            else { return nil }

        self.init(sceneUrl: sceneUrl, allocation: allocation)
    }
    
    public convenience init?(scenePath: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main, allocation: Allocation) {
        
        guard let sceneUrl = bundle.url(forResource: scenePath, withExtension: nil)
            else { return nil }

        self.init(sceneUrl: sceneUrl, allocation: allocation)
    }
    
    public convenience init?(sceneUrl: URL, options: [SCNSceneSource.LoadingOption : Any]? = nil, allocation: Allocation) {
        
        guard let scene = try? SCNScene(url: sceneUrl, options: options)
            else { return nil }

        self.init(scene, allocation: allocation)
    }
    
    public init(_ scene: SCNScene? = nil, allocation: Allocation) {
        
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

        switch allocation {
        case .singleton:
            Scene.sharedInstance = self
        case .instantiate:
            Scene.sharedInstance = nil
        }
    }

    //
    
    private var lastTimeStamp: TimeInterval?

    internal func update(updateAtTime time: TimeInterval) {

        guard let lastTimeStamp = lastTimeStamp else {

            self.lastTimeStamp = time
            rootGameObject.start()
            return
        }

        Time.deltaTime = time - lastTimeStamp
        rootGameObject.update()
        self.lastTimeStamp = time
    }

    //
    
    public func clearScene() {
        
        let copy = rootGameObject.getChilds()
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

