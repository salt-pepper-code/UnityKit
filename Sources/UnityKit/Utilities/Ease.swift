import Foundation

/// Easing functions for creating smooth, natural-looking animations.
///
/// `Ease` provides a comprehensive collection of easing functions that control the acceleration
/// and deceleration of animations. Each easing type defines how an animation progresses from
/// start to finish, creating effects ranging from simple linear motion to complex bouncing
/// and elastic movements.
///
/// ## Overview
///
/// Easing functions are essential for creating polished, professional animations. Instead of
/// animations that move at a constant speed (linear), easing functions provide acceleration
/// and deceleration patterns that feel more natural and engaging.
///
/// ### Easing Variants
///
/// Most easing types come in three variants:
/// - **In**: Starts slowly and accelerates toward the end
/// - **Out**: Starts quickly and decelerates toward the end
/// - **InOut**: Accelerates at the start and decelerates at the end
///
/// ## Topics
///
/// ### Basic Easing
/// - ``linear``
///
/// ### Quadratic Easing
/// - ``quadIn``
/// - ``quadOut``
/// - ``quadInOut``
///
/// ### Cubic Easing
/// - ``cubicIn``
/// - ``cubicOut``
/// - ``cubicInOut``
///
/// ### Quartic Easing
/// - ``quartIn``
/// - ``quartOut``
/// - ``quartInOut``
///
/// ### Quintic Easing
/// - ``quintIn``
/// - ``quintOut``
/// - ``quintInOut``
///
/// ### Sinusoidal Easing
/// - ``sineIn``
/// - ``sineOut``
/// - ``sineInOut``
///
/// ### Exponential Easing
/// - ``expoIn``
/// - ``expoOut``
/// - ``expoInOut``
///
/// ### Circular Easing
/// - ``circleIn``
/// - ``circleOut``
/// - ``circleInOut``
///
/// ### Back Easing
/// - ``backIn``
/// - ``backOut``
/// - ``backInOut``
///
/// ### Elastic Easing
/// - ``elasticIn``
/// - ``elasticOut``
/// - ``elasticInOut``
///
/// ### Bounce Easing
/// - ``bounceIn``
/// - ``bounceOut``
/// - ``bounceInOut``
///
/// ### Custom Easing
/// - ``custom(_:)``
///
/// ## Example
///
/// ```swift
/// // Create a bouncing entrance animation
/// let dropAction = Action.moveBy(
///     x: 0,
///     y: -5,
///     z: 0,
///     duration: 1.0
/// ).set(ease: .bounceOut)
///
/// gameObject.run(dropAction)
///
/// // Create a smooth, natural fade-in
/// let fadeAction = Action.fadeIn(duration: 0.8).set(ease: .sineOut)
///
/// // Elastic scaling for attention-grabbing effects
/// let scaleAction = Action.scale(to: 1.5, duration: 1.2).set(ease: .elasticOut)
///
/// // Combine different easing types
/// let slideIn = Action.moveBy(x: 10, y: 0, z: 0, duration: 0.5).set(ease: .backOut)
/// let pulse = Action.sequence([
///     Action.scale(to: 1.2, duration: 0.3).set(ease: .quadOut),
///     Action.scale(to: 1.0, duration: 0.3).set(ease: .quadIn)
/// ])
/// let combo = Action.sequence([slideIn, pulse])
/// ```
///
/// - SeeAlso: ``Action/set(ease:)``
public enum Ease {
    /// Linear easing with constant speed.
    ///
    /// Produces an animation that moves at a constant rate from start to finish
    /// with no acceleration or deceleration.
    ///
    /// **Use cases**: Loading indicators, mechanical movements, when you need
    /// predictable constant-speed animation.
    case linear

    /// Back easing that overshoots and then returns (out).
    ///
    /// The animation overshoots the target value slightly before settling at the final position.
    /// Creates a subtle "pull-back" effect at the end.
    ///
    /// **Use cases**: UI elements sliding into position, drawer animations,
    /// emphasizing the final resting position.
    case backOut

    /// Back easing that pulls back before starting (in).
    ///
    /// The animation moves backward slightly before accelerating toward the target.
    /// Creates a "wind-up" effect at the beginning.
    ///
    /// **Use cases**: Object launching, preparing for movement, anticipation effects.
    case backIn

