import SceneKit

/// Information about a raycast hit
public struct RaycastHit {
    /// The Collider that was hit
    public let collider: Collider?

    /// The GameObject that was hit
    public let gameObject: GameObject?

    /// The point in world space where the ray hit
    public let point: Vector3

    /// The distance from the ray origin to the hit point
    public let distance: Float

    /// The normal of the surface that was hit
    public let normal: Vector3
}

public class Physics {
    /// Cast a ray through the scene and return the first hit
    /// - Parameters:
    ///   - origin: Starting point of the ray in world coordinates
    ///   - direction: Direction of the ray (will be normalized)
    ///   - maxDistance: Maximum distance the ray should check for collisions
    ///   - layerMask: Layer mask to selectively ignore colliders
    ///   - scene: The scene to raycast in (defaults to shared scene)
    /// - Returns: RaycastHit if something was hit, nil otherwise
    ///
    /// Note: Uses physics-based raycasting by iterating through colliders.
    /// For view-based picking, use Camera.ScreenPointToRay with a renderer.
    public static func Raycast(
        origin: Vector3,
        direction: Vector3,
        maxDistance: Float = .infinity,
        layerMask: GameObject.Layer = .all,
        in scene: Scene? = Scene.shared
    ) -> RaycastHit? {
        guard let scene = scene else { return nil }

        let normalizedDirection = direction.normalized()
        var closestHit: RaycastHit?
        var closestDistance: Float = maxDistance

        // Get all colliders in the scene
        let colliders = GameObject.findGameObjects(.layer(layerMask), in: scene)
            .compactMap { $0.getComponent(Collider.self) }

        // Test ray against each collider's bounding box
        for collider in colliders {
            guard let gameObject = collider.gameObject else { continue }

            let boundingBox = gameObject.boundingBox
            let position = gameObject.transform.position

            // Transform bounding box to world space
            let worldMin = boundingBox.min + position
            let worldMax = boundingBox.max + position

            // Ray-AABB intersection test
            if let (distance, hitPoint, normal) = rayIntersectsAABB(
                rayOrigin: origin,
                rayDirection: normalizedDirection,
                boxMin: worldMin,
                boxMax: worldMax
            ) {
                if distance <= closestDistance {
                    closestDistance = distance
                    closestHit = RaycastHit(
                        collider: collider,
                        gameObject: gameObject,
                        point: hitPoint,
                        distance: distance,
                        normal: normal
                    )
                }
            }
        }

        return closestHit
    }

    /// Cast a ray through the scene and return all hits
    /// - Parameters:
    ///   - origin: Starting point of the ray in world coordinates
    ///   - direction: Direction of the ray (will be normalized)
    ///   - maxDistance: Maximum distance the ray should check for collisions
    ///   - layerMask: Layer mask to selectively ignore colliders
    ///   - scene: The scene to raycast in (defaults to shared scene)
    /// - Returns: Array of RaycastHit for all objects hit (sorted by distance)
    public static func RaycastAll(
        origin: Vector3,
        direction: Vector3,
        maxDistance: Float = .infinity,
        layerMask: GameObject.Layer = .all,
        in scene: Scene? = Scene.shared
    ) -> [RaycastHit] {
        guard let scene = scene else { return [] }

        let normalizedDirection = direction.normalized()
        var results: [RaycastHit] = []

        // Get all colliders in the scene
        let colliders = GameObject.findGameObjects(.layer(layerMask), in: scene)
            .compactMap { $0.getComponent(Collider.self) }

        // Test ray against each collider's bounding box
        for collider in colliders {
            guard let gameObject = collider.gameObject else { continue }

            let boundingBox = gameObject.boundingBox
            let position = gameObject.transform.position

            // Transform bounding box to world space
            let worldMin = boundingBox.min + position
            let worldMax = boundingBox.max + position

            // Ray-AABB intersection test
            if let (distance, hitPoint, normal) = rayIntersectsAABB(
                rayOrigin: origin,
                rayDirection: normalizedDirection,
                boxMin: worldMin,
                boxMax: worldMax
            ) {
                if distance <= maxDistance {
                    results.append(RaycastHit(
                        collider: collider,
                        gameObject: gameObject,
                        point: hitPoint,
                        distance: distance,
                        normal: normal
                    ))
                }
            }
        }

        // Sort by distance
        return results.sorted { $0.distance < $1.distance }
    }

    /// Ray-AABB (Axis-Aligned Bounding Box) intersection test
    /// Returns (distance, hitPoint, normal) if hit, nil otherwise
    private static func rayIntersectsAABB(
        rayOrigin: Vector3,
        rayDirection: Vector3,
        boxMin: Vector3,
        boxMax: Vector3
    ) -> (distance: Float, point: Vector3, normal: Vector3)? {
        // Use slab method for ray-AABB intersection
        var tMin: Float = 0
        var tMax: Float = .infinity

        var hitNormal = Vector3.zero

        // Test X slab
        if abs(rayDirection.x) < 0.0001 {
            // Ray parallel to X slab
            if rayOrigin.x < boxMin.x || rayOrigin.x > boxMax.x {
                return nil
            }
        } else {
            let invD = 1.0 / rayDirection.x
            var t1 = (boxMin.x - rayOrigin.x) * invD
            var t2 = (boxMax.x - rayOrigin.x) * invD

            if t1 > t2 { swap(&t1, &t2) }

            if t1 > tMin {
                tMin = t1
                hitNormal = rayDirection.x < 0 ? Vector3(1, 0, 0) : Vector3(-1, 0, 0)
            }
            tMax = min(tMax, t2)

            if tMin > tMax { return nil }
        }

        // Test Y slab
        if abs(rayDirection.y) < 0.0001 {
            if rayOrigin.y < boxMin.y || rayOrigin.y > boxMax.y {
                return nil
            }
        } else {
            let invD = 1.0 / rayDirection.y
            var t1 = (boxMin.y - rayOrigin.y) * invD
            var t2 = (boxMax.y - rayOrigin.y) * invD

            if t1 > t2 { swap(&t1, &t2) }

            if t1 > tMin {
                tMin = t1
                hitNormal = rayDirection.y < 0 ? Vector3(0, 1, 0) : Vector3(0, -1, 0)
            }
            tMax = min(tMax, t2)

            if tMin > tMax { return nil }
        }

        // Test Z slab
        if abs(rayDirection.z) < 0.0001 {
            if rayOrigin.z < boxMin.z || rayOrigin.z > boxMax.z {
                return nil
            }
        } else {
            let invD = 1.0 / rayDirection.z
            var t1 = (boxMin.z - rayOrigin.z) * invD
            var t2 = (boxMax.z - rayOrigin.z) * invD

            if t1 > t2 { swap(&t1, &t2) }

            if t1 > tMin {
                tMin = t1
                hitNormal = rayDirection.z < 0 ? Vector3(0, 0, 1) : Vector3(0, 0, -1)
            }
            tMax = min(tMax, t2)

            if tMin > tMax { return nil }
        }

        // Hit!
        let hitPoint = rayOrigin + rayDirection * tMin
        return (distance: tMin, point: hitPoint, normal: hitNormal)
    }

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
