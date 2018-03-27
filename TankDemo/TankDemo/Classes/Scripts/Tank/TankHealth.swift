
import UnityKit

class TankHealth: MonoBehaviour {

    let startingHealth: Float = 100
    var currentHealth: Float = 0
    var dead: Bool = false

    override func start() {
        currentHealth = startingHealth
    }

    public func takeDamage(_ amount: Float) {

        // Reduce current health by the amount of damage done.
        currentHealth -= amount

        // Change the UI elements appropriately.
        setHealthUI()

        // If the current health is at or below zero and it has not yet been registered, call OnDeath.
        if currentHealth <= 0 && !dead {
            onDeath()
        }
    }

    func setHealthUI() {

    }

    func onDeath() {

        // Set the flag so that this function is only called once.
        dead = true

        print("dead")

        // Turn the tank off.
        gameObject?.setActive(false)
    }
}
