
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
        _ = tank.addComponent(BoxCollider.self)

        guard let plane = GameObject.find(.name(.exact("GroundPlane")))
            else { return }

        _ = plane.addComponent(PlaneCollider.self)

        Debug.displayCollider(true)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
