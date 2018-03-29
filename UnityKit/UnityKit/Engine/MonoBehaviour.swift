
import Foundation

public typealias CoroutineCondition = (TimeInterval) -> Bool
public typealias CoroutineClosure = () -> ()
public typealias Coroutine = (execute: CoroutineClosure, exitCondition: CoroutineCondition)

open class MonoBehaviour: Behaviour, Instantiable {

    private var queuedCoroutine = [Coroutine]()
    private var currentCoroutine: Coroutine?
    private var timePassed: TimeInterval = 0

    open func instantiate(gameObject: GameObject) -> Self {
        return type(of: self).init()
    }

    open override func onEnable() {

    }

    open override func onDisable() {

    }

    open func onCollisionEnter(_ collision: Collision) {

    }

    open func onCollisionExit(_ collision: Collision) {

    }

    open func onTriggerEnter(_ collider: Collider) {

    }

    open func onTriggerExit(_ collider: Collider) {

    }

    override func internalUpdate() {

        guard let coroutine = currentCoroutine
            else { return }

        timePassed += Time.deltaTime

        guard coroutine.exitCondition(timePassed)
            else { return }

        queuedCoroutine.removeFirst()
        currentCoroutine = nil

        guard let next = nextCoroutine()
            else { return }

        executeCoroutine(next)
    }

    public func queueCoroutine(_ coroutine: Coroutine) {

        queuedCoroutine.append(coroutine)

        if queuedCoroutine.count == 1,
            let next = nextCoroutine() {

            executeCoroutine(next)
        }
    }

    private func nextCoroutine() -> Coroutine? {

        guard let first = queuedCoroutine.first
            else { return nil }

        return first
    }

    private func executeCoroutine(_ coroutine: Coroutine) {

        timePassed = 0
        currentCoroutine = coroutine
        coroutine.execute()
    }
}
