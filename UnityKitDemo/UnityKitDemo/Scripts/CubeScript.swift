import UnityKit

class CubeScript: MonoBehaviour {

    override func awake() {

    }
    
    override func start() {
        
        if let gameObject = self.gameObject {
            
            _ = UnityTween.move(gameObject, to: Vector3(0, 10, 0), duration: 4).set(timingMode: .cubicInOut)
        }
    }
    
    override func update() {
    
        if let gameObject = self.gameObject {
            
            gameObject.transform.position = Vector3.lerp(gameObject.transform.position, Vector3(0, 20, 0), Time.deltaTime)
        }
    }
}
