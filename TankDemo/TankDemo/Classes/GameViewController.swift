
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

        guard let _ = sceneView.sceneHolder,
            let camera = Camera.main()
            else { return }

        camera.transform?.position = Vector3(43, 41, -23)
        camera.transform?.localEulerAngles = Vector3(-40, 120, 0)

        print("boom")
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
