import SceneKit

/// A type alias for SceneKit actions.
///
/// `Action` represents an animation or effect that can be applied to a GameObject.
/// Actions can animate properties, apply transformations, play sounds, and more.
///
/// ## Topics
///
/// ### Related Types
/// - ``ActionTimingFunction``
/// - ``Ease``
///
/// ## See Also
/// - ``Action/set(ease:)``
public typealias Action = SCNAction

/// A type alias for action timing functions.
///
/// `ActionTimingFunction` defines how an action's animation progresses over time.
/// It takes a normalized time value (0.0 to 1.0) and returns a modified time value
/// to create easing effects.
///
/// - Parameter time: A normalized time value from 0.0 (start) to 1.0 (end).
/// - Returns: A modified time value that determines the animation's interpolation.
///
/// ## See Also
/// - ``Ease``
/// - ``Action/set(ease:)``
public typealias ActionTimingFunction = SCNActionTimingFunction

public extension Action {
    /// Applies an easing function to the action's timing.
    ///
    /// This method sets the action's timing function to create smooth, natural-looking animations
    /// using predefined easing curves. Easing functions control the acceleration and deceleration
    /// of animations.
    ///
    /// - Parameter ease: The easing type to apply to this action.
    ///
    /// - Returns: The action instance with the easing function applied, allowing for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a move action with elastic easing
    /// let moveAction = Action.move(
    ///     to: Vector3(x: 5, y: 0, z: 0),
    ///     duration: 2.0
    /// ).set(ease: .elasticOut)
    ///
    /// gameObject.run(moveAction)
    ///
    /// // Chain multiple actions with different easing
    /// let fadeIn = Action.fadeIn(duration: 0.5).set(ease: .quadIn)
    /// let scale = Action.scale(to: 2.0, duration: 1.0).set(ease: .bounceOut)
    /// let sequence = Action.sequence([fadeIn, scale])
    ///
    /// gameObject.run(sequence)
    ///
    /// // Rotate with custom timing
    /// let rotation = Action.rotateBy(
    ///     x: 0,
    ///     y: .pi * 2,
    ///     z: 0,
    ///     duration: 3.0
    /// ).set(ease: .sineInOut)
    /// ```
    ///
    /// ## Topics
    ///
    /// ### Common Easing Patterns
    ///
    /// - **Linear**: Constant speed throughout the animation
    /// - **Quad/Cubic/Quart/Quint**: Polynomial easing with increasing intensity
    /// - **Sine**: Smooth, gentle easing based on sine waves
    /// - **Expo**: Exponential easing for dramatic effects
    /// - **Back**: Overshooting motion that pulls back before moving forward
    /// - **Bounce**: Bouncing effect at the end of the animation
    /// - **Elastic**: Spring-like oscillating motion
    ///
    /// Each easing type comes in three variants:
    /// - **In**: Acceleration at the start
    /// - **Out**: Deceleration at the end
    /// - **InOut**: Acceleration at start and deceleration at end
    ///
    /// - Note: This method modifies the action and returns self for convenient method chaining.
    ///
    /// - SeeAlso: ``Ease``
    func set(ease: Ease) -> Action {
        self.timingFunction = ease.timingFunction()
        return self
    }
}
