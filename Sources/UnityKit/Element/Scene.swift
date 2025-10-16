import Foundation
import SceneKit

public typealias SceneLoadingOptions = [SCNSceneSource.LoadingOption: Any]

open class Scene: Identifiable, Equatable {
    public enum Allocation {
        case instantiate
        case singleton
    }

    private var gameObjectCount: Int = 0
    private var ignoreUpdatesCount: Int = 0
    private var lastTimeStamp: TimeInterval?
    public let scnScene: SCNScene
    public let rootGameObject: GameObject
    let shadowCastingAllowed: Bool
    public let id: String

    public private(set) static var shared: Scene?

    public convenience init?(
        sceneName: String,
        options: SceneLoadingOptions? = nil,
        bundle: Bundle = Bundle.main,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        guard let sceneUrl = searchPathForResource(for: sceneName, extension: nil, bundle: bundle)
        else { return nil }

        self.init(
            sceneUrl: sceneUrl,
            options: options,
            allocation: allocation,
            shadowCastingAllowed: shadowCastingAllowed
        )
    }

    public convenience init?(
        scenePath: String,
        options: SceneLoadingOptions? = nil,
        bundle: Bundle = Bundle.main,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        guard let sceneUrl = bundle.url(forResource: scenePath, withExtension: nil)
        else { return nil }

        self.init(
            sceneUrl: sceneUrl,
            options: options,
            allocation: allocation,
            shadowCastingAllowed: shadowCastingAllowed
        )
    }

    public convenience init?(
        sceneUrl: URL,
        options: SceneLoadingOptions? = nil,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        guard let scene = try? SCNScene(url: sceneUrl, options: options)
        else { return nil }

        self.init(
            scene,
            allocation: allocation,
            shadowCastingAllowed: shadowCastingAllowed
        )
    }

    public init(
        _ scene: SCNScene? = nil,
        allocation: Allocation,
        shadowCastingAllowed: Bool = true
    ) {
        self.shadowCastingAllowed = shadowCastingAllowed

        self.id = UUID().uuidString

        self.scnScene = scene ?? SCNScene()

        self.rootGameObject = GameObject(self.scnScene.rootNode)

        self.rootGameObject.setScene(self)

        if let camera = GameObject.find(.camera(.any), in: self) {
            camera.tag = .mainCamera
            camera.name = camera.tag.name
        }

        if Camera.main(in: self) == nil {
            let cameraObject = GameObject()

            cameraObject.tag = .mainCamera
            cameraObject.name = cameraObject.tag.name

            self.rootGameObject.addChild(cameraObject)

            let cameraComponent = cameraObject.addComponent(Camera.self)
            cameraObject.node.camera = cameraComponent.scnCamera

            cameraObject.transform.position = Vector3(0, 10, 20)
        }

        if shadowCastingAllowed == false {
            self.disableCastsShadow(gameObject: self.rootGameObject)
        }

        switch allocation {
        case .singleton:
            Scene.shared = self
        case .instantiate:
            Scene.shared = nil
        }
    }

    func disableCastsShadow(gameObject: GameObject) {
        for getChild in gameObject.getChildren() {
            getChild.node.castsShadow = false
            getChild.node.light?.castsShadow = false
            self.disableCastsShadow(gameObject: getChild)
        }
    }

    //

    public func getInstanceID() -> String {
        self.id
    }

    func preUpdate(updateAtTime time: TimeInterval) {
        guard let _ = lastTimeStamp else { return }

        self.rootGameObject.preUpdate()
    }

    func update(updateAtTime time: TimeInterval) {
        guard let lastTimeStamp else {
            self.lastTimeStamp = time
            self.rootGameObject.start()
            return
        }

        // Calculate unscaled delta time
        let realDelta = time - lastTimeStamp
        Time.unscaledDeltaTime = realDelta

        // Apply time scale and update scaled delta/time
        Time.deltaTime = realDelta * Time.timeScale
        Time.time += Time.deltaTime
        Time.frameCount += 1

        self.rootGameObject.update()
        self.rootGameObject.internalUpdate()
        self.lastTimeStamp = time
    }

    func fixedUpdate(updateAtTime time: TimeInterval) {
        guard let _ = lastTimeStamp else { return }
        self.rootGameObject.fixedUpdate()
    }

    //

    public func clearScene() {
        let copy = self.rootGameObject.getChildren()
        copy.forEach { destroy($0) }
    }

    public func addGameObject(_ gameObject: GameObject) {
        gameObject.addToScene(self)
        if self.shadowCastingAllowed == false {
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
        self.gameObjectCount = 0
        self.ignoreUpdatesCount = 0
        self.printGameObjectsIgnoreUpdates(for: self.rootGameObject)
        Debug.info("ignoreUpdates count: \(self.ignoreUpdatesCount) / \(self.gameObjectCount)")
    }

    private func printGameObjectsIgnoreUpdates(for gameObject: GameObject) {
        for getChild in gameObject.getChildren() {
            self.gameObjectCount += 1
            if getChild.ignoreUpdates {
                self.ignoreUpdatesCount += 1
            }
            Debug.info("\(getChild.name ?? "No name") -> ignoreUpdates: \(getChild.ignoreUpdates)")
            self.printGameObjectsIgnoreUpdates(for: getChild)
        }
    }
}
