import UnityKit

class CubeScript: MonoBehaviour {

    override func awake() {

    }
    
    override func start() {

    }
    
    override func update() {
    
        if let gameObject = self.gameObject {

            let to = Vector3(0, 20, 0)
            
            if to != gameObject.transform.position {
                gameObject.transform.position = Vector3.lerp(from: gameObject.transform.position, to: to, time: Time.deltaTime)
            }
        }
    }
}
