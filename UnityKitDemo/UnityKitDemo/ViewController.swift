import UIKit
import UnityKit
import SceneKit

class ViewController: UIViewController {

    internal let shipButton: UIButton = {
        let button = UIButton(type: .detailDisclosure)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    internal let cubeButton: UIButton = {
        let button = UIButton(type: .detailDisclosure)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func loadView() {
        self.view = View.makeView(sceneName: "ship.scn")
    }

    var sceneView: View {
        return self.view as! View
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        guard let scene = sceneView.sceneHolder,
            let ship = GameObject.find(.name("ship")),
            let camera = Camera.main()
            else { return }

        ship.tag = .custom("Ship")
        ship.layer = GameObject.Layer.addLayer(with: "Ship")
        _ = ship.addComponent(ShipScript.self)

        camera.cullingMask = ship.layer
        camera.followTarget(target: ship, distanceRange: (10, 10))

        let cube = GameObject.createPrimitive(.cube(width: 1, height: 1, length: 1, chamferRadius: 0, name: "Cube")).setColor(.red)
        _ = cube.addComponent(CubeScript.self)
        cube.layer = GameObject.Layer.addLayer(with: "Cube")
        cube.addToScene(scene)

        setupUI()
    }

    private func setupUI() {
        view.addSubview(shipButton)
        view.addSubview(cubeButton)
        NSLayoutConstraint.activate([
            shipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            shipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
            ])
        NSLayoutConstraint.activate([
            cubeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            cubeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])

        shipButton.addTarget(self, action: #selector(showShipUsingMask), for: .touchUpInside)
        cubeButton.addTarget(self, action: #selector(showCubeUsingMask), for: .touchUpInside)
    }

    @objc private func showShipUsingMask() {

        guard let camera = Camera.main(),
            let ship = GameObject.find(.name("ship"))
            else { return }

        camera.cullingMask = GameObject.Layer.layer(for: "Ship")
        //camera.followTarget(target: ship, distanceRange: (10, 10))
        if #available(iOS 11.0, *) {
            camera.lookAt(ship, animated: true)
        }
    }

    @objc private func showCubeUsingMask() {

        guard let camera = Camera.main(),
            let cube = GameObject.find(.name("Cube"))
            else { return }

        camera.cullingMask = GameObject.Layer.layer(for: "Cube")
        if #available(iOS 11.0, *) {
            camera.lookAt(cube, animated: true)
        }
    }
}

