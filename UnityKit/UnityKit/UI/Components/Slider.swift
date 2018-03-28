
import SpriteKit

extension UI {

    public class Slider: UIBehaviour {

        public var fillImage: Image?
        public var minValue: Float = 0
        public var maxValue: Float = 1
        public var value: Float = 0 {
            didSet {
                value.clamp(minValue...maxValue)
                updateValue()
            }
        }

        @discardableResult public func configure(_ completionBlock: (Slider) -> ()) -> Slider {

            completionBlock(self)
            return self
        }

        private func updateValue() {
            fillImage?.fillAmount = ((value - minValue) / (maxValue - minValue))
        }
    }
}

