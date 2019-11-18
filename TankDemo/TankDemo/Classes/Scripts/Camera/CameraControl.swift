import UnityKit

class CameraControl: MonoBehaviour {
    private var target: GameObject?
    private var camera: Camera?

    public func set(target: GameObject) {
        self.target = target

        camera = getComponent(Camera.self)

        guard let camera = camera
            else { return }

        camera.followTarget(target: target)
        camera.orthographic = true
        camera.orthographicSize = 20
    }

    override func update() {
        guard let camera = camera?.gameObject,
            let target = target
            else { return }

        camera.transform.position = Vector3(target.transform.position.x + 43, 41, target.transform.position.z - 23)
    }
}
