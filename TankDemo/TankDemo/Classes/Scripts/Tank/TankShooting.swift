
import UnityKit

class TankShooting: MonoBehaviour {

    public var fireButton: FireButton?

    public var shellRef: GameObject?
    public var playerNumber: Int = 1
    public var weaponOrigin: Transform?

    public var minLaunchForce: Float = 15
    public var maxLaunchForce: Float = 30
    public var maxChargeTime: Float = 0.75

    private var currentLaunchForce: Float = 0
    private var chargeSpeed: Float = 0
    private var fired: Bool = false

    override func awake() {

        fireButton = GameObject.findObjectOfType(FireButton.self)
        fireButton?.onTrigger = { [weak self] () in
            self?.fire()
        }

        if let shell = GameObject(fileName: "Shell.scn", nodeName: "Shell") {
            shellRef = shell
            shell.layer = GameObject.Layer.projectile
            shell.addComponent(Rigidbody.self)?.execute {
                $0.isKinematic = false
                $0.useGravity = true
            }
            shell.addComponent(MeshCollider.self)?.execute {
                $0.collideWithLayer = .all
                $0.triggerWithLayer = .all
            }
        }

        weaponOrigin = GameObject.find(.name(.exact("WeaponOrigin")))?.transform
        currentLaunchForce = minLaunchForce
        chargeSpeed = (maxLaunchForce - minLaunchForce) / maxChargeTime
    }
    
    private func fire() {

        guard let shellRef = shellRef,
            let origin = weaponOrigin
            else { return }

        let shell = GameObject.instantiate(original: shellRef)
        shell.transform.orientation = origin.orientation
        shell.transform.position = origin.position

        guard let rigidbody = shell.getComponent(Rigidbody.self)
            else { return }

        rigidbody.constraints = [.freezeRotationY]
        rigidbody.velocity = currentLaunchForce * origin.forward
    }
}