    /// Back easing with pull-back at both ends (in-out).
    ///
    /// Combines backIn and backOut, pulling back at the start and overshooting at the end.
    ///
    /// **Use cases**: Modal presentations, emphasized transitions.
    case backInOut

    /// Bounce easing that bounces at the end (out).
    ///
    /// The animation bounces several times before settling at the final position,
    /// like a ball hitting the ground.
    ///
    /// **Use cases**: Objects landing, playful UI interactions, game elements.
    case bounceOut

    /// Bounce easing that bounces at the start (in).
    ///
    /// The animation starts with bouncing motion before reaching the target.
    ///
    /// **Use cases**: Reverse bounce effects, object takeoff animations.
    case bounceIn

    /// Bounce easing with bounces at both ends (in-out).
    ///
    /// Combines bounceIn and bounceOut for bouncing at both start and end.
    ///
    /// **Use cases**: Emphasized bouncing effects, playful two-way transitions.
    case bounceInOut

    /// Circular easing with deceleration at the end (out).
    ///
    /// Uses a circular curve to create smooth deceleration. Gentler than exponential easing.
    ///
    /// **Use cases**: Natural-feeling UI transitions, smooth stops.
    case circleOut

    /// Circular easing with acceleration at the start (in).
    ///
    /// Uses a circular curve to create smooth acceleration from a standstill.
    ///
    /// **Use cases**: Natural-feeling starts, gradual acceleration.
    case circleIn

    /// Circular easing with acceleration and deceleration (in-out).
    ///
    /// Combines circleIn and circleOut for smooth acceleration and deceleration.
    ///
    /// **Use cases**: Smooth, natural two-way transitions.
    case circleInOut

    /// Cubic easing with deceleration at the end (out).
    ///
    /// Uses a cubic curve (t³) for smooth deceleration. Stronger than quadratic.
    ///
    /// **Use cases**: General-purpose smooth stops, UI element animations.
    case cubicOut

    /// Cubic easing with acceleration at the start (in).
    ///
    /// Uses a cubic curve for smooth acceleration from rest.
    ///
    /// **Use cases**: General-purpose smooth starts.
    case cubicIn

    /// Cubic easing with acceleration and deceleration (in-out).
    ///
    /// Combines cubicIn and cubicOut for balanced ease-in and ease-out.
    ///
    /// **Use cases**: Default smooth animations, professional transitions.
    case cubicInOut

    /// Elastic easing that oscillates at the end (out).
    ///
    /// Creates a spring-like oscillating motion that settles at the target,
    /// like a rubber band snapping into place.
    ///
    /// **Use cases**: Attention-grabbing effects, playful UI, game power-ups.
    case elasticOut

    /// Elastic easing that oscillates at the start (in).
    ///
    /// Creates oscillating motion at the beginning before reaching the target.
    ///
    /// **Use cases**: Wind-up effects, dramatic entrances.
    case elasticIn

    /// Elastic easing with oscillation at both ends (in-out).
    ///
    /// Combines elasticIn and elasticOut for oscillation at start and end.
    ///
    /// **Use cases**: Highly emphasized elastic effects.
    case elasticInOut

    /// Exponential easing with deceleration at the end (out).
    ///
    /// Uses an exponential curve for dramatic deceleration. Very strong easing effect.
    ///
    /// **Use cases**: Rapid movements that come to a quick stop, dramatic transitions.
    case expoOut

    /// Exponential easing with acceleration at the start (in).
    ///
    /// Uses an exponential curve for dramatic acceleration from a very slow start.
    ///
    /// **Use cases**: Dramatic entrances, rocket launches, explosive movements.
    case expoIn

    /// Exponential easing with acceleration and deceleration (in-out).
    ///
    /// Combines expoIn and expoOut for dramatic acceleration and deceleration.
    ///
    /// **Use cases**: Highly dramatic transitions, fast-paced animations.
    case expoInOut

    /// Quadratic easing with deceleration at the end (out).
    ///
    /// Uses a quadratic curve (t²) for gentle deceleration. Subtle easing effect.
    ///
    /// **Use cases**: Subtle smooth stops, gentle UI transitions.
    case quadOut

