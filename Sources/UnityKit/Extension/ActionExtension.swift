import SceneKit

public typealias Action = SCNAction
public typealias ActionTimingFunction = SCNActionTimingFunction

public extension Action {
    func set(ease: Ease) -> Action {
        self.timingFunction = ease.timingFunction()
        return self
    }
}
