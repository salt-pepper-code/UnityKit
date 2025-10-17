import SceneKit

/// The current phase of a touch event.
///
/// This is an alias for `UITouch.Phase`, providing touch states like began, moved, ended, etc.
public typealias TouchPhase = UITouch.Phase

/// The type of touch input (direct, indirect, stylus, etc.).
///
/// This is an alias for `UITouch.TouchType`, identifying the touch input method.
public typealias TouchType = UITouch.TouchType

/// Represents a single touch input on the screen.
///
/// The `Touch` class encapsulates information about a touch event, including its position,
/// phase, pressure, and movement over time. Use this to track individual fingers or stylus
/// inputs for multi-touch interactions.
///
/// ## Overview
///
/// Touch objects are managed by the ``Input`` system and should be accessed through
/// ``Input/getTouch(_:)`` rather than created directly.
///
/// ## Topics
///
/// ### Touch Properties
/// - ``phase``
/// - ``fingerId``
/// - ``type``
/// - ``tapCount``
///
/// ### Position and Movement
/// - ``position``
/// - ``deltaPosition``
/// - ``position(in:)``
///
/// ### Timing
/// - ``deltaTime``
///
/// ### Pressure and Stylus
/// - ``pressure``
/// - ``maximumPossiblePressure``
/// - ``altitudeAngle``
/// - ``azimuthAngle``
/// - ``radius``
/// - ``radiusVariance``
///
/// ## Example Usage
///
/// ```swift
/// // Get the first touch
/// if let touch = Input.getTouch(0) {
///     print("Touch position: \(touch.position)")
///     print("Touch phase: \(touch.phase)")
///     print("Movement: \(touch.deltaPosition)")
/// }
/// ```
public final class Touch {
    private var previousTime: TimeInterval?
    private var updatedTime: TimeInterval = 0

    var previousPosition: Vector2?
    var updatedPosition: Vector2 = .zero

    /// The position delta since the last frame.
    ///
    /// Returns the change in touch position from the previous frame. This is useful for
    /// implementing drag gestures and tracking finger movement.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let touch = Input.getTouch(0) {
    ///     // Move camera based on touch drag
    ///     camera.position += Vector3(touch.deltaPosition.x, touch.deltaPosition.y, 0)
    /// }
    /// ```
    public var deltaPosition: Vector2 {
        guard let previousPosition,
              let _ = phase
        else { return .zero }

        return self.updatedPosition - previousPosition
    }

    /// The time interval since the touch was last updated.
    ///
    /// Returns the time in seconds between touch updates.
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

    /// A unique identifier for this touch.
    ///
    /// This ID persists throughout the touch's lifetime (from began to ended/cancelled).
    public let fingerId: Int

    /// The underlying UITouch object.
    ///
    /// Provides direct access to the native iOS touch for advanced use cases.
    public let uitouch: UITouch

    /// The view in which the touch began.
    ///
    /// Returns the UIView where this touch originated.
    public var view: UIView? { return self.viewAtBegin }
    private weak var viewAtBegin: UIView?

    /// The current phase of the touch.
    ///
    /// Indicates the touch state: `.began`, `.moved`, `.stationary`, `.ended`, or `.cancelled`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let touch = Input.getTouch(0) {
    ///     switch touch.phase {
    ///     case .began:
    ///         print("Touch started")
    ///     case .moved:
    ///         print("Touch moved")
    ///     case .ended:
    ///         print("Touch ended")
    ///     default:
    ///         break
    ///     }
    /// }
    /// ```
    public var phase: TouchPhase?

    /// The altitude angle of the stylus (in radians).
    ///
    /// For stylus input, returns the angle between the stylus and the screen surface.
    /// A value of 0 indicates the stylus is parallel to the screen.
    public var altitudeAngle: Float { return self.uitouch.altitudeAngle.toFloat() }

    /// The azimuth angle of the stylus (in radians).
    ///
    /// For stylus input, returns the direction of the stylus projection on the screen.
    public var azimuthAngle: Float { return self.uitouch.azimuthAngle(in: self.uitouch.view).toFloat() }

    /// The maximum possible pressure for this touch device.
    ///
    /// Returns the maximum force value the device can detect. Compare with ``pressure``
    /// to determine relative pressure.
    public var maximumPossiblePressure: Float { return self.uitouch.maximumPossibleForce.toFloat() }

    /// The current position of the touch in screen coordinates.
    ///
    /// Returns the touch location in the view's coordinate system.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let touch = Input.getTouch(0) {
    ///     print("Touch at: \(touch.position)")
    /// }
    /// ```
    public var position: Vector2 { return self.uitouch.location(in: self.uitouch.view).toVector2() }

