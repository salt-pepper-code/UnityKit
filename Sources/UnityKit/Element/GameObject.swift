import Foundation
import SceneKit

public class GameObject: Object {
    var task: DispatchWorkItem?

    override public var name: String? {
        didSet {
            self.node.name = self.name
        }
    }

    public var layer: Layer {
        get {
            return Layer(rawValue: self.node.categoryBitMask)
        }
        set {
            guard self.node.camera == nil,
                  self.node.light == nil
            else { return }

            self.node.categoryBitMask = newValue.rawValue
            let childrenCopy = self.children // Thread-safe read
            childrenCopy.forEach { $0.layer = newValue }
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
            if !self.ignoreUpdates {
                self.parent?.ignoreUpdates = false
            }
        }
    }

    public private(set) var transform: Transform!
    public private(set) var renderer: Renderer?

    private var _children = [GameObject]()
    private let childrenQueue = DispatchQueue(
        label: "com.unitykit.gameobject.children",
        qos: .userInitiated,
        attributes: .concurrent
    )

    var children: [GameObject] {
        get {
            self.childrenQueue.sync { self._children }
        }
        set {
            self.childrenQueue.sync(flags: .barrier) { [weak self] in
                self?._children = newValue
            }
        }
    }

    public private(set) weak var parent: GameObject?
    public private(set) weak var scene: Scene? {
        didSet {
            guard oldValue != self.scene
            else { return }

            if let parent, let rootGameObject = oldValue?.rootGameObject, parent == rootGameObject {
                self.scene?.rootGameObject.addChild(self)
            }

            self.movedToScene()
        }
    }

    private var didAwake: Bool = false
    private var didStart: Bool = false
    private var waitNextUpdate: Bool = true {
        didSet {
            let childrenCopy = self.children // Thread-safe read
            childrenCopy.forEach { $0.waitNextUpdate = self.waitNextUpdate }
        }
    }

    public var activeInHierarchy: Bool {
        if let parent {
            return self.activeSelf && parent.activeInHierarchy
        }
        return self.activeSelf
    }

    public private(set) var activeSelf: Bool {
        get {
            return !self.node.isHidden
        }
        set {
            self.node.isHidden = !newValue

            for component in components {
                guard let behaviour = component as? Behaviour
                else { continue }

                behaviour.enabled = newValue
            }
        }
    }

    public var enabled: Bool {
        get {
            return self.activeSelf
        }
        set {
            self.activeSelf = newValue
        }
    }

    public var boundingBox: BoundingBox {
        return self.node.boundingBox
    }

    public var boundingSphere: BoundingSphere {
        return self.node.boundingSphere
    }

    public convenience init?(
        fileName: String,
        nodeName: String?,
        bundle: Bundle = Bundle.main
    ) {
        guard let modelUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
        else { return nil }

        self.init(modelUrl: modelUrl, nodeName: nodeName)
    }

    public convenience init?(
        modelPath: String,
        nodeName: String?,
        bundle: Bundle = Bundle.main
    ) {
        guard let modelUrl = bundle.url(forResource: modelPath, withExtension: nil)
        else { return nil }

        self.init(modelUrl: modelUrl, nodeName: nodeName)
    }

