
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

        let joystickGameObject = GameObject(name: "Joystick")
        guard let joystick = joystickGameObject.addComponent(Joystick.self)
            else { return }

        scene.addGameObject(joystickGameObject)

        let size: CGFloat = 60
        joystick.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(joystick.view)
        NSLayoutConstraint.activate([
            joystick.view.widthAnchor.constraint(equalToConstant: size),
            joystick.view.heightAnchor.constraint(equalToConstant: size),
            joystick.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            joystick.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
            ])

        joystick.baseAlpha = 0.5
        joystick.handleTintColor = .green

        scene.addGameObject(tank)
        _ = tank.addComponent(RigidBody.self)?.set(isKinematic: false).set(useGravity: true)
        _ = tank.addComponent(BoxCollider.self)
        _ = tank.addComponent(TankMovement.self)

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
