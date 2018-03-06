import Foundation
import SceneKit

public final class GameObject: Object {

    public override var name: String? {
        
        didSet {
            if self.node.name != self.name {
                self.node.name = self.name
            }
        }
    }
    public var tag: Tag = .untagged
    public let node: SCNNode
    private(set) public var transform: Transform!
    private(set) public var renderer: Renderer?
    
    private(set) internal var childs = [GameObject]()
    
    private(set) public weak var parent: GameObject?
    private(set) public weak var scene: Scene?
    
    private var didAwake: Bool = false
    private var didStart: Bool = false
    
    public var layer: Layer {
        
        get {
            return Layer(rawValue: self.node.categoryBitMask)
        }
        set {
            self.node.categoryBitMask = newValue.rawValue
            self.childs.forEach { $0.layer = newValue }
        }
    }
    
    public convenience init?(modelName: String, withExtension: String? = nil, bundle: Bundle = Bundle.main) {
        
        guard let modelUrl = searchPathForResource(forResource: modelName, withExtension: withExtension, bundle: bundle)
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
    
    public init(_ node: SCNNode) {
        
        self.node = node
        
        super.init()
        
        self.name = node.name
        self.layer = Layer(rawValue: node.categoryBitMask)
        
        self.transform = self.addComponent(monoBehaviourOnly: false, type: Transform.self)
        
        if node.geometry != nil {
            
            self.renderer = self.addComponent(monoBehaviourOnly: false, type: Renderer.self)
            
            for material in node.geometry!.materials {
            
                self.renderer?.materials.append(Material(material))
            }
        }
        
        GameObject.convertAllChildToGameObjects(self)
        
        self.awake()
    }
    
    public required init() {
        
        self.node = SCNNode()
        
        super.init()
        
        self.transform = self.addComponent(monoBehaviourOnly: false, type: Transform.self)
        
        self.awake()
    }
    
    public override func destroy() {
        
        super.destroy()
        
        self.parent?.removeChild(self)
    }
    
    public func instantiate() -> GameObject {
        
        let cloneNode = self.node.clone()
        let clone = GameObject(cloneNode)
        
        if let name = self.name {
            
            clone.name = name + " Clone"
        }
        
        clone.tag = self.tag

        return clone
    }
    
    public func setScene(_ scene: Scene) {
        
        self.scene = scene
        
        self.childs.forEach { (child) in
            
            child.setScene(scene)
        }
    }
    
    //Update
    
    public override func awake() {
        
        if !self.didAwake {
            
            self.didAwake = true
            
            self.components.forEach { (component) in component.awake() }
            self.childs.forEach { (child) in child.awake() }
        }
    }
    
    public override func start() {
        
        if !self.didAwake {
            
            return
        }
        
        if !self.didStart {
            
            self.didStart = true
            
            self.components.forEach { (component) in component.start() }
            self.childs.forEach { (child) in child.start() }
        }
    }
    
    public override func update() {
        
        if !self.didAwake {
            
            return
        }
        
        if !self.didStart {
            
            self.start()
        }
        
        self.components.forEach { (component) in component.update() }
        self.childs.forEach { (child) in child.update() }
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
        
        for child in self.childs {
            
            if let component = child.getComponent(type) {
                
                return component
            }
            
            if let component = child.getComponentInChild(type) {
                
                return component
            }
        }
        
        return nil
    }
    
    public func getComponentsInChild<T: Component>(_ type: T.Type) -> [T]? {
        
        var storedComponents = [T]()
        
        for child in self.childs {
            
            if let components = child.getComponents(type) {
                
                storedComponents.append(contentsOf: components)
            }
            
            if let components = child.getComponentsInChild(type) {
                
                storedComponents.append(contentsOf: components)
            }
        }
        
        return storedComponents.count == 0 ? nil : storedComponents
    }
    
    //Child
    
    public func addToScene(_ scene: Scene) {
        
        self.scene = scene
        self.parent = scene.rootGameObject
        
        self.setScene(scene)
        
        scene.rootGameObject.addChild(self)
    }
    
    public func addChild(_ child: GameObject) {
        
        child.scene = self.scene
        child.parent = self
        
        if self.childs.index(where: { $0 === child }) == nil {
            
            self.childs.append(child)
            
            self.node.addChildNode(child.node)
        }
    }
    
    public func getChilds() -> [GameObject] {
        
        return self.childs
    }
    
    public func getChildNodes() -> [SCNNode] {
        
        return self.node.childNodes
    }
    
    public func getChild(_ index: Int) -> GameObject? {
        
        return self.childs[index]
    }
    
    public func removeChild(_ child: GameObject) {
        
        if let index = self.childs.index(where: { $0 === child }) {
            
            if let gameObject = getChild(index) {
                
                gameObject.node.removeFromParentNode()
            }
            
            self.childs.remove(at: index)
        }
    }
}

