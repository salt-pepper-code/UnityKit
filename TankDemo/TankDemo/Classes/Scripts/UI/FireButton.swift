import UIKit
import UnityKit

public typealias FireButtonTrigger = () -> Void

class FireButton: MonoBehaviour {
    let view: UIView
    private let baseImage = UIImage(named: "JoystickBase")!
    private let baseImageView: UIImageView

    public var onTrigger: FireButtonTrigger?

    public var baseAlpha: CGFloat {
        get {
            return baseImageView.alpha
        }
        set {
            baseImageView.alpha = newValue
        }
    }

    public required init() {
        self.view = UIView()
        self.baseImageView = UIImageView(image: baseImage)
        super.init()
        initialize()
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        baseImageView.alpha = baseAlpha
        baseImageView.frame = view.bounds
        baseImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(baseImageView)
    }

    public override func update() {
        guard let touch = Input.getTouch(0),
            let phase = touch.phase,
            touch.view == view
            else { return }

        switch phase {
        case .ended:
            onTrigger?()
        default:
            break
        }
    }
}
