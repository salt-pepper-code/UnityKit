import Foundation

public func destroy(_ gameObject: GameObject) {
    
    Object.destroy(gameObject)
}

open class Object: Identifiable {

    /*!
     @property name
     @abstract Determines the name of the receiver.
     */
    open var name: String?
    
    private(set) internal var components = [Component]()
    internal let uuid: String
    
    public required init() {
        self.uuid = UUID().uuidString
    }

    public func getInstanceID() -> String {
        return uuid
    }

    public class func destroy(_ gameObject: GameObject) {
        gameObject.destroy()
    }
    
    open func destroy() {
        removeAllComponents()
    }
    
    open func awake() {
        
    }
    
    open func start() {
        
    }

    open func preUpdate() {

    }

    internal func internalUpdate() {

    }

    open func update() {
        
    }

    open func fixedUpdate() {

    }

    internal func movedToScene() {

    }
    
    internal func removeAllComponents() {
        components.forEach { $0.remove() }
    }
    
    public func removeComponentsOfType(_ type: Component.Type) {

        while let index = components.firstIndex(where: { $0.self === type }) {
            components[index].remove()
        }
    }
    
    public func removeComponent(_ component: Component) {
        
        if let index = components.firstIndex(where: { $0 == component }) {
            components[index].onDestroy()
            components.remove(at: index)
        }
    }
    
    open func getComponent<T: Component>(_ type: T.Type) -> T? {
        return components.compactMap { $0 as? T }.first
    }
    
    open func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
    
    @discardableResult open func addComponent<T: Component>(_ type: T.Type) -> T {
        return addComponent(external: true, type: type)
    }

    @discardableResult internal func addComponent<T: Component>(external: Bool = true, type: T.Type, gameObject: GameObject? = nil) -> T {
        
        if external && (T.self === Renderer.self || T.self === Transform.self || T.self === MeshFilter.self || T.self === UI.Canvas.self) {
            fatalError("Can't manually add Renderer, Transform, MeshFilter or Canvas")
        }

        return addComponent(T(), gameObject: gameObject)
    }

    private func orderIndex<T: Component>(_ type: T.Type) -> Int {

        if type.self === Transform.self { return 0 }
        if type.self === Camera.self { return 1 }
        if type.self === Light.self { return 1 } 
        if type.self === MeshFilter.self { return 1 }
        if type.self === Renderer.self { return 2 }
        if type.self === Rigidbody.self { return 3 }
        if type.self === Collider.self { return 4 }
        if type.self === BoxCollider.self { return 4 }
        if type.self === PlaneCollider.self { return 4 }
        if type.self === MeshCollider.self { return 4 }
        if type.self === Vehicle.self { return 5 }
        return 6
    }

    @discardableResult internal func addComponent<T: Component>(_ component: T, gameObject: GameObject? = nil) -> T {

        components.append(component)
        components.sort { orderIndex(type(of: $0)) <= orderIndex(type(of: $1)) }
        component.gameObject = gameObject
        component.awake()

        if let behaviour = component as? Behaviour {
            behaviour.enabled = true
        }

        return component
    }
}
