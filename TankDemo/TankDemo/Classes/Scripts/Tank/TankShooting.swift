
import UnityKit

class TankShooting: MonoBehaviour {

    public var fireButton: FireButton?

    public var shellRef: GameObject?
    public var playerNumber: Int = 1

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

        currentLaunchForce = minLaunchForce
        chargeSpeed = (maxLaunchForce - minLaunchForce) / maxChargeTime
    }
    
    private func fire() {

        guard let shellRef = shellRef,
            let gameObject = gameObject,
            let origin = GameObject.find(.name(.exact("WeaponOrigin")), in: gameObject)
            else { return }

        let shell = GameObject.instantiate(original: shellRef, addToScene: false)
        shell.layer = .projectile
        shell.transform.orientation = origin.transform.orientation
        shell.transform.position = origin.transform.position

        shell.addComponent(Rigidbody.self)?
            .configure {
                $0.useGravity = true
                $0.isKinematic = false
                $0.constraints = [.freezeRotationY]
            }
            .set(property: .velocity(currentLaunchForce * gameObject.transform.forward))

        shell.addComponent(MeshCollider.self)?
            .configure {
                $0.collideWithLayer = .all
                $0.contactWithLayer = .all
        }

        gameObject.scene?.addGameObject(shell)
    }
}
