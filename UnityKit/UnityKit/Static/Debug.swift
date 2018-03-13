
public class Debug {

    public static func displayCollider(_ display: Bool, in scene: Scene? = Scene.sharedInstance) {

        let colliders = Collider.colliderTypes
            .flatMap { (type) -> [Collider] in GameObject.getComponents(type, in: scene) }
            .flatMap { $0 }

        colliders.forEach {
            $0.displayCollider = display
        }
    }
}