    /// The current pressure of the touch.
    ///
    /// For pressure-sensitive devices (like 3D Touch), returns the force applied.
    /// Returns 0 for non-pressure-sensitive touches.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let touch = Input.getTouch(0) {
    ///     let pressureRatio = touch.pressure / touch.maximumPossiblePressure
    ///     print("Pressure: \(pressureRatio * 100)%")
    /// }
    /// ```
    public var pressure: Float { return self.uitouch.force.toFloat() }

    /// The radius of the touch area.
    ///
    /// Returns an approximation of the touch contact area radius in points.
    public var radius: Float { return self.uitouch.majorRadius.toFloat() }

    /// The variance in the radius measurement.
    ///
    /// Returns the tolerance of the ``radius`` measurement.
    public var radiusVariance: Float { return self.uitouch.majorRadiusTolerance.toFloat() }

    /// The number of taps for this touch.
    ///
    /// Returns the tap count for recognizing single, double, or triple taps.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let touch = Input.getTouch(0), touch.phase == .ended {
    ///     if touch.tapCount == 2 {
    ///         print("Double tap detected")
    ///     }
    /// }
    /// ```
    public var tapCount: Int { return self.uitouch.tapCount }

    /// The type of touch input.
    ///
    /// Returns the touch type: `.direct` (finger), `.indirect` (trackpad), `.stylus`, etc.
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

    /// Returns the touch position in a specific view's coordinate system.
    ///
    /// - Parameter view: The view in which to locate the touch. Pass `nil` to use the window's coordinate system.
    /// - Returns: The touch position as a ``Vector2`` in the specified view's coordinates.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let touch = Input.getTouch(0) {
    ///     let posInWindow = touch.position(in: nil)
    ///     let posInCustomView = touch.position(in: myCustomView)
    /// }
    /// ```
    public func position(in view: UIView?) -> Vector2 {
        return self.uitouch.location(in: view).toVector2()
    }
}

