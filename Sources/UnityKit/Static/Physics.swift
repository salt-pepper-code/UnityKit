import SceneKit

/// Information about a raycast hit.
///
/// This structure contains detailed information about where a ray intersected with a collider in the scene.
/// Use this information to determine what was hit, where it was hit, and the surface properties at the hit point.
///
/// ## Example
/// ```swift
/// if let hit = Physics.Raycast(origin: camera.position, direction: camera.forward) {
///     print("Hit \(hit.gameObject?.name ?? "unknown") at distance \(hit.distance)")
///     print("Hit point: \(hit.point)")
///     print("Surface normal: \(hit.normal)")
/// }
/// ```
public struct RaycastHit {
    /// The Collider that was hit by the ray.
    ///
    /// This property contains the collider component that the ray intersected with.
    /// Use this to access collision-specific properties or trigger specific behaviors.
    public let collider: Collider?

    /// The GameObject that was hit by the ray.
    ///
    /// This property provides access to the complete GameObject that contains the hit collider.
    /// Use this to access other components, transform data, or modify the hit object.
    public let gameObject: GameObject?

    /// The point in world space where the ray hit the collider.
    ///
    /// This is the exact position in 3D space where the ray first intersected with the collider's surface.
    /// Coordinates are in world space units.
    public let point: Vector3

    /// The distance from the ray origin to the hit point.
    ///
    /// This value represents how far along the ray the intersection occurred, measured in world space units.
    /// Use this to determine the closest hit when multiple objects are hit by the same ray.
    public let distance: Float

    /// The normal of the surface that was hit.
    ///
    /// The surface normal is a unit vector pointing perpendicular to the surface at the hit point.
    /// This is useful for calculating reflection angles, determining surface orientation, or applying
    /// forces in the correct direction.
    public let normal: Vector3
}

