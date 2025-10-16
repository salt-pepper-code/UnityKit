import SceneKit

public typealias TouchPhase = UITouch.Phase
public typealias TouchType = UITouch.TouchType

public final class Touch {
    private var previousTime: TimeInterval?
    private var updatedTime: TimeInterval = 0

    var previousPosition: Vector2?
    var updatedPosition: Vector2 = .zero

    public var deltaPosition: Vector2 {
        guard let previousPosition,
              let _ = phase
        else { return .zero }

        return self.updatedPosition - previousPosition
    }

    public internal(set) var deltaTime: TimeInterval {
        get {
            guard let previousTime
            else { return 0 }

            return self.updatedTime - previousTime
        }
        set {
            self.previousTime = self.updatedTime != 0 ? self.updatedTime : nil
            self.updatedTime = newValue
        }
    }

    public let fingerId: Int
    public let uitouch: UITouch
    public var view: UIView? { return self.viewAtBegin }
    private weak var viewAtBegin: UIView?

    public var phase: TouchPhase?
    public var altitudeAngle: Float { return self.uitouch.altitudeAngle.toFloat() }
    public var azimuthAngle: Float { return self.uitouch.azimuthAngle(in: self.uitouch.view).toFloat() }
    public var maximumPossiblePressure: Float { return self.uitouch.maximumPossibleForce.toFloat() }
    public var position: Vector2 { return self.uitouch.location(in: self.uitouch.view).toVector2() }
    public var pressure: Float { return self.uitouch.force.toFloat() }
    public var radius: Float { return self.uitouch.majorRadius.toFloat() }
    public var radiusVariance: Float { return self.uitouch.majorRadiusTolerance.toFloat() }
    public var tapCount: Int { return self.uitouch.tapCount }
    public var type: TouchType { return self.uitouch.type }

    init(_ uitouch: UITouch, index: Int) {
        self.uitouch = uitouch
        self.fingerId = index
        self.viewAtBegin = uitouch.view
        self.phase = uitouch.phase
        self.updatedTime = uitouch.timestamp
        self.updatedPosition = uitouch.location(in: uitouch.view).toVector2()
    }

    func updateTouch(_ touch: Touch) {
        if touch.view != self.view {
            self.phase = .cancelled
        }
        self.deltaTime = touch.updatedTime
        self.updatedPosition = touch.position
    }

    public func position(in view: UIView?) -> Vector2 {
        return self.uitouch.location(in: view).toVector2()
    }
}

public enum Input {
    private struct State {
        var touches: [Touch]?
        var stackUpdates = [TouchPhase: [Touch]]()
        var clearNextFrame = false
        var keysPressed: Set<String> = []
        var keysDown: Set<String> = []
        var keysUp: Set<String> = []
        var mouseButtons: [Bool] = [false, false, false]
        var mouseButtonsDown: [Bool] = [false, false, false]
        var mouseButtonsUp: [Bool] = [false, false, false]
        var mousePosition: Vector2 = .zero
    }

    private static let state = Synchronized(State(), label: "com.unitykit.input")

    public static var mousePosition: Vector2 {
        get {
            state.read { $0.mousePosition }
        }
        set {
            state.write { state in
                state.mousePosition = newValue
            }
        }
    }

    public static var anyKey: Bool {
        state.read { !$0.keysPressed.isEmpty }
    }

    public static var anyKeyDown: Bool {
        state.read { !$0.keysDown.isEmpty }
    }

    public static var touchCount: Int {
        state.read { $0.touches?.count ?? 0 }
    }

    // MARK: - Keyboard Methods

    /// Returns true while the user holds down the key identified by name
    public static func getKey(_ key: String) -> Bool {
        self.state.read { $0.keysPressed.contains(key.uppercased()) }
    }

    /// Returns true during the frame the user starts pressing down the key
    public static func getKeyDown(_ key: String) -> Bool {
        self.state.read { $0.keysDown.contains(key.uppercased()) }
    }

    /// Returns true during the frame the user releases the key
    public static func getKeyUp(_ key: String) -> Bool {
        self.state.read { $0.keysUp.contains(key.uppercased()) }
    }

    // MARK: - Mouse Methods

    /// Returns whether the given mouse button is held down (0 = left, 1 = right, 2 = middle)
    public static func getMouseButton(_ button: Int) -> Bool {
        guard button >= 0, button < 3 else { return false }
        return self.state.read { $0.mouseButtons[button] }
    }

