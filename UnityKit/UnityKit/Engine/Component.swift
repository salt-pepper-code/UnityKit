import Foundation

open class Component: Object {

    internal(set) public weak var gameObject: GameObject?
    internal var implementsPreUpdate = true
    internal var implementsUpdate = true
    internal var implementsFixedUpdate = true
    
    public var transform: Transform? {
        get {
            return gameObject?.transform
        }
    }
    
    public required init() {
        super.init()
    }
    
    open override func preUpdate() {
        implementsPreUpdate = false
    }
    
    open override func update() {
        implementsUpdate = false
    }
    
    open override func fixedUpdate() {
        implementsFixedUpdate = false
    }
    
    open override func destroy() {
        gameObject?.removeComponent(self)
    }
    
    open func onDestroy() {
        
    }
    
    public func remove() {
        gameObject?.removeComponent(self)
    }

    public override func removeComponent(_ component: Component) {
        gameObject?.removeComponent(component)
    }

    public override func removeComponentsOfType(_ type: Component.Type) {
        gameObject?.removeComponentsOfType(type)
    }

    open override func getComponent<T: Component>(_ type: T.Type) -> T? {
        return gameObject?.getComponent(type)
    }
    
    open override func getComponents<T: Component>(_ type: T.Type) -> [T] {
        return gameObject?.getComponents(type) ?? []
    }
    
    @discardableResult open override func addComponent<T: Component>(_ type: T.Type) -> T? {
        return gameObject?.addComponent(type)
    }
}
