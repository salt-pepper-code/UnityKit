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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blue

        let sceneView = View.makeView(on: self.view, sceneFilename: "ship.scn")
        
        sceneView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 0)
        
        guard let scene = sceneView.sceneHolder
            else { return }

        if let ship = GameObject.find(.name("ship")),
            let camera = Camera.main() {

            ship.tag = .custom("Ship")
            ship.layer = GameObject.Layer.addLayer(with: "Ship")
            _ = ship.addComponent(ShipScript.self)

            camera.cullingMask = ship.layer
            camera.followTarget(target: ship, distanceRange: (10, 10))
        }

        let cube = GameObject.createPrimitive(.cube(width: 1, height: 1, length: 1, chamferRadius: 0, name: "Cube")).setColor(UIColor(red: 1, green: 0, blue: 0, alpha: 1))
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

        shipButton.addTarget(self, action: #selector(showShip), for: .touchUpInside)
        cubeButton.addTarget(self, action: #selector(showCube), for: .touchUpInside)
    }

    @objc private func showShip() {

        guard let camera = Camera.main(), let ship = GameObject.find(.name("ship"))
            else { return }

        camera.cullingMask = GameObject.Layer.layer(for: "Ship")
        camera.followTarget(target: ship, distanceRange: (10, 10))
    }

    @objc private func showCube() {

        guard let camera = Camera.main(), let cube = GameObject.find(.name("Cube"))
            else { return }

        camera.cullingMask = GameObject.Layer.layer(for: "Cube")
        camera.followTarget(target: cube, distanceRange: (10, 10))
    }
}

