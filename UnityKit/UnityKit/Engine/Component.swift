import Foundation

open class Component: Object {

    internal(set) public weak var gameObject: GameObject?
    
    public var transform: Transform? {
        get {
            return gameObject?.transform
        }
    }
    
    public required init() {
        super.init()
    }
    
    deinit {
        onDestroy()
    }
        
    open override func destroy() {
        
        super.destroy()
        gameObject?.removeComponent(self)
    }
    
    open func onDestroy() {
        
    }
    
    public func remove() {
        gameObject?.removeComponent(self)
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
