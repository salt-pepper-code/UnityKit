import Foundation
import SceneKit

public typealias SceneLoadingOptions = [SCNSceneSource.LoadingOption: Any]

open class Scene: Identifiable {
    public enum Allocation {
        case instantiate
        case singleton
    }

    private var gameObjectCount: Int = 0
    private var ignoreUpdatesCount: Int = 0
    private var lastTimeStamp: TimeInterval?
    public let scnScene: SCNScene
    public let rootGameObject: GameObject
    internal let shadowCastingAllowed: Bool
    internal let uuid: String

    private(set) public static var sharedInstance: Scene?

    public convenience init?(sceneName: String, options: SceneLoadingOptions? = nil, bundle: Bundle = Bundle.main, allocation: Allocation, shadowCastingAllowed: Bool = true) {
        guard let sceneUrl = searchPathForResource(for: sceneName, extension: nil, bundle: bundle)
            else { return nil }

        self.init(sceneUrl: sceneUrl, options: options, allocation: allocation, shadowCastingAllowed: shadowCastingAllowed)
    }

    public convenience init?(scenePath: String, options: SceneLoadingOptions? = nil, bundle: Bundle = Bundle.main, allocation: Allocation, shadowCastingAllowed: Bool = true) {
        guard let sceneUrl = bundle.url(forResource: scenePath, withExtension: nil)
            else { return nil }

        self.init(sceneUrl: sceneUrl, options: options, allocation: allocation, shadowCastingAllowed: shadowCastingAllowed)
    }

    public convenience init?(sceneUrl: URL, options: SceneLoadingOptions? = nil, allocation: Allocation, shadowCastingAllowed: Bool = true) {
        guard let scene = try? SCNScene(url: sceneUrl, options: options)
            else { return nil }

        self.init(scene, allocation: allocation, shadowCastingAllowed: shadowCastingAllowed)
    }

    public init(_ scene: SCNScene? = nil, allocation: Allocation, shadowCastingAllowed: Bool = true) {
        self.shadowCastingAllowed = shadowCastingAllowed

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

            let cameraComponent = cameraObject.addComponent(Camera.self)
            cameraObject.node.camera = cameraComponent.scnCamera

            cameraObject.tag = .mainCamera
            cameraObject.name = cameraObject.tag.name

            self.rootGameObject.addChild(cameraObject)

            cameraObject.transform.position = Vector3(0, 10, 20)
        }

        if shadowCastingAllowed == false {
            self.disableCastsShadow(gameObject: self.rootGameObject)
        }

        switch allocation {
        case .singleton:
            Scene.sharedInstance = self
        case .instantiate:
            Scene.sharedInstance = nil
        }
    }

    internal func disableCastsShadow(gameObject: GameObject) {
        gameObject.getChildren().forEach {
            $0.node.castsShadow = false
            $0.node.light?.castsShadow = false
            disableCastsShadow(gameObject: $0)
        }
    }
    //

    public func getInstanceID() -> String {
        return uuid
    }

    internal func preUpdate(updateAtTime time: TimeInterval) {
        guard let _ = lastTimeStamp else { return }

        rootGameObject.preUpdate()
    }

    internal func update(updateAtTime time: TimeInterval) {
        guard let lastTimeStamp = lastTimeStamp else {
            self.lastTimeStamp = time
            rootGameObject.start()
            return
        }

        Time.deltaTime = time - lastTimeStamp
        rootGameObject.update()
        rootGameObject.internalUpdate()
        self.lastTimeStamp = time
    }

    internal func fixedUpdate(updateAtTime time: TimeInterval) {
        guard let _ = lastTimeStamp else { return }
        rootGameObject.fixedUpdate()
    }

    //

    public func clearScene() {
        let copy = rootGameObject.getChildren()
        copy.forEach { destroy($0) }
    }

    public func addGameObject(_ gameObject: GameObject) {
        gameObject.addToScene(self)
        if shadowCastingAllowed == false {
            gameObject.node.castsShadow = false
        }
    }

    public func find(_ type: GameObject.SearchType) -> GameObject? {
        return GameObject.find(type, in: self)
    }

    public func findGameObjects(_ type: GameObject.SearchType) -> [GameObject] {
        return GameObject.findGameObjects(type, in: self)
    }
}

// Debug
extension Scene {
    public func printGameObjectsIgnoreUpdates() {
        gameObjectCount = 0
        ignoreUpdatesCount = 0
        printGameObjectsIgnoreUpdates(for: rootGameObject)
        Debug.log("ignoreUpdates count: \(ignoreUpdatesCount) / \(gameObjectCount)")
    }

    private func printGameObjectsIgnoreUpdates(for gameObject: GameObject) {
        gameObject.getChildren().forEach {
            gameObjectCount += 1
            if $0.ignoreUpdates {
                ignoreUpdatesCount += 1
            }
            Debug.log("\($0.name ?? "No name") -> ignoreUpdates: \($0.ignoreUpdates)")
            printGameObjectsIgnoreUpdates(for: $0)
        }
    }
}
