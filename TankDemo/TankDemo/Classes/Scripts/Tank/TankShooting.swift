
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

        shellRef = GameObject(fileName: "Shell.scn", nodeName: "Shell")

        guard let gameObject = gameObject
            else { return }

        weaponOrigin = GameObject.find(.name(.exact("WeaponOrigin")), in: gameObject)?.transform
        currentLaunchForce = minLaunchForce
        chargeSpeed = (maxLaunchForce - minLaunchForce) / maxChargeTime
    }
    
    private func fire() {

        guard let shellRef = shellRef,
            let origin = weaponOrigin
            else { return }

        let shell = GameObject.instantiate(original: shellRef, addToScene: false)
        shell.transform.orientation = origin.orientation
        shell.transform.position = origin.position
        shell.layer = .projectile

        let rigidbody: Rigidbody? = shell.addComponent(Rigidbody.self)?.execute {
            $0.useGravity = true
            $0.isKinematic = false
            $0.constraints = [.freezeRotationY]
        }
        shell.addComponent(MeshCollider.self)?.execute {
            $0.collideWithLayer = .all
            $0.contactWithLayer = .all
        }

        gameObject?.scene?.addGameObject(shell)

        rigidbody?.set(property: .velocity(currentLaunchForce * origin.forward))
    }
}
