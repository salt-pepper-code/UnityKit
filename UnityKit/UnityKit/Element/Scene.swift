import Foundation
import SceneKit

open class Scene: Identifiable {

    public enum Allocation {
        case instantiate
        case singleton
    }

    private var lastTimeStamp: TimeInterval?
    public let scnScene: SCNScene
    public let rootGameObject: GameObject

    internal let uuid: String

    private(set) public static var sharedInstance: Scene?

    public convenience init?(sceneName: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main, allocation: Allocation) {

        guard let sceneUrl = searchPathForResource(for: sceneName, extension: nil, bundle: bundle)
            else { return nil }

        self.init(sceneUrl: sceneUrl, options: options, allocation: allocation)
    }
    
    public convenience init?(scenePath: String, options: [SCNSceneSource.LoadingOption : Any]? = nil, bundle: Bundle = Bundle.main, allocation: Allocation) {
        
        guard let sceneUrl = bundle.url(forResource: scenePath, withExtension: nil)
            else { return nil }

        self.init(sceneUrl: sceneUrl, options: options, allocation: allocation)
    }
    
    public convenience init?(sceneUrl: URL, options: [SCNSceneSource.LoadingOption : Any]? = nil, allocation: Allocation) {
        
        guard let scene = try? SCNScene(url: sceneUrl, options: options)
            else { return nil }

        self.init(scene, allocation: allocation)
    }
    
    public init(_ scene: SCNScene? = nil, allocation: Allocation) {

        self.uuid = UUID().uuidString
        
        self.scnScene = scene ?? SCNScene()
        
        self.rootGameObject = GameObject(self.scnScene.rootNode)
        
        self.rootGameObject.setScene(self)

        if let camera = GameObject.find(.camera(.any), in: self) {

            camera.tag = .mainCamera
            camera.name = camera.tag.name
        }

        if Camera.main(in: self) == nil {
            
            let cameraObject = GameObject()

            if let cameraComponent = cameraObject.addComponent(Camera.self) {
                cameraObject.node.camera = cameraComponent.scnCamera
            }

            cameraObject.tag = .mainCamera
            cameraObject.name = cameraObject.tag.name

            self.rootGameObject.addChild(cameraObject)
            
            cameraObject.transform.position = Vector3(0, 10, 20)
        }

        switch allocation {
        case .singleton:
            Scene.sharedInstance = self
        case .instantiate:
            Scene.sharedInstance = nil
        }
    }

    //

    public func getInstanceID() -> String {
        return uuid
    }
    
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

    internal func fixedUpdate(updateAtTime time: TimeInterval) {

        guard let _ = lastTimeStamp
            else { return }

        rootGameObject.fixedUpdate()
    }

    //
    
    public func clearScene() {
        
        let copy = rootGameObject.getChildren()
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

