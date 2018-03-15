
import UnityKit
import Foundation

class TankMovement: MonoBehaviour {

    public var joystick: Joystick? {
        didSet {
            guard let joystick = joystick
                else { return }

            joystick.onUpdate = { [weak self] (angle, displacement) in
                self?.move(angle, displacement)
            }
            joystick.onComplete = { [weak self] () in
                guard let rigidBody = self?.rigidBody
                    else { return }
                rigidBody.clearAllForces()
            }
        }
    }

    public var rigidBody: RigidBody?
    public var playerNumber: Int = 1                // Used to identify which tank belongs to which player.  This is set by this tank's manager.
    public var speed: Float = 2                    // How fast the tank moves forward and back.
    public var turnSpeed: Float = 45               // How fast the tank turns in degrees per second.
    //public var movementAudio: AudioSource?          // Reference to the audio source used to play engine sounds. NB: different to the shooting audio source.
    //public var engineIdling: AudioClip?             // Audio to play when the tank isn't moving.
    //public var engineDriving: AudioClip?            // Audio to play when the tank is moving.
    //public var pitchRange: Float = 0.1              // The amount by which the pitch of the engine noises can vary.
    //private var originalPitch: Float = 0            // The pitch of the audio source at the start of the scene.
    //private var particleSystems:ParticleSystem?     // References to all the particles systems used by the Tanks

    override func awake() {
        rigidBody = getComponent(RigidBody.self)
    }

    override func onEnable() {

    }

    override func onDisable() {
        
    }

    override func start() {

    }
    
    private func move(_ angle: Float, _ displacement: Float) {

        guard let gameObject = gameObject,
            let rigidBody = rigidBody
            else { return }

        //print(gameObject.transform.forward)

        // Create a vector in the direction the tank is facing with a magnitude based on the input, speed and the time between frames.
        var angle = angle
        if angle > 180 {
            angle -= 360
        }

        let radians = angle.degreesToRadians
        let direction = Vector3(cos(radians), 0, sin(radians))
        print(direction)
       // let turn = angle / turnSpeed * Time.deltaTime.toFloat()


        //rigidBody.addTorque(Vector4(0, 1, 0, 1.degreesToRadians))

        //gameObject.transform.localEulerAngles += turn //Vector3.lerp(from: gameObject.transform.localEulerAngles, to: Vector3(0, angle, 0), time: Time.deltaTime)

        //rigidBody.addForce(direction)
//        let movement = gameObject.transform.forward * speed * Time.deltaTime.toFloat()
        gameObject.transform.localEulerAngles = Vector3(0, angle, 0)
        gameObject.transform.position += displacement * direction

        //gameObject.node.physicsBody?.applyForce(gameObject.transform.forward, asImpulse: true)
        //gameObject.node.physicsBody?.applyTorque(Vector4(0, 1, 0, turn.degreesToRadians), asImpulse: true)
    }


    private func turn() {

    }
}
