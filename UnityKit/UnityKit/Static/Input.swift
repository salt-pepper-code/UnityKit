
import SceneKit

public typealias TouchPhase = UITouchPhase
public typealias TouchType = UITouchType

public final class Touch {

    fileprivate var previousTime: TimeInterval?
    fileprivate var updatedTime: TimeInterval = 0

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
    public var view: UIView? { return viewAtBegin }
    fileprivate weak var viewAtBegin: UIView?

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
        fingerId = index
        viewAtBegin = uitouch.view
        phase = uitouch.phase
        updatedTime = uitouch.timestamp
        updatedPosition = uitouch.location(in: uitouch.view).toVector2()
    }

    internal func updateTouch(_ touch: Touch) {

        if touch.view != view {
            phase = .cancelled
        }
        deltaTime = touch.updatedTime
        updatedPosition = touch.position
    }

    public func position(in view: UIView?) -> Vector2 {
        return uitouch.location(in: view).toVector2()
    }

}

public final class Input {

    private static var touches: [Touch]?
    private static var stackUpdates = [TouchPhase: [Touch]]()
    private static var clearNextFrame = false

    public static var touchCount: Int {

        guard let touches = touches
            else { return 0 }

        return touches.count
    }

    internal static func update() {

        guard !clearNextFrame else {
            clear()
            return
        }

        if let touches = touches {

            Debug.log(touches.count)
            
            if let first = stackUpdates.first {

                for (index, touch) in touches.enumerated() {

                    let updatedTouch = first.value[index]
                    touch.phase = first.key
                    switch first.key {
                    case .began:
                        Debug.log("update began")
                    case .moved:
                        Debug.log("update moved")
                        touch.previousPosition = touch.position
                    case .ended:
                        Debug.log("update ended")
                        touch.previousPosition = touch.position
                        clearNextFrame = true
                    case .cancelled:
                        Debug.log("update cancelled")
                        clear()
                    default:
                        break
                    }
                    touch.updateTouch(updatedTouch)
                }

                stackUpdates.removeValue(forKey: first.key)

            } else {

                Debug.log("update stationary")

                touches.forEach {
                    $0.phase = .stationary
                }
            }

        } else if let first = stackUpdates.first,
            first.value.first?.phase == .began {

            Debug.log("setTouches")
            setTouches(first.value)
            update()
        }
    }

    internal static func stackTouches(_ touches: [Touch], phase: TouchPhase) {

        if let currentTouches = self.touches,
            let currentFirst = currentTouches.first,
            let first = touches.first {

            if currentFirst.view != first.view {
                currentTouches.forEach {
                    $0.phase = .ended
                }
                clearNextFrame = true
                Debug.log("different view")
                return
            }
        }

        switch phase {
        case .began:
            Debug.log("stack began")
            if self.touches != nil || stackUpdates.count > 0 {
                clear()
            }
        case .moved:
            Debug.log("stack moved")
        case .ended:
            Debug.log("stack ended")
        case .cancelled:
            Debug.log("stack cancelled")
        default:
            break
        }
        stackUpdates[phase] = touches
    }

    public static func getTouch(_ index: Int) -> Touch? {
        return touches?[index]
    }

    internal static func clear() {
        Debug.log("clear")
        clearNextFrame = false
        stackUpdates.removeAll()
        touches = nil
    }

    internal static func setTouches(_ touches: [Touch]) {
        self.touches = touches
    }
}

