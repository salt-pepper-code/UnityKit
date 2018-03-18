
import UnityKit
import SceneKit

class GameViewController: UIViewController {

    override func loadView() {
        self.view = View.makeView(sceneName: "Scene.scn",
                                  extraLayers: ["Shell"])
    }

    var sceneView: View {
        return self.view as! View
    }

    override func viewDidLoad() {

        super.viewDidLoad()
        setupScene()
    }

    func setupScene() {

        guard let scene = sceneView.sceneHolder,
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

        // Collider Setup
        guard let militaries = GameObject.find(.name(.exact("Military"))),
            let oilFields = GameObject.find(.name(.exact("OilField"))),
            let rocks = GameObject.find(.name(.exact("Rocks"))),
            let boundaries = GameObject.find(.name(.exact("Boundaries"))),
            let ground = GameObject.find(.name(.exact("GroundPlane"))),
            let helipad = GameObject.find(.name(.exact("Helipad")))
            else { return }

        let gameObjects = militaries.getChildren() + oilFields.getChildren() + boundaries.getChildren()

        gameObjects.forEach {
            $0.addComponent(Rigidbody.self)?.set(useGravity: false)
            $0.addComponent(MeshCollider.self)
        }

        rocks.getChildren().forEach {
            $0.addComponent(Rigidbody.self)?.set(useGravity: false)
            $0.addComponent(BoxCollider.self)
        }

        ground.addComponent(Rigidbody.self)?.set(useGravity: false)
        ground.addComponent(PlaneCollider.self)

        helipad.addComponent(Rigidbody.self)?.set(useGravity: false)
        helipad.addComponent(BoxCollider.self)

        // Tank Setup
        scene.addGameObject(tank)
        tank.addComponent(Rigidbody.self)?.set(isKinematic: false)
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
