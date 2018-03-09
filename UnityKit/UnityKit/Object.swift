import Foundation

public func destroy(_ gameObject: GameObject) {
    
    Object.destroy(gameObject)
}

protocol Identifiable: Equatable {
    var uuid: String { get }
}

open class Object: Identifiable {

    /*!
     @property name
     @abstract Determines the name of the receiver.
     */
    open var name: String?
    
    private(set) internal var components = [Component]()
    public let uuid: String
    
    public required init() {
        self.uuid = UUID().uuidString
    }

    public static func ==(lhs: Object, rhs: Object) -> Bool {
        return lhs.uuid == rhs.uuid
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

    open func update() {
        
    }
    
    internal func removeAllComponents() {
        
        components.removeAll()
    }
    
    public func removeComponentsOfType(_ type: Component.Type) {
                
        while let index = components.index(where: { $0.self === type }) {
            components.remove(at: index)
        }
    }
    
    public func removeComponent(_ component: Component) {
        
        if let index = components.index(where: { $0 == component }) {
            components.remove(at: index)
        }
    }
    
    open func getComponent<T: Component>(_ type: T.Type) -> T? {
        return components.flatMap { $0 as? T }.first
    }
    
    open func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return components.flatMap { $0 as? T }
    }
    
    open func addComponent<T: Component>(_ type: T.Type) -> T? {
        return addComponent(monoBehaviourOnly: true, type: type)
    }
    
    internal func addComponent<T: Component>(monoBehaviourOnly: Bool = true, type: T.Type) -> T? {
        
        if monoBehaviourOnly && (T.self === Renderer.self || T.self === Transform.self) {
            return nil
        }
        
        let component = T()
        components.append(component)
        component.awake()

        return component
    }
}
