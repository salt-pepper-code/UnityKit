
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

        // Physics Setup
        guard let militaries = GameObject.find(.name(.exact("Military")))?.getChildren(),
            let oilFields = GameObject.find(.name(.exact("OilField")))?.getChildren(),
            let rocks = GameObject.find(.name(.exact("Rocks")))?.getChildren(),
            let boundaries = GameObject.find(.name(.exact("Boundaries")))?.getChildren(),
            let ground = GameObject.find(.name(.exact("GroundPlane"))),
            let helipad = GameObject.find(.name(.exact("Helipad")))
            else { return }

        let environments = militaries + oilFields + boundaries + rocks + [helipad]

        // Layers
        environments.forEach { $0.layer = .environment }
        ground.layer = .ground
        tank.layer = .player

        // Rigidbodies
        environments.forEach {
            $0.addComponent(Rigidbody.self)?
                .configure {
                    $0.useGravity = false
                    $0.isStatic = true
            }
        }
        ground.addComponent(Rigidbody.self)?
            .configure {
                $0.useGravity = false
                $0.isStatic = true
        }

        // Colliders
        environments.forEach {
            $0.addComponent(MeshCollider.self)?
                .configure {
                    $0.collideWithLayer = [.player, .projectile]
            }
        }
        ground.addComponent(BoxCollider.self)?
            .set(size: Vector3Nullable(nil, 8, nil))
            .set(center: Vector3Nullable(nil, -4, nil))
            .configure {
                $0.collideWithLayer = [.player, .projectile]
        }

        // Tank Setup
        tank.addComponent(Rigidbody.self)?
            .configure {
                $0.isKinematic = false
                $0.constraints = [.freezeRotationX, .freezeRotationZ]
                $0.set(property: .allowsResting(false))
                $0.set(property: .mass(80))
                $0.set(property: .restitution(0.1))
                $0.set(property: .friction(0.5))
                $0.set(property: .rollingFriction(0))
        }
        tank.addComponent(MeshCollider.self)?
            .set(mesh: tank.getComponent(MeshFilter.self)?.mesh)
            .configure {
                $0.collideWithLayer = [.environment, .ground]
                $0.contactWithLayer = [.ground, .projectile]
        }
        tank.addComponent(TankMovement.self)
        tank.addComponent(TankShooting.self)
        tank.addComponent(Vehicle.self)?
            .set(wheels: createWheels(), physicsWorld: scene.scnScene.physicsWorld)

        tank.transform.position = Vector3(0, 2, 0)

        scene.addGameObject(tank)
    }

    func createWheels() -> [Wheel.Parameters] {

        let positionXZ: Float = 0.56
        let positionY: Float = 0.352

        let wheels: [Wheel.Parameters] =
            [{ var wheel = Wheel.Parameters(nodeName: "Wheel_Back_R")
                wheel.connectionPosition = Vector3(positionXZ, positionY, positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }(),
             { var wheel = Wheel.Parameters(nodeName: "Wheel_Back_L")
                wheel.connectionPosition = Vector3(-positionXZ, positionY, positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }(),
             { var wheel = Wheel.Parameters(nodeName: "Wheel_Front_R")
                wheel.connectionPosition = Vector3(positionXZ, positionY, -positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }(),
             { var wheel = Wheel.Parameters(nodeName: "Wheel_Front_L")
                wheel.connectionPosition = Vector3(-positionXZ, positionY, -positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }()]

        return wheels
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

