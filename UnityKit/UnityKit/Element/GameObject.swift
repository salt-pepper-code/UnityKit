import Foundation
import SceneKit

public final class GameObject: Object {

    public override var name: String? {
        
        didSet {
            node.name = name
        }
    }

    public var layer: Layer {

        get {
            return Layer(rawValue: node.categoryBitMask)
        }
        set {
            guard node.camera == nil,
                node.light == nil
                else { return }

            node.categoryBitMask = newValue.rawValue
            childs.forEach { $0.layer = newValue }
        }
    }

    public var tag: Tag = .untagged
    public let node: SCNNode

    private(set) public var transform: Transform!
    private(set) public var renderer: Renderer?
    
    private(set) internal var childs = [GameObject]()
    
    private(set) public weak var parent: GameObject?
    private(set) public weak var scene: Scene? {
        didSet {
            guard let oldScene = oldValue,
                let newScene = scene,
                let parent = parent,
                oldScene != newScene
                else { return }

            if parent == oldScene.rootGameObject {
                scene?.rootGameObject.addChild(self)
            }
        }
    }

    private var didAwake: Bool = false
    private var didStart: Bool = false

    public var activeInHierarchy: Bool {

        get {
            if let parent = parent {
                return activeSelf && parent.activeInHierarchy
            }
            return activeSelf
        }
    }

    private(set) public var activeSelf: Bool {

        get {
            return !node.isHidden
        }
        set {
            node.isHidden = !newValue
        }
    }

    public convenience init?(modelName: String, extension ext: String? = nil, bundle: Bundle = Bundle.main) {
        
        guard let modelUrl = searchPathForResource(for: modelName, extension: ext, bundle: bundle)
            else { return nil }
        
        self.init(modelUrl: modelUrl)
    }
    
    public convenience init?(modelPath: String, bundle: Bundle = Bundle.main) {
        
        guard let modelUrl = bundle.url(forResource: modelPath, withExtension: nil)
            else { return nil }
        
        self.init(modelUrl: modelUrl)
    }
    
    public convenience init?(modelUrl: URL) {
        
        guard let node = SCNReferenceNode(url: modelUrl)
            else { return nil }
        
        node.load()
        self.init(node)
    }

    public convenience init(name: String) {

        let node = SCNNode()
        node.name = name
        self.init(node)
    }
    
    public init(_ node: SCNNode) {
        
        self.node = node
        
        super.init()
        
        self.name = node.name ?? "No name"
        self.layer = Layer(rawValue: node.categoryBitMask)
        self.transform = addComponent(monoBehaviourOnly: false, type: Transform.self)
        
        if let geometry = node.geometry {
            
            self.renderer = addComponent(monoBehaviourOnly: false, type: Renderer.self)

            geometry.materials.forEach {
                self.renderer?.materials.append(Material($0))
            }
        }

        if let camera = node.camera,
            let cameraComponent = addComponent(Camera.self) {

            cameraComponent.scnCamera = camera
        }
        
        GameObject.convertAllChildToGameObjects(self)
        awake()
    }
    
    public required init() {
        
        self.node = SCNNode()
        super.init()
        self.transform = addComponent(monoBehaviourOnly: false, type: Transform.self)
        awake()
    }
    
    public override func destroy() {
        
        super.destroy()
        parent?.removeChild(self)
    }
    
    public func instantiate() -> GameObject {
        
        let cloneNode = node.clone()
        let clone = GameObject(cloneNode)
        
        if let name = name {
            clone.name = name + " Clone"
        }
        
        clone.tag = tag

        return clone
    }
    
    internal func setScene(_ scene: Scene) {
        
        self.scene = scene
        childs.forEach { $0.setScene(scene) }
    }

    public func setActive(_ active: Bool) {
        self.activeSelf = active
    }

    //Update
    
    public override func awake() {

        guard !didAwake
            else { return }

        didAwake = true
        components.forEach { $0.awake() }
        childs.forEach { $0.awake() }
    }
    
    public override func start() {
        
        guard didAwake
            else { return }

        guard !didStart
            else { return }

        didStart = true
        components.forEach { $0.start() }
        childs.forEach { $0.start() }
    }
    
    public override func update() {
        
        guard didAwake
            else { return }

        guard didStart else {
            start()
            return
        }

        components.forEach { $0.update() }
        childs.forEach { $0.update() }
    }
    
    //Component
    
    public override func addComponent<T: Component>(_ type: T.Type) -> T? {
        
        let component = super.addComponent(type)
        component?.gameObject = self
        return component
    }
    
    internal override func addComponent<T: Component>(monoBehaviourOnly: Bool = true, type: T.Type) -> T? {
        
        let component = super.addComponent(monoBehaviourOnly: monoBehaviourOnly, type: type)
        component?.gameObject = self
        return component
    }
    
    public func getComponentInChild<T: Component>(_ type: T.Type) -> T? {
        
        for child in childs {
            
            if let component = child.getComponent(type) {
                return component
            }
            
            if let component = child.getComponentInChild(type) {
                return component
            }
        }
        
        return nil
    }
    
    public func getComponentsInChild<T: Component>(_ type: T.Type) -> [T] {

        return childs.flatMap { (child) -> [T] in
            child.getComponents(type) + child.getComponentsInChild(type)
        }
    }
    
    //Child
    
    public func addToScene(_ scene: Scene) {

        setScene(scene)
        parent = scene.rootGameObject
        
        scene.rootGameObject.addChild(self)
    }
    
    public func addChild(_ child: GameObject) {

        if let scene = scene {
            child.setScene(scene)
        }
        child.parent = self
        
        if childs.index(where: { $0 == child }) == nil {
            
            childs.append(child)
            node.addChildNode(child.node)
        }
    }
    
    public func getChilds() -> [GameObject] {
        
        return childs
    }
    
    public func getChildNodes() -> [SCNNode] {
        
        return node.childNodes
    }
    
    public func getChild(_ index: Int) -> GameObject? {
        
        return childs[index]
    }
    
    public func removeChild(_ child: GameObject) {
        
        if let index = childs.index(where: { $0 == child }) {
            
            if let gameObject = getChild(index) {
                
                gameObject.node.removeFromParentNode()
            }
            
            childs.remove(at: index)
        }
    }
}