    public convenience init?(modelUrl: URL, nodeName: String?) {
        guard let referenceNode = SCNReferenceNode(url: modelUrl)
        else { return nil }

        referenceNode.load()

        if let nodeName {
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
        self.initialize()
        Debug.debug("GameObject[\(self.name ?? "unnamed")].init(_:)")
        self.awake()
    }

    func initialize() {
        self.name = self.node.name ?? "No name"
        self.layer = .default
        self.transform = self.addComponent(external: false, type: Transform.self)

        if let geometry = node.geometry {
            let meshFilter = self.addComponent(external: false, type: MeshFilter.self)
            meshFilter.mesh = Mesh(geometry)

            self.renderer = self.addComponent(external: false, type: Renderer.self)

            self.renderer?.materials = geometry.materials.map { Material($0) }
        }

        if let camera = node.camera {
            self.addComponent(external: false, type: Camera.self).scnCamera = camera
        }

        if let light = node.light {
            self.addComponent(external: false, type: Light.self).scnLight = light
        }

        GameObject.convertAllChildToGameObjects(self)
    }

    /// Create a new instance
    public required init() {
        self.node = SCNNode()
        super.init()
        self.transform = self.addComponent(external: false, type: Transform.self)
        Debug.debug("GameObject[\(self.name ?? "unnamed")].init()")
        self.awake()
    }

    override public func destroy() {
        super.destroy()
        self.parent?.removeChild(self)
    }

    public func instantiate() -> GameObject {
        let cloneNode = self.node.deepClone()
        let clone = GameObject(cloneNode)

        if let name {
            clone.name = "\(name) Clone"
        }

        clone.tag = self.tag
        clone.layer = self.layer

        for item in components {
            if let component = item as? Component & Instantiable {
                clone.addComponent(component.instantiate(gameObject: clone), gameObject: clone)
            }
        }
        return clone
    }

    func shouldIgnoreUpdates() -> Bool {
        return components.first(where: { !$0.ignoreUpdates }) == nil
    }

    func setScene(_ scene: Scene) {
        self.scene = scene
        let childrenCopy = self.children // Thread-safe read
        childrenCopy.forEach { $0.setScene(scene) }
    }

    override func movedToScene() {
        components.forEach { $0.movedToScene() }
    }

    public func setActive(_ active: Bool) {
        self.activeSelf = active
    }

    //Update

    override public func awake() {
        guard !self.didAwake
        else { return }

        self.didAwake = true
        components.forEach { $0.awake() }
        let childrenCopy = self.children // Thread-safe read
        childrenCopy.forEach { $0.awake() }
    }

    override public func start() {
        guard self.didAwake,
              !self.didStart,
              self.activeSelf
        else { return }

        guard !self.waitNextUpdate else {
            self.waitNextUpdate = false
            return
        }

        self.didStart = true
        components.forEach { $0.start() }
        let childrenCopy = self.children // Thread-safe read
        childrenCopy.forEach { $0.start() }
        self.setActive(true)
    }

    override func internalUpdate() {
        guard self.didAwake,
              self.didStart,
              self.activeSelf
        else { return }

        components
            .compactMap { $0 as? MonoBehaviour }
            .filter(\.enabled)
            .forEach { $0.internalUpdate() }

        let childrenCopy = self.children // Thread-safe read
        childrenCopy
            .filter { !$0.ignoreUpdates }
            .forEach { $0.internalUpdate() }
    }

    override public func preUpdate() {
        guard self.didAwake,
              self.didStart,
              self.activeSelf
        else { return }

        components
            .filter {
                if !$0.implementsPreUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.preUpdate() }

        let childrenCopy = self.children // Thread-safe read
        childrenCopy
            .filter { !$0.ignoreUpdates }
            .forEach { $0.preUpdate() }
    }

    override public func update() {
        guard self.didAwake,
              self.activeSelf
        else { return }

        guard self.didStart else {
            self.start()
            return
        }

        components
            .filter {
                if !$0.implementsUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.update() }

        let childrenCopy = self.children // Thread-safe read
        childrenCopy
            .filter { !$0.ignoreUpdates || !$0.didStart }
            .forEach { $0.update() }
    }

    override public func fixedUpdate() {
        guard self.didAwake,
              self.didStart,
              self.activeSelf
        else { return }

        components
            .filter {
                if !$0.implementsFixedUpdate { return false }
                if let behaviour = $0 as? Behaviour { return behaviour.enabled }
                return true
            }
            .forEach { $0.fixedUpdate() }

        let childrenCopy = self.children // Thread-safe read
        childrenCopy
            .filter { !$0.ignoreUpdates }
            .forEach { $0.fixedUpdate() }
    }

    public func removeFromParent() {
        self.parent?.removeChild(self)
    }

    // Component

    @discardableResult override func addComponent<T: Component>(
        _ component: T,
        gameObject: GameObject?
    ) -> T {
        let result = super.addComponent(component, gameObject: gameObject)

        if self.didAwake, self.activeSelf {
            component.awake()
        }

        // If GameObject has already started, call start() on the new component
        if self.didStart, self.activeSelf {
            component.start()
        }

        return result
    }

    @discardableResult override public func addComponent<T: Component>(_ type: T.Type) -> T {
        let component = super.addComponent(external: true, type: type, gameObject: self)
        self.ignoreUpdates = self.shouldIgnoreUpdates()
        return component
    }

    @discardableResult override func addComponent<T: Component>(
        external: Bool = true,
        type: T.Type,
        gameObject: GameObject? = nil
    ) -> T {
        return super.addComponent(external: external, type: type, gameObject: gameObject ?? self)
    }

    public func getComponentInChild<T: Component>(_ type: T.Type) -> T? {
        for child in self.children {
            if let component = child.getComponent(type) {
                return component
            }
        }
        for child in self.children {
            if let component = child.getComponentInChild(type) {
                return component
            }
        }
        return nil
    }

    public func getComponentsInChild<T: Component>(_ type: T.Type) -> [T] {
        return self.children.flatMap { child -> [T] in
            child.getComponents(type) + child.getComponentsInChild(type)
        }
    }

    // Child

    public func addToScene(_ scene: Scene) {
        self.setScene(scene)
        self.parent = scene.rootGameObject

        scene.rootGameObject.addChild(self)
    }

    public func addChild(_ child: GameObject) {
        if let scene {
            child.setScene(scene)
        }
        child.parent = self
        if !child.ignoreUpdates {
            self.ignoreUpdates = false
        }

        self.childrenQueue.sync(flags: .barrier) {
            if self._children.first(where: { $0 == child }) == nil {
                self._children.append(child)
            }
        }

        if child.node.parent != self.node {
            self.node.addChildNode(child.node)
        }
    }

    public func getChildren() -> [GameObject] {
        return self.childrenQueue.sync { self._children }
    }

    func getChildNodes() -> [SCNNode] {
        return self.node.childNodes
    }

    public func getChild(_ index: Int) -> GameObject? {
        return self.childrenQueue.sync {
            guard index < self._children.count else { return nil }
            return self._children[index]
        }
    }

    public func removeChild(_ child: GameObject) {
        self.childrenQueue.sync(flags: .barrier) {
            if let index = _children.firstIndex(where: { $0 == child }) {
                let gameObject = self._children[index]
                gameObject.node.removeFromParentNode()
                self._children.remove(at: index)
            }
        }
    }
}
