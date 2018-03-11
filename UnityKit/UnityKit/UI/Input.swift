
import SceneKit

public typealias TouchPhase = UITouchPhase
public typealias TouchType = UITouchType

public class Touch {

    private var previousTime: TimeInterval?
    private var updatedTime: TimeInterval = 0

    internal var previousPosition: Vector2?
    internal var updatedPosition: Vector2 = .zero

    public var deltaPosition: Vector2 {
        guard let previousPosition = previousPosition,
            let _ = phase
            else { return .zero }

        return updatedPosition - previousPosition
    }
    internal(set) public var deltaTime: TimeInterval {
        get {
            guard let previousTime = previousTime
                else { return 0 }

            return updatedTime - previousTime
        }
        set {
            previousTime = updatedTime != 0 ? updatedTime : nil
            updatedTime = newValue
        }
    }

    public let fingerId: Int
    public let uitouch: UITouch

    public var phase: TouchPhase?
    public var altitudeAngle: Float { return uitouch.altitudeAngle.toFloat() }
    public var azimuthAngle: Float { return uitouch.azimuthAngle(in: uitouch.view).toFloat() }
    public var maximumPossiblePressure: Float { return uitouch.maximumPossibleForce.toFloat() }
    public var position: Vector2 { return uitouch.location(in: uitouch.view).toVector2() }
    public var pressure: Float { return uitouch.force.toFloat() }
    public var radius: Float { return uitouch.majorRadius.toFloat() }
    public var radiusVariance: Float { return uitouch.majorRadiusTolerance.toFloat() }
    public var tapCount: Int { return uitouch.tapCount }
    public var type: TouchType { return uitouch.type }

    internal init(_ uitouch: UITouch, index: Int) {
        self.uitouch = uitouch
        self.fingerId = index
        self.updatedTime = uitouch.timestamp
    }
}

public class Input {

    public static var touchCount: Int {

        guard let touches = touches
            else { return 0 }

        return touches.count
    }

    internal static var touches: [Touch]?

    internal static func preUpdateTouches(_ phase: TouchPhase) {

        touches?.forEach { touch in

            touch.phase = phase
            touch.deltaTime = touch.uitouch.timestamp
            touch.updatedPosition = touch.uitouch.location(in: touch.uitouch.view).toVector2()

            if phase == .moved {
                touch.previousPosition = touch.uitouch.previousLocation(in: touch.uitouch.view).toVector2()
            }
        }
    }

    internal static func endUpdateTouches() {

        var shouldClear = false
        touches?.forEach { touch in
            guard let phase = touch.phase
                else { return }

            switch phase {
            case .moved, .began:
                touch.phase = .stationary
            case .ended, .cancelled:
                touch.phase = nil
                shouldClear = true
            case .stationary:
                touch.previousPosition = touch.updatedPosition
            }
        }

        if shouldClear {
            clear()
        }
    }

    public static func getTouch(_ index: Int) -> Touch? {
        return touches?[index]
    }

    internal static func clear() {
        self.touches = nil
    }

    internal static func setTouches(_ touches: [Touch]) {
        self.touches = touches
    }
}