    /// Quadratic easing with acceleration at the start (in).
    ///
    /// Uses a quadratic curve for gentle acceleration from rest.
    ///
    /// **Use cases**: Subtle smooth starts, gentle beginnings.
    case quadIn

    /// Quadratic easing with acceleration and deceleration (in-out).
    ///
    /// Combines quadIn and quadOut for subtle ease-in and ease-out.
    ///
    /// **Use cases**: Gentle smooth animations, subtle transitions.
    case quadInOut

    /// Quartic easing with deceleration at the end (out).
    ///
    /// Uses a quartic curve (t⁴) for strong deceleration. Stronger than cubic.
    ///
    /// **Use cases**: Strong smooth stops, emphasized deceleration.
    case quartOut

    /// Quartic easing with acceleration at the start (in).
    ///
    /// Uses a quartic curve for strong acceleration from rest.
    ///
    /// **Use cases**: Strong smooth starts, emphasized acceleration.
    case quartIn

    /// Quartic easing with acceleration and deceleration (in-out).
    ///
    /// Combines quartIn and quartOut for strong ease-in and ease-out.
    ///
    /// **Use cases**: Emphasized smooth animations, strong transitions.
    case quartInOut

    /// Quintic easing with deceleration at the end (out).
    ///
    /// Uses a quintic curve (t⁵) for very strong deceleration. Strongest polynomial easing.
    ///
    /// **Use cases**: Very strong smooth stops, highly emphasized deceleration.
    case quintOut

    /// Quintic easing with acceleration at the start (in).
    ///
    /// Uses a quintic curve for very strong acceleration from rest.
    ///
    /// **Use cases**: Very strong smooth starts, highly emphasized acceleration.
    case quintIn

    /// Quintic easing with acceleration and deceleration (in-out).
    ///
    /// Combines quintIn and quintOut for very strong ease-in and ease-out.
    ///
    /// **Use cases**: Highly emphasized smooth animations, strongest transitions.
    case quintInOut

    /// Sinusoidal easing with deceleration at the end (out).
    ///
    /// Uses a sine curve for very smooth, gentle deceleration. Most natural-feeling easing.
    ///
    /// **Use cases**: Natural, organic movements, camera movements, recommended for most UI.
    case sineOut

    /// Sinusoidal easing with acceleration at the start (in).
    ///
    /// Uses a sine curve for very smooth, gentle acceleration.
    ///
    /// **Use cases**: Natural starts, organic acceleration, gentle beginnings.
    case sineIn

    /// Sinusoidal easing with acceleration and deceleration (in-out).
    ///
    /// Combines sineIn and sineOut for the smoothest, most natural ease-in and ease-out.
    ///
    /// **Use cases**: Natural transitions, organic movements, recommended default for smooth animations.
    case sineInOut

    /// Custom easing with a user-defined timing function.
    ///
    /// Allows you to provide your own timing function for complete control over the easing curve.
    ///
    /// - Parameter function: A custom `ActionTimingFunction` that takes a time value (0.0-1.0)
    ///   and returns the modified time value.
    ///
    /// **Example**:
    /// ```swift
    /// // Create a custom stepped easing
    /// let customEase = Ease.custom { time in
    ///     return floor(time * 4) / 4 // Creates 4 steps
    /// }
    ///
    /// let action = Action.fadeIn(duration: 1.0).set(ease: customEase)
    /// ```
    case custom(ActionTimingFunction)

