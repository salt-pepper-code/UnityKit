import UnityKit
import MKTween

class ShipScript: MonoBehaviour {

    override func start() {
        
        if let gameObject = self.gameObject {
            
            gameObject.transform.position.x = 10
            
            //_ = Tween.move(gameObject, to: Vector3(gameObject.transform.position.x, gameObject.transform.position.y, 80), duration: 4).set(timingMode: .cubicInOut)
        }
    }
}
