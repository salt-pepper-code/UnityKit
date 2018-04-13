import Foundation
import SceneKit

public class GameObject: Object {
    internal var task: DispatchWorkItem?

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
            children.forEach { $0.layer = newValue }
        }
    }

    public var tag: Tag = .untagged

    public var node: SCNNode

    /*!
     @property ignoreUpdates
     @abstract Specifies if the receiver's will cascade the update calls.
     @discussion By manually changing this value can improve considerably performance by skipping update calls.
     */
    public var ignoreUpdates = true {
        didSet {
            if !ignoreUpdates {
                parent?.ignoreUpdates = false
            }
        }
    }

    private(set) public var transform: Transform!
    private(set) public var renderer: Renderer?

    private(set) internal var children = [GameObject]()

    private(set) public weak var parent: GameObject?
    private(set) public weak var scene: Scene? {
        didSet {
            guard oldValue != scene
                else { return }

            if let parent = parent, let rootGameObject = oldValue?.rootGameObject, parent == rootGameObject {
                scene?.rootGameObject.addChild(self)
            }

            movedToScene()
        }
    }

    private var didAwake: Bool = false
    private var didStart: Bool = false
    private var waitNextUpdate: Bool = true {
        didSet {
            children.forEach { $0.waitNextUpdate = waitNextUpdate }
        }
    }

    public var activeInHierarchy: Bool {
        if let parent = parent {
            return activeSelf && parent.activeInHierarchy
        }
        return activeSelf
    }

    private(set) public var activeSelf: Bool {
        get {
            return !node.isHidden
        }
        set {
            node.isHidden = !newValue

            for component in components {
                guard let behaviour = component as? Behaviour
                    else { continue }

                behaviour.enabled = newValue
            }
        }
    }

    public var enabled: Bool {
        get {
            return activeSelf
        }
        set {
            activeSelf = newValue
        }
    }

    public var boundingBox: BoundingBox {
        return node.boundingBox
    }

    public var boundingSphere: BoundingSphere {
        return node.boundingSphere
    }

    public convenience init?(fileName: String, nodeName: String?, bundle: Bundle = Bundle.main) {
        guard let modelUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
            else { return nil }

        self.init(modelUrl: modelUrl, nodeName: nodeName)
    }

    public convenience init?(modelPath: String, nodeName: String?, bundle: Bundle = Bundle.main) {
        guard let modelUrl = bundle.url(forResource: modelPath, withExtension: nil)
            else { return nil }

        self.init(modelUrl: modelUrl, nodeName: nodeName)
    }

    public convenience init?(modelUrl: URL, nodeName: String?) {
        guard let referenceNode = SCNReferenceNode(url: modelUrl)
            else { return nil }

        referenceNode.load()

        if let nodeName = nodeName {
            guard let node = referenceNode.childNodes.filter({ $0.name == nodeName }).first
                else { return nil }

            self.init(node)
        } else {
            self.init(referenceNode)
        }
    }

    public convenience init(name: String) {
        let node = SCNNode()
        node.name = name
        self.init(node)
    }

    public init(_ node: SCNNode) {
        self.node = node
        super.init()
        initialize()
        awake()
    }

    internal func initialize() {
        self.name = node.name ?? "No name"
        self.layer = .`default`
        self.transform = addComponent(external: false, type: Transform.self)

        if let geometry = node.geometry {
            let meshFilter = addComponent(external: false, type: MeshFilter.self)
            meshFilter.mesh = Mesh(geometry)

            self.renderer = addComponent(external: false, type: Renderer.self)

            self.renderer?.materials = geometry.materials.map { Material($0) }
        }

        if let camera = node.camera {
            addComponent(external: false, type: Camera.self).scnCamera = camera
        }

        if let light = node.light {
            addComponent(external: false, type: Light.self).scnLight = light
        }

        GameObject.convertAllChildToGameObjects(self)
    }

    /// Create a new instance
    public required init() {
        self.node = SCNNode()
        super.init()
        self.transform = addComponent(external: false, type: Transform.self)
        awake()
    }

    public override func destroy() {
        super.destroy()
        parent?.removeChild(self)
    }

    public func instantiate() -> GameObject {
        let cloneNode = node.deepClone()
        let clone = GameObject(cloneNode)

        if let name = name {
            clone.name = "\(name) Clone"
        }

        clone.tag = tag
        clone.layer = layer

        components.forEach {
            if let component = $0 as? Component & Instantiable {
                clone.addComponent(component.instantiate(gameObject: clone), gameObject: clone)
            }
        }
        return clone
    }

    internal func shouldIgnoreUpdates() -> Bool {
        var ignore = true
        for component in components {
            if !component.ignoreUpdates {
                ignore = false
                break
            }
        }
        return ignore
    }

    internal func setScene(_ scene: Scene) {
        self.scene = scene
        children.forEach { $0.setScene(scene) }
    }

    internal override func movedToScene() {
        components.forEach { $0.movedToScene() }
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
        children.forEach { $0.awake() }
    }

    public override func start() {
        guard didAwake,
            !didStart,
            activeSelf
            else { return }

        guard !waitNextUpdate else {
            waitNextUpdate = false
            return
        }

        didStart = true
        components.forEach { $0.start() }
        children.forEach { $0.start() }
        setActive(true)
    }

    override func internalUpdate() {
        guard didAwake,
            didStart,
            activeSelf
            else { return }

        components
            .compactMap { $0 as? MonoBehaviour }
            .filter { $0.enabled }
            .forEach { $0.internalUpdate() }

        children
            .filter { !$0.ignoreUpdates }
            .forEach { $0.internalUpdate() }
    }

    public override func preUpdate() {
        guard didAwake,
            didStart,
            activeSelf
            else { return }

        components
            .filter {
                if !$0.implementsPreUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.preUpdate() }

        children
            .filter { !$0.ignoreUpdates }
            .forEach { $0.preUpdate() }
    }

    public override func update() {
        guard didAwake,
            activeSelf
            else { return }

        guard didStart else {
            start()
            return
        }

        components
            .filter {
                if !$0.implementsUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.update() }

        children
            .filter { !$0.ignoreUpdates || !$0.didStart }
            .forEach { $0.update() }
    }

    public override func fixedUpdate() {
        guard didAwake,
            didStart,
            activeSelf
            else { return }

        components
            .filter {
                if !$0.implementsFixedUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.fixedUpdate() }

        children
            .filter { !$0.ignoreUpdates }
            .forEach { $0.fixedUpdate() }
    }

    public func removeFromParent() {
        parent?.removeChild(self)
    }

    // Component

    @discardableResult internal override func addComponent<T: Component>(_ component: T, gameObject: GameObject?) -> T {
        return super.addComponent(component, gameObject: gameObject)
    }

    @discardableResult public override func addComponent<T: Component>(_ type: T.Type) -> T {
        self.ignoreUpdates = shouldIgnoreUpdates()
        return super.addComponent(external: true, type: type, gameObject: self)
    }

    @discardableResult internal override func addComponent<T: Component>(external: Bool = true, type: T.Type, gameObject: GameObject? = nil) -> T {
        return super.addComponent(external: external, type: type, gameObject: gameObject ?? self)
    }

    public func getComponentInChild<T: Component>(_ type: T.Type) -> T? {
        for child in children {
            if let component = child.getComponent(type) {
                return component
            }
        }
        for child in children {
            if let component = child.getComponentInChild(type) {
                return component
            }
        }
        return nil
    }

    public func getComponentsInChild<T: Component>(_ type: T.Type) -> [T] {
        return children.flatMap { (child) -> [T] in
            child.getComponents(type) + child.getComponentsInChild(type)
        }
    }

    // Child

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
        if !child.ignoreUpdates {
            self.ignoreUpdates = false
        }
        if children.first(where: { $0 == child }) == nil {
            children.append(child)
            if child.node.parent != node {
                node.addChildNode(child.node)
            }
        }
    }

    public func getChildren() -> [GameObject] {
        return children
    }

    internal func getChildNodes() -> [SCNNode] {
        return node.childNodes
    }

    public func getChild(_ index: Int) -> GameObject? {
        return children[index]
    }

    public func removeChild(_ child: GameObject) {
        if let index = children.firstIndex(where: { $0 == child }) {
            if let gameObject = getChild(index) {
                gameObject.node.removeFromParentNode()
            }
            children.remove(at: index)
        }
    }
}
