import Foundation

public enum Ease {
    case linear
    case backOut
    case backIn
    case backInOut
    case bounceOut
    case bounceIn
    case bounceInOut
    case circleOut
    case circleIn
    case circleInOut
    case cubicOut
    case cubicIn
    case cubicInOut
    case elasticOut
    case elasticIn
    case elasticInOut
    case expoOut
    case expoIn
    case expoInOut
    case quadOut
    case quadIn
    case quadInOut
    case quartOut
    case quartIn
    case quartInOut
    case quintOut
    case quintIn
    case quintInOut
    case sineOut
    case sineIn
    case sineInOut
    case custom(ActionTimingFunction)

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
