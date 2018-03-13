
public class Debug {

    public static func displayCollider(_ display: Bool, in scene: Scene? = Scene.sharedInstance) {

        var colliders = [Collider]()
        colliders.appendContentsOf(newElements: GameObject.getComponents(BoxCollider.self, in: scene))
        colliders.appendContentsOf(newElements: GameObject.getComponents(PlaneCollider.self, in: scene))
        colliders.forEach {
            $0.displayCollider = display
        }
    }
}
