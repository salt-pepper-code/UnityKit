import UIKit
import UnityKit
import SceneKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blue
        
        let sceneView = View.makeView(onView: self.view, sceneFilename: "ship.scn")
        
        sceneView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 0)
        
        if let scene = sceneView.sceneHolder {

            if let shipMesh = scene.find(.name("shipMesh")) {
                
                _ = shipMesh.addComponent(ShipScript.self)
                
                if let camera = Camera.main(scene) {
                
                    camera.followTarget(target: shipMesh, distanceRange: (10, 10))
                }
            }
        }
        
        /*let sceneView = View.makeView(onView: self.view)
        
        if let scene = sceneView.sceneHolder {
            
            let cube = GameObject.createPrimitive(.cube(width: 1, height: 1, length: 1, chamferRadius: 0, name: "Cube")).setColor(UIColor(red: 1, green: 0, blue: 0, alpha: 1))
            
            _ = cube.addComponent(CubeScript.self)
            
            cube.addToScene(scene)
                        
            let camera = Camera.main(scene)
            
            camera?.lookAt(cube)
            
            //camera?.followTarget = cube
        }*/
    }
}

