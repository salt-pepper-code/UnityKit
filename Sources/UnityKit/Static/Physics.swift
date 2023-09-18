import SceneKit

public class Physics {
    public static func overlapSphere(
        position: Vector3,
        radius: Float,
        layerMask: GameObject.Layer = .all,
        in scene: Scene? = Scene.shared
    ) -> [Collider] {
        guard let scene = scene
        else { return [] }

        let boundingSphere = (center: position, radius: radius)

        let colliders = GameObject.findGameObjects(.layer(layerMask), in: scene)
            .compactMap { gameObject -> Collider? in gameObject.getComponent(Collider.self) }
            .filter {
                guard let gameObject = $0.gameObject
                else { return false }

                var boundingBox = gameObject.boundingBox

                let min = boundingBox.min + gameObject.transform.position
                let max = boundingBox.max + gameObject.transform.position

                boundingBox = (min: min, max: max)

                return boxIntersectsSphere(box: boundingBox, sphere: boundingSphere)
            }

        return colliders
    }

    static func boxIntersectsSphere(box: BoundingBox, sphere: BoundingSphere) -> Bool {
        var dist_squared = sphere.radius * sphere.radius
        if sphere.center.x < box.min.x { dist_squared -= pow(sphere.center.x - box.min.x, 2) }
        else if sphere.center.x > box.max.x { dist_squared -= pow(sphere.center.x - box.max.x, 2) }
        if sphere.center.y < box.min.y { dist_squared -= pow(sphere.center.y - box.min.y, 2) }
        else if sphere.center.y > box.max.y { dist_squared -= pow(sphere.center.y - box.max.y, 2) }
        if sphere.center.z < box.min.z { dist_squared -= pow(sphere.center.z - box.min.z, 2) }
        else if sphere.center.z > box.max.z { dist_squared -= pow(sphere.center.z - box.max.z, 2) }
        return dist_squared > 0
    }
}