/// Provides access to keyboard, mouse, and touch input.
///
/// The `Input` enum offers static methods and properties to query the current state of input devices.
/// Use this system to detect button presses, track touch events, and read mouse/keyboard input.
///
/// ## Overview
///
/// The Input system is updated automatically each frame by the game engine. All input state
/// queries reflect the current frame's input status. Frame-specific events (like `getKeyDown`)
/// only return true for a single frame when the event occurs.
///
/// ## Topics
///
/// ### Touch Input
/// - ``Touch``
/// - ``touchCount``
/// - ``getTouch(_:)``
/// - ``TouchPhase``
/// - ``TouchType``
///
/// ### Keyboard Input
/// - ``anyKey``
/// - ``anyKeyDown``
/// - ``getKey(_:)``
/// - ``getKeyDown(_:)``
/// - ``getKeyUp(_:)``
///
/// ### Mouse Input
/// - ``mousePosition``
/// - ``getMouseButton(_:)``
/// - ``getMouseButtonDown(_:)``
/// - ``getMouseButtonUp(_:)``
///
/// ## Example Usage
///
/// ```swift
/// // Check for touch input
/// if Input.touchCount > 0 {
///     if let touch = Input.getTouch(0) {
///         print("Touch at: \(touch.position)")
///     }
/// }
///
/// // Check for keyboard input
/// if Input.getKeyDown("SPACE") {
///     player.jump()
/// }
///
/// // Check for mouse button
/// if Input.getMouseButton(0) {
///     print("Left mouse button held")
/// }
///
/// // Detect any key press
/// if Input.anyKeyDown {
///     print("A key was pressed this frame")
/// }
/// ```
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

    /// The current mouse position in screen coordinates.
    ///
    /// Returns the position of the mouse cursor or last touch location as a ``Vector2``.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let mousePos = Input.mousePosition
    /// print("Mouse at: \(mousePos)")
    /// ```
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

    /// Returns `true` if any key is currently held down.
    ///
    /// This remains true for as long as at least one key is pressed.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if Input.anyKey {
    ///     print("At least one key is pressed")
    /// }
    /// ```
    public static var anyKey: Bool {
        state.read { !$0.keysPressed.isEmpty }
    }

    /// Returns `true` during the frame when any key is first pressed.
    ///
    /// This only returns true for a single frame when a key is pressed down.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if Input.anyKeyDown {
    ///     dismissPauseScreen()
    /// }
    /// ```
    public static var anyKeyDown: Bool {
        state.read { !$0.keysDown.isEmpty }
    }

    /// The number of active touches on the screen.
    ///
    /// Returns 0 when no touches are active. Use this to detect multi-touch scenarios.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if Input.touchCount == 2 {
    ///     // Handle pinch gesture
    ///     let touch0 = Input.getTouch(0)
    ///     let touch1 = Input.getTouch(1)
    /// }
    /// ```
    public static var touchCount: Int {
        state.read { $0.touches?.count ?? 0 }
    }

    // MARK: - Keyboard Methods

    /// Returns `true` while the specified key is held down.
    ///
    /// This continues to return true for as long as the key remains pressed. Key names are
    /// case-insensitive.
    ///
    /// - Parameter key: The name of the key to check (e.g., "A", "Space", "Enter").
    /// - Returns: `true` if the key is currently pressed, `false` otherwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Move player while key is held
    /// if Input.getKey("W") {
    ///     player.moveForward()
    /// }
    /// if Input.getKey("A") {
    ///     player.moveLeft()
    /// }
    /// ```
    public static func getKey(_ key: String) -> Bool {
        self.state.read { $0.keysPressed.contains(key.uppercased()) }
    }

    /// Returns `true` during the frame when the specified key is first pressed.
    ///
    /// This only returns true for a single frame when the key is initially pressed down.
    /// Key names are case-insensitive.
    ///
    /// - Parameter key: The name of the key to check (e.g., "Space", "Enter").
    /// - Returns: `true` if the key was pressed this frame, `false` otherwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Jump when space is pressed (not held)
    /// if Input.getKeyDown("SPACE") {
    ///     player.jump()
    /// }
    /// ```
    public static func getKeyDown(_ key: String) -> Bool {
        self.state.read { $0.keysDown.contains(key.uppercased()) }
    }

    /// Returns `true` during the frame when the specified key is released.
    ///
    /// This only returns true for a single frame when the key is released. Key names are
    /// case-insensitive.
    ///
    /// - Parameter key: The name of the key to check (e.g., "Space", "Shift").
    /// - Returns: `true` if the key was released this frame, `false` otherwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Stop charging when key is released
    /// if Input.getKeyUp("SPACE") {
    ///     weapon.fire()
    /// }
    /// ```
    public static func getKeyUp(_ key: String) -> Bool {
        self.state.read { $0.keysUp.contains(key.uppercased()) }
    }

    // MARK: - Mouse Methods

    /// Returns `true` while the specified mouse button is held down.
    ///
    /// Button indices: 0 = left, 1 = right, 2 = middle. This continues to return true for
    /// as long as the button remains pressed.
    ///
    /// - Parameter button: The mouse button index (0-2).
    /// - Returns: `true` if the button is currently pressed, `false` otherwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Continuous fire while left mouse button is held
    /// if Input.getMouseButton(0) {
    ///     weapon.fire()
    /// }
    /// ```
    public static func getMouseButton(_ button: Int) -> Bool {
        guard button >= 0, button < 3 else { return false }
        return self.state.read { $0.mouseButtons[button] }
    }

    /// Returns `true` during the frame when the specified mouse button is first pressed.
    ///
    /// Button indices: 0 = left, 1 = right, 2 = middle. This only returns true for a single
    /// frame when the button is initially pressed.
    ///
    /// - Parameter button: The mouse button index (0-2).
    /// - Returns: `true` if the button was pressed this frame, `false` otherwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Single shot on left mouse button press
    /// if Input.getMouseButtonDown(0) {
    ///     weapon.fireSingleShot()
    /// }
    /// ```
    public static func getMouseButtonDown(_ button: Int) -> Bool {
        guard button >= 0, button < 3 else { return false }
        return self.state.read { $0.mouseButtonsDown[button] }
    }

    /// Returns `true` during the frame when the specified mouse button is released.
    ///
    /// Button indices: 0 = left, 1 = right, 2 = middle. This only returns true for a single
    /// frame when the button is released.
    ///
    /// - Parameter button: The mouse button index (0-2).
    /// - Returns: `true` if the button was released this frame, `false` otherwise.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Release slingshot on mouse button release
    /// if Input.getMouseButtonUp(0) {
    ///     slingshot.release()
    /// }
    /// ```
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

    /// Returns the touch at the specified index.
    ///
    /// Touch indices range from 0 to ``touchCount`` - 1. Use this to access individual touches
    /// for multi-touch interactions.
    ///
    /// - Parameter index: The zero-based index of the touch to retrieve.
    /// - Returns: The ``Touch`` object at the specified index, or `nil` if the index is invalid.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Single touch input
    /// if Input.touchCount > 0 {
    ///     if let touch = Input.getTouch(0) {
    ///         handleTouch(touch)
    ///     }
    /// }
    ///
    /// // Multi-touch (pinch gesture)
    /// if Input.touchCount == 2 {
    ///     let touch0 = Input.getTouch(0)
    ///     let touch1 = Input.getTouch(1)
    ///     if let t0 = touch0, let t1 = touch1 {
    ///         let distance = (t0.position - t1.position).magnitude
    ///         handlePinch(distance: distance)
    ///     }
    /// }
    /// ```
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
