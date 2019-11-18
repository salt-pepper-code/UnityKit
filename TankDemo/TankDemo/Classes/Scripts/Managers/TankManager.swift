import UnityKit

class TankManager: MonoBehaviour {
    private var movement: TankMovement?
    private var shooting: TankShooting?

    public func setup() {
        movement = getComponent(TankMovement.self)
        shooting = getComponent(TankShooting.self)
    }

    public func disableControl () {
        movement?.enabled = false
        shooting?.enabled = false
    }

    public func enableControl () {
        movement?.enabled = true
        shooting?.enabled = true
    }
}