    /// Converts the easing type to an ActionTimingFunction.
    ///
    /// This method returns the underlying timing function that can be applied to SceneKit actions.
    /// You typically don't need to call this directly; instead, use ``Action/set(ease:)`` which
    /// calls this method internally.
    ///
    /// - Returns: An `ActionTimingFunction` closure that defines the easing curve.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Direct usage (not common)
    /// let ease = Ease.bounceOut
    /// let timingFunc = ease.timingFunction()
    ///
    /// let action = Action.moveBy(x: 5, y: 0, z: 0, duration: 1.0)
    /// action.timingFunction = timingFunc
    ///
    /// // Preferred usage via set(ease:)
    /// let action = Action.moveBy(x: 5, y: 0, z: 0, duration: 1.0)
    ///     .set(ease: .bounceOut)
    /// ```
    ///
    /// - SeeAlso: ``Action/set(ease:)``
    public func timingFunction() -> ActionTimingFunction {
        switch self {
        case .linear: return Ease._linear
        case .backOut: return Ease._backOut
        case .backIn: return Ease._backIn
        case .backInOut: return Ease._backInOut
        case .bounceOut: return Ease._bounceOut
        case .bounceIn: return Ease._bounceIn
        case .bounceInOut: return Ease._bounceInOut
        case .circleOut: return Ease._circleOut
        case .circleIn: return Ease._circleIn
        case .circleInOut: return Ease._circleInOut
        case .cubicOut: return Ease._cubicOut
        case .cubicIn: return Ease._cubicIn
        case .cubicInOut: return Ease._cubicInOut
        case .elasticOut: return Ease._elasticOut
        case .elasticIn: return Ease._elasticIn
        case .elasticInOut: return Ease._elasticInOut
        case .expoOut: return Ease._expoOut
        case .expoIn: return Ease._expoIn
        case .expoInOut: return Ease._expoInOut
        case .quadOut: return Ease._quadOut
        case .quadIn: return Ease._quadIn
        case .quadInOut: return Ease._quadInOut
        case .quartOut: return Ease._quartOut
        case .quartIn: return Ease._quartIn
        case .quartInOut: return Ease._quartInOut
        case .quintOut: return Ease._quintOut
        case .quintIn: return Ease._quintIn
        case .quintInOut: return Ease._quintInOut
        case .sineOut: return Ease._sineOut
        case .sineIn: return Ease._sineIn
        case .sineInOut: return Ease._sineInOut
        case .custom(let function): return function
        }
    }

    private static var _linear: ActionTimingFunction = { (n: Float) -> Float in
        return n
    }

    private static var _quadIn: ActionTimingFunction = { (n: Float) -> Float in
        return n * n
    }

    private static var _quadOut: ActionTimingFunction = { (n: Float) -> Float in
        return n * (2 - n)
    }

    private static var _quadInOut: ActionTimingFunction = { (n: Float) -> Float in
        var n = n * 2
        if n < 1 {
            return 0.5 * n * n * n
        }
        n -= 1
        return -0.5 * (n * (n - 2) - 1)
    }

    private static var _cubicIn: ActionTimingFunction = { (n: Float) -> Float in
        return n * n * n
    }

    private static var _cubicOut: ActionTimingFunction = { (n: Float) -> Float in
        let n = n - 1
        return n * n * n + 1
    }

    private static var _cubicInOut: ActionTimingFunction = { (n: Float) -> Float in
        var n = n * 2
        if n < 1 {
            return 0.5 * n * n * n
        }
        n -= 2
        return 0.5 * (n * n * n + 2)
    }

    private static var _quartIn: ActionTimingFunction = { (n: Float) -> Float in
        return n * n * n * n
    }

    private static var _quartOut: ActionTimingFunction = { (n: Float) -> Float in
        return 1 - _quartIn(n - 1)
    }

    private static var _quartInOut: ActionTimingFunction = { (n: Float) -> Float in
        var n = n * 2
        if n < 1 {
            return 0.5 * _quartIn(n)
        }
        n -= 2
        return -0.5 * (_quartIn(n) - 2)
    }

    private static var _quintIn: ActionTimingFunction = { (n: Float) -> Float in
        return n * n * n * n * n
    }

    private static var _quintOut: ActionTimingFunction = { (n: Float) -> Float in
        return _quintIn(n - 1) + 1
    }

    private static var _quintInOut: ActionTimingFunction = { (n: Float) -> Float in
        var n = n * 2
        if n < 1 {
            return 0.5 * _quintIn(n)
        }
        n -= 2
        return 0.5 * (_quintIn(n) + 2)
    }

    private static var _sineIn: ActionTimingFunction = { (n: Float) -> Float in
        return 1 - cos(n * .pi / 2)
    }

    private static var _sineOut: ActionTimingFunction = { (n: Float) -> Float in
        return sin(n * .pi / 2)
    }

    private static var _sineInOut: ActionTimingFunction = { (n: Float) -> Float in
        return 0.5 * (1 - cos(.pi * n))
    }

