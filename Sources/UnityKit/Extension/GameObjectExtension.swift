import SceneKit

public extension GameObject {
    internal static func convertAllChildToGameObjects(_ gameObject: GameObject) {
        gameObject.layer = .default
        for getChildNode in gameObject.getChildNodes() {
            gameObject.addChild(GameObject(getChildNode))
        }
    }

    static func instantiate(original: GameObject, addToScene: Bool = true) -> GameObject {
        let gameObject = original.instantiate()

        if addToScene {
            let scene = original.scene ?? Scene.shared
            scene?.addGameObject(gameObject)
        }

        return gameObject
    }

    static func instantiate(original: GameObject, parent: Transform) -> GameObject {
        let gameObject = original.instantiate()

        parent.gameObject?.addChild(gameObject)

        return gameObject
    }

    func setColor(_ color: Color, lightingModel: SCNMaterial.LightingModel = .phong) -> GameObject {
        renderer?.material = Material(color, lightingModel: lightingModel)

        return self
    }

    func setOpacity(_ opacity: Float, lightingModel: SCNMaterial.LightingModel = .phong) -> GameObject {
        node.opacity = opacity.toCGFloat()

        return self
    }
}
