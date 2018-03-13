
import UnityKit
import SceneKit

class GameViewController: UIViewController {

    override func loadView() {
        self.view = View.makeView(sceneName: "Scene.scn")
    }

    var sceneView: View {
        return self.view as! View
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        guard let scene = sceneView.sceneHolder,
            let tank = GameObject(fileName: "Tank.scn", nodeName: "Tank")
            else { return }

        scene.addGameObject(tank)
        _ = tank.addComponent(RigidBody.self)?.set(isKinematic: false).set(useGravity: true)
        _ = tank.addComponent(BoxCollider.self)

        tank.transform.position = Vector3(0, 10, 0)

        guard let ground = GameObject.find(.name(.exact("GroundPlane")))
            else { return }

        _ = ground.addComponent(RigidBody.self)?.set(isKinematic: true).set(useGravity: false)
        _ = ground.addComponent(PlaneCollider.self)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
