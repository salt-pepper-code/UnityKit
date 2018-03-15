
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
            let ground = GameObject.find(.name(.exact("GroundPlane"))),
            let tank = GameObject(fileName: "Tank.scn", nodeName: "Tank")
            else { return }

        // Controls Setup
        let controls = GameObject(name: "Controls")
        guard let joystick = controls.addComponent(Joystick.self),
            let fireButton = controls.addComponent(FireButton.self)
            else { return }

        scene.addGameObject(controls)
        setup(joystick: joystick)
        setup(fireButton: fireButton)

        // Ground Setup
        ground.addComponent(Rigidbody.self)?.set(isKinematic: true).set(useGravity: false)
        ground.addComponent(PlaneCollider.self)

        // Tank Setup
        scene.addGameObject(tank)
        tank.addComponent(Rigidbody.self)?.set(isKinematic: false).set(useGravity: true)
        tank.addComponent(BoxCollider.self)
        tank.addComponent(TankMovement.self)
        tank.addComponent(TankShooting.self)
    }

    func setup(joystick: Joystick) {

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
    }

    func setup(fireButton: FireButton) {

        let size: CGFloat = 60
        fireButton.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fireButton.view)
        NSLayoutConstraint.activate([
            fireButton.view.widthAnchor.constraint(equalToConstant: size),
            fireButton.view.heightAnchor.constraint(equalToConstant: size),
            fireButton.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            fireButton.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30)
            ])

        fireButton.baseAlpha = 1
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
