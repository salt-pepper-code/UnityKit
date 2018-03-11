
import UnityKit

class CubeScript: MonoBehaviour {

    override func awake() {

    }
    
    override func start() {

    }
    
    override func update() {
    
        if let gameObject = self.gameObject {
            gameObject.transform.position = Vector3.lerp(from: gameObject.transform.position, to: Vector3(0, 20, 0), time: Time.deltaTime)
        }

        if let touch = Input.getTouch(0) {
            print(touch.deltaPosition)
        }
    }
}
