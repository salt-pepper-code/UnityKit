import SceneKit

public typealias Action = SCNAction
public typealias ActionTimingFunction = SCNActionTimingFunction

extension Action {
    public func set(ease: Ease) -> Action {
        self.timingFunction = ease.timingFunction()
        return self
    }
}
