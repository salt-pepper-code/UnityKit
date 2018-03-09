
import UnityKit

class ShipScript: MonoBehaviour {

    override func start() {
        
        if let gameObject = self.gameObject {
            
            gameObject.transform.position.x = 10

            let move = Action.move(to: Vector3(gameObject.transform.position.x, gameObject.transform.position.y, 80), duration: 4).set(ease: .quadInOut)
            gameObject.runAction(move)
        }
    }
}
