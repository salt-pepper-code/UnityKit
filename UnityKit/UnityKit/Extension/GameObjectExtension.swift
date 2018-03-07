import SceneKit

extension GameObject {
    
    internal static func convertAllChildToGameObjects(_ gameObject: GameObject) {
        
        gameObject.getChildNodes().forEach({ (childNode) in
            
            let child = GameObject(childNode)
            
            if childNode.camera != nil {
                _ = child.addComponent(Camera.self)                
            }
            gameObject.addChild(child)
        })
    }
    
    public static func instantiate(original: GameObject) -> GameObject {

        let gameObject = original.instantiate()
        
        original.scene?.addGameObject(gameObject)
        
        return gameObject
    }
    
    public static func instantiate(original: GameObject, parent: Transform) -> GameObject {
        
        let gameObject = original.instantiate()
        
        parent.gameObject?.addChild(gameObject)
        
        return gameObject
    }
    
    public func setColor(_ color: UIColor, lightingModel: SCNMaterial.LightingModel = .phong) -> GameObject {
        
        renderer?.material = Material(color, lightingModel: lightingModel)
        
        return self
    }
}
