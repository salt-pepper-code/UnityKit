import UnityKit
import Foundation

class TankMovement: MonoBehaviour {
    public var joystick: Joystick?
    public var vehicle: Vehicle?
    public let breakingSpeed: Float = 10
    public let motorSpeed: Float = 200
    public let turnSpeed: Float = 10

    override func onDestroy() {
        joystick?.onUpdate = nil
        joystick?.onComplete = nil
    }

    override func awake() {
        fetchComponents()

        if let clip = AudioClip(fileName: "EngineIdle.aif", playType: .loop) {
            addComponent(AudioSource.self)
                .configure {
                    $0.clip = clip
                    $0.volume = 0.4
                    $0.play()
                }
        }

        guard let joystick = joystick
            else { return }

        joystick.onStart = { [weak self] () in
            if let clip = AudioClip(fileName: "EngineDriving.aif", playType: .loop) {
                self?.getComponent(AudioSource.self)?
                    .configure {
                        $0.clip = clip
                        $0.play()
                    }
            }
        }

        joystick.onUpdate = { [weak self] update -> Void in
            self?.move(update.angle, update.displacement)
        }

        joystick.onComplete = { [weak self] () in
            if let clip = AudioClip(fileName: "EngineIdle.aif", playType: .loop) {
                self?.getComponent(AudioSource.self)?
                    .configure {
                        $0.clip = clip
                        $0.play()
                    }
            }

            guard let vehicle = self?.vehicle,
                let breakingSpeed = self?.breakingSpeed
                else { return }

            vehicle.applyBrakingForce(breakingSpeed, forWheelAt: 0)
            vehicle.applyBrakingForce(breakingSpeed, forWheelAt: 1)

            vehicle.applySteeringAngle(0)
            vehicle.applyEngineForce(0)
        }
    }

    private func fetchComponents() {
        vehicle = gameObject?.getComponent(Vehicle.self)
        joystick = GameObject.findObjectOfType(Joystick.self)
    }

    private func move(_ angle: Degree, _ displacement: Float) {
        guard enabled
            else { return }

        if vehicle == nil {
            fetchComponents()
        }

        guard let gameObject = gameObject,
            let vehicle = vehicle
            else { return }

        let angle = 360 - angle - 180 - 45
        let tankYRotation = (gameObject.transform.localRotation.y * gameObject.transform.localRotation.w).radiansToDegrees
        let diffAngle = angle.differenceAngle(tankYRotation)

        var steeringAngle = max(min(angle.differenceAngle(tankYRotation), turnSpeed), -turnSpeed)
        let engineForce = motorSpeed

        if steeringAngle > -turnSpeed && steeringAngle < turnSpeed {
            steeringAngle = 0
        }

        if abs(diffAngle) > 90 {
            vehicle.applySteeringAngle(steeringAngle, forWheelAt: 0)
            vehicle.applySteeringAngle(steeringAngle, forWheelAt: 1)

            vehicle.applySteeringAngle(-steeringAngle, forWheelAt: 2)
            vehicle.applySteeringAngle(-steeringAngle, forWheelAt: 3)
        } else {
            vehicle.applySteeringAngle(0, forWheelAt: 0)
            vehicle.applySteeringAngle(0, forWheelAt: 1)

            vehicle.applySteeringAngle(steeringAngle, forWheelAt: 2)
            vehicle.applySteeringAngle(steeringAngle, forWheelAt: 3)
        }

        vehicle.applyBrakingForce(0, forWheelAt: 0)
        vehicle.applyBrakingForce(0, forWheelAt: 1)

        vehicle.applyEngineForce(engineForce, forWheelAt: 0)
        vehicle.applyEngineForce(engineForce, forWheelAt: 1)
    }
}
