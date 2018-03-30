
import Foundation

public typealias CoroutineCondition = (TimeInterval) -> Bool
public typealias CoroutineClosure = () -> ()
public typealias Coroutine = (execute: CoroutineClosure, exitCondition: CoroutineCondition?)
private typealias CoroutineInfo = (coroutine: Coroutine, thread: CoroutineThread)

public enum CoroutineThread {
    case main
    case background
}

open class MonoBehaviour: Behaviour, Instantiable {

    private var queuedCoroutineInfo = [CoroutineInfo]()
    private var currentCoroutineInfo: CoroutineInfo?
    private var timePassed: TimeInterval = 0

    open override func destroy() {

        currentCoroutineInfo = nil
        queuedCoroutineInfo.removeAll()
        super.destroy()
    }

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

        guard let coroutineInfo = currentCoroutineInfo
            else { return }

        timePassed += Time.deltaTime

        let exit: Bool
        if let exitCondition = coroutineInfo.coroutine.exitCondition {
            exit = exitCondition(timePassed)
        } else {
            exit = true
        }

        guard exit
            else { return }

        queuedCoroutineInfo.removeFirst()
        currentCoroutineInfo = nil

        guard let next = nextCoroutineInfo()
            else { return }

        executeCoroutine(next)
    }

    public func startCoroutine(_ coroutine: CoroutineClosure, thread: CoroutineThread = .background) {
        coroutine()
    }

    public func queueCoroutine(_ coroutine: Coroutine, thread: CoroutineThread = .main) {

        queuedCoroutineInfo.append((coroutine: coroutine, thread: thread))

        if queuedCoroutineInfo.count == 1,
            let next = nextCoroutineInfo() {

            executeCoroutine(next)
        }
    }

    private func nextCoroutineInfo() -> CoroutineInfo? {

        guard let first = queuedCoroutineInfo.first
            else { return nil }

        return first
    }

    private func executeCoroutine(_ coroutineInfo: CoroutineInfo) {

        timePassed = 0
        currentCoroutineInfo = coroutineInfo

        switch coroutineInfo.thread {
        case .main:
            coroutineInfo.coroutine.execute()
        case .background:
            DispatchQueue.global(qos: .background).async {
                coroutineInfo.coroutine.execute()
            }
        }
    }
}
