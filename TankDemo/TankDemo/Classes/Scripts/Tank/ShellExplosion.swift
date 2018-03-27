
import UnityKit

class ShellExplosion: MonoBehaviour {

    let maxDamage: Float = 100
    let explosionForce: Float = 1000
    let maxLifeTime: Float = 2
    let explosionRadius: Float = 5

    override func onTriggerEnter(_ collider: Collider) {

        guard let transform = transform
            else { return }

        let colliders = Physics.overlapSphere(position: transform.position, radius: explosionRadius, layerMask: .player)

        for collider in colliders {

            guard let rigidbody = collider.getComponent(Rigidbody.self),
                let transform = gameObject?.transform
                else { continue }

            if let vehicle = collider.getComponent(Vehicle.self) {
                vehicle.applyBrakingForce(0)
            }
            
            rigidbody.addExplosionForce(explosionForce: explosionForce, explosionPosition: transform.position, explosionRadius: explosionRadius)
        }

        gameObject?.destroy()
    }
}