    private static var _expoIn: ActionTimingFunction = { (n: Float) -> Float in
        return n == 0 ? 0 : pow(1024, n - 1)
    }

    private static var _expoOut: ActionTimingFunction = { (n: Float) -> Float in
        return n == 1 ? n : 1 - pow(2, -10 * n)
    }

    private static var _expoInOut: ActionTimingFunction = { (n: Float) -> Float in
        if n == 0 {
            return 0
        }
        if n == 1 {
            return 1
        }
        let n = n * 2
        if n < 1 {
            return 0.5 * pow(1024, n - 1)
        }
        return 0.5 * (-pow(2, -10 * (n - 1)) + 2)
    }

    private static var _circleIn: ActionTimingFunction = { (n: Float) -> Float in
        return 1 - sqrt(1 - n * n)
    }

    private static var _circleOut: ActionTimingFunction = { (n: Float) -> Float in
        let n = n - 1
        return sqrt(1 - (n * n))
    }

    private static var _circleInOut: ActionTimingFunction = { (n: Float) -> Float in
        var n = n * 2
        if n < 1 {
            return -0.5 * (sqrt(1 - n * n) - 1)
        }
        n -= 2
        return 0.5 * (sqrt(1 - n * n) + 1)
    }

    private static var _backIn: ActionTimingFunction = { (n: Float) -> Float in
        let s: Float = 1.70158
        return n * n * (((s + 1) * n) - s)
    }

    private static var _backOut: ActionTimingFunction = { (n: Float) -> Float in
        let n = n - 1
        let s: Float = 1.70158
        return (n * n * (((s + 1) * n) + s)) + 1
    }

    private static var _backInOut: ActionTimingFunction = { (n: Float) -> Float in
        var n = n * 2
        let s: Float = 1.70158 * 1.525
        if n < 1 {
            return 0.5 * (n * n * ((s + 1) * n - s))
        }
        n -= 2
        return 0.5 * (n * n * ((s + 1) * n + s) + 2)
    }

    private static var _bounceIn: ActionTimingFunction = { (n: Float) -> Float in
        return 1 - _bounceOut(1 - n)
    }

    private static var _bounceOut: ActionTimingFunction = { (n: Float) -> Float in
        var n = n
        if n < 1 / 2.75 {
            return 7.5625 * n * n
        } else if n < 2 / 2.75 {
            n -= 1.5 / 2.75
            return 7.5625 * n * n + 0.75
        } else if n < 2.5 / 2.75 {
            n -= 2.25 / 2.75
            return 7.5625 * n * n + 0.9375
        } else {
            n -= 2.625 / 2.75
            return 7.5625 * n * n + 0.984375
        }
    }

    private static var _bounceInOut: ActionTimingFunction = { (n: Float) -> Float in
        if n < 0.5 {
            return _bounceIn(n * 2) * 0.5
        }
        return _bounceOut(n * 2 - 1) * 0.5 + 0.5
    }

    private static var _elasticIn: ActionTimingFunction = { (n: Float) -> Float in
        if n == 0 {
            return 0
        }
        if n == 1 {
            return 1
        }
        let n = n - 1
        let p: Float = 0.4
        let s: Float = p / 4
        let a: Float = 1
        return -(a * pow(2, 10 * n) * sin((n - s) * (2 * .pi) / p))
    }

    private static var _elasticOut: ActionTimingFunction = { (n: Float) -> Float in
        if n == 0 {
            return 0
        }
        if n == 1 {
            return 1
        }
        let p: Float = 0.4
        let s: Float = p / 4
        let a: Float = 1
        return a * pow(2, -10 * n) * sin((n - s) * (2 * .pi) / p) + 1
    }

    private static var _elasticInOut: ActionTimingFunction = { (n: Float) -> Float in
        if n == 0 {
            return 0
        }
        if n == 1 {
            return 1
        }
        let n = (n - 1) * 2
        let p: Float = 0.4
        let s: Float = p / 4
        let a: Float = 1
        if n < 1 {
            return -0.5 * (a * pow(2, 10 * n) * sin((n - s) * (2 * .pi) / p))
        }
        return a * pow(2, -10 * n) * sin((n - s) * (2 * .pi) / p) * 0.5 + 1
    }
}
