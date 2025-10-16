import Foundation

public typealias CoroutineCondition = (TimeInterval) -> Bool
public typealias CoroutineClosure = () -> Void
public typealias Coroutine = (execute: CoroutineClosure, exitCondition: CoroutineCondition?)
private typealias CoroutineInfo = (coroutine: Coroutine, thread: CoroutineThread)

public enum CoroutineThread {
    case main
    case background
}

open class MonoBehaviour: Behaviour, Instantiable {
    override var order: ComponentOrder {
        return .monoBehaviour
    }

    private var queuedCoroutineInfo = [CoroutineInfo]()
    private var currentCoroutineInfo: CoroutineInfo?
    private var timePassed: TimeInterval = 0
    override public var ignoreUpdates: Bool {
        return false
    }

    override open func destroy() {
        self.currentCoroutineInfo = nil
        self.queuedCoroutineInfo.removeAll()
        super.destroy()
    }

    open func instantiate(gameObject: GameObject) -> Self {
        return type(of: self).init()
    }

    override open func onEnable() {}

    override open func onDisable() {}

    open func onCollisionEnter(_ collision: Collision) {}

    open func onCollisionExit(_ collision: Collision) {}

    open func onTriggerEnter(_ collider: Collider) {}

    open func onTriggerExit(_ collider: Collider) {}

    override func internalUpdate() {
        guard let coroutineInfo = currentCoroutineInfo
        else { return }

        self.timePassed += Time.deltaTime

        let exit: Bool = if let exitCondition = coroutineInfo.coroutine.exitCondition {
            exitCondition(self.timePassed)
        } else {
            true
        }
        guard exit else { return }

        self.queuedCoroutineInfo.removeFirst()
        self.currentCoroutineInfo = nil

        guard let next = nextCoroutineInfo() else { return }

        self.executeCoroutine(next)
    }

    public func startCoroutine(_ coroutine: CoroutineClosure, thread: CoroutineThread = .background) {
        coroutine()
    }

    public func queueCoroutine(_ coroutine: Coroutine, thread: CoroutineThread = .main) {
        self.queuedCoroutineInfo.append((coroutine: coroutine, thread: thread))
        if self.queuedCoroutineInfo.count == 1,
           let next = nextCoroutineInfo()
        {
            self.executeCoroutine(next)
        }
    }

    private func nextCoroutineInfo() -> CoroutineInfo? {
        guard let first = queuedCoroutineInfo.first
        else { return nil }
        return first
    }

    private func executeCoroutine(_ coroutineInfo: CoroutineInfo) {
        self.timePassed = 0
        self.currentCoroutineInfo = coroutineInfo
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
