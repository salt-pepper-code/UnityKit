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

        /**
         Configurable block that passes and returns itself.
         - parameters:
            - configurationBlock: block that passes itself.

         - returns: itself
         */
        @discardableResult public func configure(_ configurationBlock: (Slider) -> Void) -> Slider {
            configurationBlock(self)
            return self
        }

        private func updateValue() {
            fillImage?.fillAmount = ((value - minValue) / (maxValue - minValue))
        }
    }
}
