import UnityKit
import UIKit

public typealias JoystickTuple = (angle: Float, displacement: Float)
public typealias JoystickUpdate = (JoystickTuple) -> Void
public typealias JoystickStart = () -> Void
public typealias JoystickCompletion = () -> Void

public final class Joystick: MonoBehaviour {
    let view: UIView

    public var onStart: JoystickStart?
    public var onUpdate: JoystickUpdate?
    public var onComplete: JoystickCompletion?

    public var baseAlpha: CGFloat {
        get {
            return baseImageView.alpha
        }
        set {
            baseImageView.alpha = newValue
        }
    }

    public var handleTintColor: UIColor = .blue {
        didSet { makeHandleImage() }
    }

    public private(set) var angle: Float = 0.0
    public private(set) var displacement: Float = 0.0

    private lazy var radius: Float = { return view.bounds.size.width.toFloat() / 2.0 }()

    private let baseImage = UIImage(named: "JoystickBase")!
    private let handleImage = UIImage(named: "JoystickHandle")!

    private let baseImageView: UIImageView
    private let handleImageView: UIImageView

    private var lastAngleRadians: Float = 0.0
    private var originalCenter: CGPoint?

    public required init() {
        self.view = UIView()
        self.baseImageView = UIImageView(image: baseImage)
        self.handleImageView = UIImageView(image: handleImage)
        super.init()
        initialize()
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        baseImageView.alpha = baseAlpha
        view.addSubview(baseImageView)
        baseImageView.frame = view.bounds
        baseImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        if !makeHandleImage() {
            fatalError("failed to create handle image")
        }

        view.addSubview(handleImageView)
        handleImageView.frame = view.bounds.insetBy(dx: 0.15 * view.bounds.width, dy: 0.15 * view.bounds.height)
        handleImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    @discardableResult private func makeHandleImage() -> Bool {
        guard let inputImage = CIImage(image: handleImage)
            else { return false }

        let filterConfig: [String: Any] = [kCIInputIntensityKey: 1.0,
                                           kCIInputColorKey: CIColor(color: handleTintColor),
                                           kCIInputImageKey: inputImage]

        guard let filter = CIFilter(name: "CIColorMonochrome", parameters: filterConfig),
            let outputImage = filter.outputImage
            else { return false }

        handleImageView.image = UIImage(ciImage: outputImage)
        return true
    }

    private var didStart = false

    public override func update() {
        guard let touch = Input.getTouch(0)
            else { return }

        guard let phase = touch.phase,
            touch.view == view else {
                if didStart {
                    onComplete?()
                    resetPosition()
                }
                return
        }

        switch phase {
        case .began:
            didStart = true
            onStart?()
            updatePosition(touch: touch)
        case .moved, .stationary:
            updatePosition(touch: touch)
        case .cancelled, .ended:
            didStart = false
            onComplete?()
            resetPosition()
        @unknown default:
            break
        }
    }

    private func resetPosition() {
        update(position: Vector2(view.frame.midX.toFloat(), view.frame.midY.toFloat()))
    }

    private func updatePosition(touch: Touch) {
        update(position: touch.position(in: view.superview))
    }

    private func update(position: Vector2) {
        let delta = position - CGPoint(x: view.frame.midX, y: view.frame.midY).toVector2()
        let newDisplacement = delta.length() / radius
        let newAngleRadians = atan2f(delta.x, delta.y)

        if newDisplacement > 1.0 {
            let x = CGFloat(sinf(newAngleRadians)) * radius.toCGFloat()
            let y = CGFloat(cosf(newAngleRadians)) * radius.toCGFloat()
            handleImageView.frame.origin = CGPoint(x: x + view.bounds.midX - handleImageView.bounds.size.width / 2.0,
                                                   y: y + view.bounds.midY - handleImageView.bounds.size.height / 2.0)
        } else {
            handleImageView.center = (CGPoint(x: view.bounds.midX, y: view.bounds.midY).toVector2() + delta).toCGPoint()
        }

        displacement = min(newDisplacement, 1.0)
        lastAngleRadians = newAngleRadians

        angle = displacement != 0.0 ? (180.0 - newAngleRadians * 180.0 / .pi) : 0.0

        if displacement != 0 {
            onUpdate?((angle, displacement))
        }
    }
}
