import UnityKit
import SceneKit

class GameViewController: UIViewController {
    override func loadView() {
        self.view = UI.View.makeView(sceneName: "Scene.scn", options: UI.View.Options(showsStatistics: true))
    }

    var sceneView: UI.View {
        return self.view as? UI.View ?? UI.View(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Debug.set(enable: .all)
        setupScene()
    }

    func setupScene() {
        guard let scene = sceneView.sceneHolder
            else { return }

        // Controls Setup
        let controls = GameObject(name: "Controls")
        let joystick = controls.addComponent(Joystick.self)
        let fireButton = controls.addComponent(FireButton.self)

        scene.addGameObject(controls)
        setup(joystick: joystick)
        setup(fireButton: fireButton)

        // Physics Setup
        // Look for 3d models within the scene by they respective names in the file.
        let militaries = GameObject.find(.name(.exact("Military")))?.getChildren() ?? []
        let oilFields = GameObject.find(.name(.exact("OilField")))?.getChildren() ?? []
        let rocks = GameObject.find(.name(.exact("Rocks")))?.getChildren() ?? []
        let boundaries = GameObject.find(.name(.exact("Boundaries")))?.getChildren() ?? []
        guard let ground = GameObject.find(.name(.exact("GroundPlane"))),
            let helipad = GameObject.find(.name(.exact("Helipad")))
            else { return }

        let environments = militaries + oilFields + boundaries + rocks + [helipad]

        // Layers
        // Settings layer tag to easily identify them for collisions.
        environments.forEach {
            $0.layer = .environment
        }
        ground.layer = .ground

        // Rigidbodies
        // Adding rigid bodies to environments with static so they won't move after a collision and be affected by gravity.
        (environments + [ground]).forEach {
            $0.addComponent(Rigidbody.self)
                .configure {
                    $0.useGravity = false
                    $0.isStatic = true
                }
        }

        // Colliders
        environments.forEach {
            $0.addComponent(MeshCollider.self)
                .configure {
                    // This will define what will the environment trigger the collision with.
                    $0.collideWithLayer = [.player, .projectile]
                }
        }
        // We want to ignore triggering any collision with the ground, as the tank will constantly collide with the ground.
        ground.addComponent(BoxCollider.self)
            .set(size: Vector3Nullable(nil, 8, nil))
            .set(center: Vector3Nullable(nil, -4, nil))

        // GameManager
        let gameManager = GameObject(name: "GameManager")
        gameManager.addComponent(GameManager.self)
        gameManager.transform.position = Vector3(0, 5, 0)
        if let clip = AudioClip(fileName: "BackgroundMusic.wav", playType: .loop) {
            gameManager.addComponent(AudioSource.self)
                .configure {
                    $0.clip = clip
                    $0.volume = 0.3
                    $0.play()
                }
        }
        scene.addGameObject(gameManager)
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
