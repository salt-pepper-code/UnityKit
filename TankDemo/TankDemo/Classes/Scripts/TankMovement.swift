
import UnityKit
import Foundation

class TankMovement: MonoBehaviour {

    public var joystick: Joystick?
    public var rigidBody: RigidBody?
    public var playerNumber: Int = 1
    public var speed: Float = 2
    //public var movementAudio: AudioSource?          // Reference to the audio source used to play engine sounds. NB: different to the shooting audio source.
    //public var engineIdling: AudioClip?             // Audio to play when the tank isn't moving.
    //public var engineDriving: AudioClip?            // Audio to play when the tank is moving.
    //public var pitchRange: Float = 0.1              // The amount by which the pitch of the engine noises can vary.
    //private var originalPitch: Float = 0            // The pitch of the audio source at the start of the scene.
    //private var particleSystems:ParticleSystem?     // References to all the particles systems used by the Tanks

    override func awake() {

        rigidBody = getComponent(RigidBody.self)
        joystick = GameObject.findObjectOfType(Joystick.self)

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
    
    private func move(_ angle: Degree, _ displacement: Float) {

        guard let rigidBody = rigidBody,
            let transform = transform
            else { return }

        let angle = (360 - (angle - 90)).clamp()
        let rotation = Vector4(0, 1, 0, angle.degreesToRadians)
        let movement = transform.forward * speed * Time.deltaTime.toFloat()

        rigidBody.moveRotation(rotation)
        rigidBody.movePosition(rigidBody.position + movement)
    }
}