    /// Returns true during the frame the user pressed the given mouse button
    public static func getMouseButtonDown(_ button: Int) -> Bool {
        guard button >= 0, button < 3 else { return false }
        return self.state.read { $0.mouseButtonsDown[button] }
    }

    /// Returns true during the frame the user releases the given mouse button
    public static func getMouseButtonUp(_ button: Int) -> Bool {
        guard button >= 0, button < 3 else { return false }
        return self.state.read { $0.mouseButtonsUp[button] }
    }

    // MARK: - Internal Update Methods

    static func setKeyDown(_ key: String) {
        let upperKey = key.uppercased()
        self.state.write {
            $0.keysPressed.insert(upperKey)
            $0.keysDown.insert(upperKey)
        }
    }

    static func setKeyUp(_ key: String) {
        let upperKey = key.uppercased()
        self.state.write {
            $0.keysPressed.remove(upperKey)
            $0.keysUp.insert(upperKey)
        }
    }

    static func setMouseButtonDown(_ button: Int) {
        guard button >= 0, button < 3 else { return }
        self.state.write {
            $0.mouseButtons[button] = true
            $0.mouseButtonsDown[button] = true
        }
    }

    static func setMouseButtonUp(_ button: Int) {
        guard button >= 0, button < 3 else { return }
        self.state.write {
            $0.mouseButtons[button] = false
            $0.mouseButtonsUp[button] = true
        }
    }

    static func setMousePosition(_ position: Vector2) {
        self.mousePosition = position
    }

    static func update() {
        var shouldRecurse = false

        self.state.write { s in
            // Clear frame-specific input states
            s.keysDown.removeAll()
            s.keysUp.removeAll()
            s.mouseButtonsDown = [false, false, false]
            s.mouseButtonsUp = [false, false, false]

            guard !s.clearNextFrame else {
                self.clear(state: &s)
                return
            }

            if let currentTouches = s.touches {
                if let first = s.stackUpdates.first {
                    s.stackUpdates.removeValue(forKey: first.key)

                    for (index, touch) in currentTouches.enumerated() {
                        let updatedTouch = first.value[index]
                        touch.phase = first.key
                        switch first.key {
                        case .moved:
                            touch.previousPosition = touch.position
                        case .ended:
                            touch.previousPosition = touch.position
                            s.clearNextFrame = true
                        case .cancelled:
                            self.clear(state: &s)
                        default:
                            break
                        }
                        touch.updateTouch(updatedTouch)
                    }
                } else {
                    for currentTouch in currentTouches {
                        currentTouch.phase = .stationary
                    }
                }
            } else if let first = s.stackUpdates.first,
                      first.value.first?.phase == .began
            {
                s.touches = first.value
                shouldRecurse = true
            }
        }

        // Handle recursive update call outside the synchronized block to avoid deadlock
        if shouldRecurse {
            self.update()
        }
    }

    static func stackTouches(_ touches: [Touch], phase: TouchPhase) {
        self.state.write { s in
            if let currentTouches = s.touches,
               let currentFirst = currentTouches.first,
               let first = touches.first
            {
                if currentFirst.view != first.view {
                    for currentTouch in currentTouches {
                        currentTouch.phase = .ended
                    }
                    s.clearNextFrame = true
                    return
                }
            }

            switch phase {
            case .began:
                if s.touches != nil || s.stackUpdates.count > 0 {
                    self.clear(state: &s)
                }
            default:
                break
            }
            s.stackUpdates[phase] = touches
        }
    }

    public static func getTouch(_ index: Int) -> Touch? {
        self.state.read { s in
            guard let touches = s.touches, index < touches.count else { return nil }
            return touches[index]
        }
    }

    static func clear() {
        self.state.write { s in self.clear(state: &s) }
    }

    private static func clear(state: inout State) {
        state.clearNextFrame = false
        state.stackUpdates.removeAll()
        state.touches = nil
    }

    static func setTouches(_ touches: [Touch]) {
        self.state.write { $0.touches = touches }
    }

    // MARK: - Testing Helpers

    static func resetForTesting() {
        self.state.write { s in
            self.clear(state: &s)
            s.keysPressed.removeAll()
            s.keysDown.removeAll()
            s.keysUp.removeAll()
            s.mouseButtons = [false, false, false]
            s.mouseButtonsDown = [false, false, false]
            s.mouseButtonsUp = [false, false, false]
            s.mousePosition = .zero
        }
    }
}
