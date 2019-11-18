import UnityKit
import Foundation

class TankShooting: MonoBehaviour {
    public var fireButton: FireButton?

    public var shellRef: GameObject?

    public var minLaunchForce: Float = 15
    public var maxLaunchForce: Float = 30
    public var maxChargeTime: Float = 0.75
    public let reloadTime: TimeInterval = 1

    private var timeElapsed: TimeInterval = 1
    private var currentLaunchForce: Float = 0
    private var chargeSpeed: Float = 0
    private var fired: Bool = false

    override func onDestroy() {
        fireButton?.onTrigger = nil
    }

    override func awake() {
        fireButton = GameObject.findObjectOfType(FireButton.self)
        fireButton?.onTrigger = { [weak self] () in
            self?.fire()
        }

        shellRef = GameObject(fileName: "Shell.scn", nodeName: "Shell")

        currentLaunchForce = minLaunchForce
        chargeSpeed = (maxLaunchForce - minLaunchForce) / maxChargeTime
    }

    override func update() {
        timeElapsed += Time.deltaTime
    }

    private func fire() {
        guard enabled,
            timeElapsed >= reloadTime,
            let shellRef = shellRef,
            let gameObject = gameObject,
            let origin = GameObject.find(.name(.exact("WeaponOrigin")), in: gameObject)
            else { return }

        timeElapsed = 0

        let shell = GameObject.instantiate(original: shellRef, addToScene: false)
        shell.layer = .projectile
        shell.transform.orientation = origin.transform.orientation
        shell.transform.position = origin.transform.position

        shell.addComponent(Rigidbody.self)
            .configure {
                $0.useGravity = true
                $0.isStatic = false
                $0.isKinematic = false
                $0.constraints = [.freezeRotationY]
            }
            .set(property: .velocity(currentLaunchForce * gameObject.transform.forward))
        shell.addComponent(MeshCollider.self)
            .configure {
                $0.collideWithLayer = .all
                $0.contactWithLayer = .all
            }
        shell.addComponent(Light.self)
            .configure {
                $0.type = .omni
                $0.color = Color(hexString: "#FFF02B")
                $0.intensity = 200
                $0.attenuationDistance = 0...10
                $0.attenuationFalloffExponent = 2
            }
        if let clip = AudioClip(fileName: "ShotFiring.wav") {
            shell.addComponent(AudioSource.self)
                .configure {
                    $0.clip = clip
                    $0.volume = 1.5
                    $0.play()
                }
        }
        shell.addComponent(ShellExplosion.self)

        gameObject.scene?.addGameObject(shell)
    }
}
