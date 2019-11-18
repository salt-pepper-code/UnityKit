import UnityKit
import SceneKit

class ShellExplosion: MonoBehaviour {
    let maxDamage: Float = 100
    let explosionForce: Float = 1000
    let maxLifeTime: Float = 2
    let explosionRadius: Float = 5

    override func onTriggerEnter(_ collider: Collider) {
        guard let shellTransform = gameObject?.transform
            else { return }

        let colliders = Physics.overlapSphere(position: shellTransform.position, radius: explosionRadius, layerMask: .player)

        for collider in colliders {
            guard let targetRigidbody = collider.getComponent(Rigidbody.self)
                else { continue }

            if let targetVehicle = collider.getComponent(Vehicle.self) {
                targetVehicle.applyBrakingForce(0)
            }

            targetRigidbody.addExplosionForce(explosionForce: explosionForce,
                                              explosionPosition: shellTransform.position,
                                              explosionRadius: explosionRadius,
                                              replacePosition: Vector3Nullable(nil, 0, nil))

            guard let targetHealth = targetRigidbody.getComponent(TankHealth.self)
                else { continue }

            // Calculate the amount of damage the target should take based on it's distance from the shell.
            let damage = calculateDamage(targetRigidbody.position)

            targetHealth.takeDamage(damage)
        }

        if let scene = Scene.sharedInstance {
            let empty = GameObject()
            scene.addGameObject(empty)
            empty.transform.position = shellTransform.position
            if let clip = AudioClip(fileName: "ShellExplosion.wav") {
                empty.addComponent(AudioSource.self)
                    .configure {
                        $0.clip = clip
                        $0.volume = 2
                        $0.play()
                    }
            }
            empty.addComponent(ParticleSystem.self)
                .load(fileName: "Explosion.scnp", loops: false)
                .executeAfter(milliseconds: 1000, block: { [weak empty] _ in
                    empty?.destroy()
                })
        }

        // Destroy the shell.
        gameObject?.destroy()
    }

    private func calculateDamage(_ targetPosition: Vector3) -> Float {
        guard let transform = transform
            else { return 0 }

        // Create a vector from the shell to the target.
        let explosionToTarget = targetPosition - transform.position

        // Calculate the distance from the shell to the target.
        let explosionDistance = explosionToTarget.magnitude()

        // Calculate the proportion of the maximum distance (the explosionRadius) the target is away.
        let relativeDistance = (explosionRadius - explosionDistance) / explosionRadius

        // Calculate damage as this proportion of the maximum possible damage.
        // Make sure that the minimum damage is always 0.
        return max(0, relativeDistance * maxDamage)
    }
}