/// Global physics simulation settings and raycasting utilities.
///
/// The `Physics` class provides static methods for performing physics queries in the scene,
/// such as raycasting and overlap tests. These queries allow you to detect objects along rays,
/// find objects within specific areas, and gather collision information without simulating
/// physical forces.
///
/// ## Overview
///
/// Physics queries are essential for implementing gameplay mechanics like:
/// - Shooting mechanics and hit detection
/// - Line-of-sight checking for AI
/// - Ground detection for character controllers
/// - Click-to-select object interaction
/// - Proximity detection and trigger zones
///
/// All methods in this class use axis-aligned bounding box (AABB) intersection tests
/// for efficient collision detection.
///
/// ## Topics
///
/// ### Raycasting
///
/// - ``Raycast(origin:direction:maxDistance:layerMask:in:)``
/// - ``RaycastAll(origin:direction:maxDistance:layerMask:in:)``
///
/// ### Overlap Testing
///
/// - ``overlapSphere(position:radius:layerMask:in:)``
///
/// ## Example: Basic Raycasting
///
/// ```swift
/// // Cast a ray forward from the camera
/// let origin = camera.transform.position
/// let direction = camera.transform.forward
///
/// if let hit = Physics.Raycast(origin: origin, direction: direction, maxDistance: 100) {
///     print("Hit object: \(hit.gameObject?.name ?? "unknown")")
///     print("Distance: \(hit.distance)")
///
///     // Spawn effect at hit point
///     let effect = GameObject(name: "HitEffect")
///     effect.transform.position = hit.point
/// }
/// ```
///
/// ## Example: Layer-Filtered Raycasting
///
/// ```swift
/// // Only detect enemies
/// let hit = Physics.Raycast(
///     origin: playerPosition,
///     direction: aimDirection,
///     maxDistance: 50,
///     layerMask: .enemy
/// )
///
/// if let enemy = hit?.gameObject {
///     // Apply damage to enemy
///     enemy.getComponent(Health.self)?.takeDamage(10)
/// }
/// ```
///
/// ## Example: Sphere Overlap Detection
///
/// ```swift
/// // Find all objects within explosion radius
/// let affected = Physics.overlapSphere(
///     position: explosionCenter,
///     radius: 10.0,
///     layerMask: .damageable
/// )
///
/// for collider in affected {
///     if let rb = collider.gameObject?.getComponent(Rigidbody.self) {
///         rb.addExplosionForce(
///             explosionForce: 1000,
///             explosionPosition: explosionCenter,
///             explosionRadius: 10.0
///         )
///     }
/// }
/// ```
public class Physics {
    /// Casts a ray through the scene and returns information about the first object hit.
    ///
    /// This method performs a raycast from the specified origin point in the given direction,
    /// testing for intersections with colliders in the scene. It returns detailed information
    /// about the first (closest) hit, or `nil` if nothing was hit within the maximum distance.
    ///
    /// The ray direction is automatically normalized before testing. The method uses
    /// axis-aligned bounding box (AABB) intersection tests for efficient collision detection.
    ///
    /// - Parameters:
    ///   - origin: The starting point of the ray in world space coordinates.
    ///   - direction: The direction vector of the ray. This will be automatically normalized.
    ///   - maxDistance: The maximum distance the ray should check for collisions. Defaults to infinity.
    ///   - layerMask: A layer mask to selectively test only colliders on specific layers. Defaults to `.all`.
    ///   - scene: The scene to perform the raycast in. Defaults to the shared scene instance.
    ///
    /// - Returns: A ``RaycastHit`` structure containing hit information if an object was hit, or `nil` if nothing was hit.
    ///
    /// - Note: This method uses physics-based raycasting by iterating through colliders.
    ///         For view-based picking (screen to world), use `Camera.ScreenPointToRay` with a renderer.
    ///
    /// ## Example: Shooting Mechanic
    /// ```swift
    /// class Gun: MonoBehaviour {
    ///     func shoot() {
    ///         let origin = transform.position
    ///         let direction = transform.forward
    ///
    ///         if let hit = Physics.Raycast(origin: origin, direction: direction, maxDistance: 100) {
    ///             // Create bullet hole at hit point
    ///             createBulletHole(at: hit.point, normal: hit.normal)
    ///
    ///             // Apply damage if we hit something damageable
    ///             hit.gameObject?.getComponent(Health.self)?.takeDamage(25)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// ## Example: Ground Detection
    /// ```swift
    /// func isGrounded() -> Bool {
    ///     let origin = transform.position
    ///     let direction = Vector3(0, -1, 0)
    ///
    ///     if let hit = Physics.Raycast(origin: origin, direction: direction, maxDistance: 0.1) {
    ///         return hit.distance <= 0.1
    ///     }
    ///     return false
    /// }
    /// ```
    public static func Raycast(
        origin: Vector3,
        direction: Vector3,
        maxDistance: Float = .infinity,
        layerMask: GameObject.Layer = .all,
        in scene: Scene? = Scene.shared
    ) -> RaycastHit? {
        guard let scene else { return nil }

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

    /// Casts a ray through the scene and returns information about all objects hit.
    ///
    /// This method performs a raycast similar to ``Raycast(origin:direction:maxDistance:layerMask:in:)``,
    /// but instead of returning only the first hit, it returns all intersections along the ray path.
    /// The results are automatically sorted by distance from the origin, with the closest hit first.
    ///
    /// This is useful when you need to process multiple objects along a ray path, such as
    /// penetrating projectiles or checking line-of-sight through multiple objects.
    ///
    /// - Parameters:
    ///   - origin: The starting point of the ray in world space coordinates.
    ///   - direction: The direction vector of the ray. This will be automatically normalized.
    ///   - maxDistance: The maximum distance the ray should check for collisions. Defaults to infinity.
    ///   - layerMask: A layer mask to selectively test only colliders on specific layers. Defaults to `.all`.
    ///   - scene: The scene to perform the raycast in. Defaults to the shared scene instance.
    ///
    /// - Returns: An array of ``RaycastHit`` structures for all objects hit, sorted by distance (closest first).
    ///            Returns an empty array if nothing was hit.
    ///
    /// ## Example: Penetrating Shot
    /// ```swift
    /// func firePenetratingBullet() {
    ///     let hits = Physics.RaycastAll(
    ///         origin: gunBarrel.position,
    ///         direction: gunBarrel.forward,
    ///         maxDistance: 50
    ///     )
    ///
    ///     // Damage all enemies hit, with damage falloff
    ///     for (index, hit) in hits.enumerated() {
    ///         let damage = 100 - (index * 20) // Damage decreases with each penetration
    ///         hit.gameObject?.getComponent(Health.self)?.takeDamage(damage)
    ///     }
    /// }
    /// ```
    ///
    /// ## Example: Line of Sight Check
    /// ```swift
    /// func hasLineOfSightTo(target: GameObject) -> Bool {
    ///     let direction = (target.transform.position - transform.position).normalized()
    ///     let maxDistance = (target.transform.position - transform.position).magnitude()
    ///
    ///     let hits = Physics.RaycastAll(
    ///         origin: transform.position,
    ///         direction: direction,
    ///         maxDistance: maxDistance
    ///     )
    ///
    ///     // Check if any opaque objects block the view
    ///     for hit in hits {
    ///         if hit.gameObject != target && !hit.gameObject!.hasTag("transparent") {
    ///             return false // Line of sight is blocked
    ///         }
    ///     }
    ///     return true
    /// }
    /// ```
    public static func RaycastAll(
        origin: Vector3,
        direction: Vector3,
        maxDistance: Float = .infinity,
        layerMask: GameObject.Layer = .all,
        in scene: Scene? = Scene.shared
    ) -> [RaycastHit] {
        guard let scene else { return [] }

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

    /// Finds all colliders that overlap with a sphere in the scene.
    ///
    /// This method checks for all colliders whose bounding boxes intersect with a sphere
    /// centered at the specified position with the given radius. This is useful for
    /// detecting objects within a certain range, implementing explosion effects, or
    /// creating trigger zones.
    ///
    /// The method uses bounding box to sphere intersection tests for efficient detection.
    ///
    /// - Parameters:
    ///   - position: The center point of the sphere in world space coordinates.
    ///   - radius: The radius of the sphere in world space units.
    ///   - layerMask: A layer mask to selectively test only colliders on specific layers. Defaults to `.all`.
    ///   - scene: The scene to perform the overlap test in. Defaults to the shared scene instance.
    ///
    /// - Returns: An array of ``Collider`` components for all objects overlapping the sphere.
    ///            Returns an empty array if no objects overlap.
    ///
    /// ## Example: Explosion Effect
    /// ```swift
    /// func explode(at position: Vector3, radius: Float, force: Float) {
    ///     let affectedColliders = Physics.overlapSphere(
    ///         position: position,
    ///         radius: radius,
    ///         layerMask: .default
    ///     )
    ///
    ///     for collider in affectedColliders {
    ///         if let rb = collider.gameObject?.getComponent(Rigidbody.self) {
    ///             rb.addExplosionForce(
    ///                 explosionForce: force,
    ///                 explosionPosition: position,
    ///                 explosionRadius: radius
    ///             )
    ///         }
    ///
    ///         // Apply damage
    ///         collider.gameObject?.getComponent(Health.self)?.takeDamage(50)
    ///     }
    /// }
    /// ```
    ///
    /// ## Example: Proximity Detection
    /// ```swift
    /// class ProximityTrigger: MonoBehaviour {
    ///     var detectionRadius: Float = 5.0
    ///
    ///     func update() {
    ///         let nearby = Physics.overlapSphere(
    ///             position: transform.position,
    ///             radius: detectionRadius,
    ///             layerMask: .player
    ///         )
    ///
    ///         if !nearby.isEmpty {
    ///             print("Player detected nearby!")
    ///             triggerEvent()
    ///         }
    ///     }
    /// }
    /// ```
    public static func overlapSphere(
        position: Vector3,
        radius: Float,
        layerMask: GameObject.Layer = .all,
        in scene: Scene? = Scene.shared
    ) -> [Collider] {
        guard let scene
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

                return self.boxIntersectsSphere(box: boundingBox, sphere: boundingSphere)
            }

        return colliders
    }

    /// Tests if an axis-aligned bounding box intersects with a sphere.
    ///
    /// This internal method performs a bounding box to sphere intersection test
    /// using the closest point on the box to the sphere's center.
    ///
    /// - Parameters:
    ///   - box: The axis-aligned bounding box to test, defined by min and max points.
    ///   - sphere: The bounding sphere to test, defined by center point and radius.
    ///
    /// - Returns: `true` if the box and sphere intersect, `false` otherwise.
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
