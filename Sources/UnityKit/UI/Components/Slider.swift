import SpriteKit

public extension UI {
    class Slider: UIBehaviour {
        public var fillImage: Image?
        public var minValue: Float = 0
        public var maxValue: Float = 1
        public var value: Float = 0 {
            didSet {
                self.value.clamp(self.minValue...self.maxValue)
                self.updateValue()
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
            self.fillImage?.fillAmount = ((self.value - self.minValue) / (self.maxValue - self.minValue))
        }
    }
}
