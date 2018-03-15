
import UnityKit

class TankShooting: MonoBehaviour {

    public var shellRef: GameObject?
    public var playerNumber: Int = 1
    public var weaponOrigin: Transform?

    public var minLaunchForce: Float = 15
    public var maxLaunchForce: Float = 30
    public var maxChargeTime: Float = 0.75

    private var currentLaunchForce: Float = 0
    private var chargeSpeed: Float = 0
    private var fired: Bool = false

    override func start() {

        if let shell = GameObject(fileName: "Shell.scn", nodeName: "Shell") {
            shellRef = shell

            shell.addComponent(Rigidbody.self)
            shell.addComponent(MeshCollider.self)
        }

        let copy = shellRef?.instantiate()

        weaponOrigin = GameObject.find(.name(.exact("WeaponOrigin")))?.transform
        currentLaunchForce = minLaunchForce
        chargeSpeed = (maxLaunchForce - minLaunchForce) / maxChargeTime
    }
    
    override func update() {
    
    }
}
