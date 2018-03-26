
import UnityKit
import Foundation

class TankMovement: MonoBehaviour {

    public var joystick: Joystick?
    public var vehicle: Vehicle?
    public var playerNumber: Int = 1
    public let motorSpeed: Float = 100
    public let turnSpeed: Float = 10
    private var previousPosition: Vector3?

    //public var movementAudio: AudioSource?          // Reference to the audio source used to play engine sounds. NB: different to the shooting audio source.
    //public var engineIdling: AudioClip?             // Audio to play when the tank isn't moving.
    //public var engineDriving: AudioClip?            // Audio to play when the tank is moving.
    //public var pitchRange: Float = 0.1              // The amount by which the pitch of the engine noises can vary.
    //private var originalPitch: Float = 0            // The pitch of the audio source at the start of the scene.
    //private var particleSystems:ParticleSystem?     // References to all the particles systems used by the Tanks

    override func awake() {

        fetchComponents()

        guard let joystick = joystick
            else { return }

        joystick.onUpdate = { [weak self] (update) -> () in
            self?.move(update.angle, update.displacement)
        }

        joystick.onComplete = { [weak self] () in

            guard let vehicle = self?.vehicle
                else { return }

            vehicle.applyBrakingForce(3, forWheelAt: 0)
            vehicle.applyBrakingForce(3, forWheelAt: 1)

            vehicle.applyEngineForce(0, forWheelAt: 0)
            vehicle.applyEngineForce(0, forWheelAt: 1)
        }
    }

    private func fetchComponents() {

        vehicle = gameObject?.getComponent(Vehicle.self)
        joystick = GameObject.findObjectOfType(Joystick.self)
    }

    private func move(_ angle: Degree, _ displacement: Float) {

        if vehicle == nil {
            fetchComponents()
        }

        guard let gameObject = gameObject,
            let vehicle = vehicle
            else { return }

        let angle = 360 - angle - 180 - 45
        let tankYRotation = (gameObject.transform.localRotation.y * gameObject.transform.localRotation.w).radiansToDegrees

        let diffAngle = angle.differenceAngle(tankYRotation)
        var turn = max(min(angle.differenceAngle(tankYRotation), turnSpeed), -turnSpeed)

        if turn > -turnSpeed && turn < turnSpeed {
            turn = 0
        }

        var speed = motorSpeed

        if abs(diffAngle) > 90 {
            speed = -motorSpeed
            turn = -turn
        }

        vehicle.applySteeringAngle(turn, forWheelAt: 2)
        vehicle.applySteeringAngle(turn, forWheelAt: 3)

        vehicle.applyBrakingForce(0, forWheelAt: 0)
        vehicle.applyBrakingForce(0, forWheelAt: 1)

        vehicle.applyEngineForce(speed, forWheelAt: 0)
        vehicle.applyEngineForce(speed, forWheelAt: 1)
    }
}
