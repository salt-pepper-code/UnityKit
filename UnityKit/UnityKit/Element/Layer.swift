
extension GameObject {

    public struct Layer: OptionSet {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let `default` = Layer(rawValue: 1 << 0)
        public static let ignoreRayCast = Layer(rawValue: 1 << 1)
        public static let UI = Layer(rawValue: 1 << 2)

        public static let all: Layer = [.`default`, .ignoreRayCast, .UI]

        private(set) public static var layers = ["default": `default`, "ignoreRayCast": ignoreRayCast, "UI": UI]

        public static func layer(for name: String) -> Layer {

            guard let layer = layers[name]
                else { return `default` }

            return layer
        }

        public static func name(for layer: Layer) -> String {

            guard let index = layers.index(where: { (key, value) -> Bool in value == layer })
                else { return "" }

            return layers.keys[index]
        }

        public static func addLayer(with name: String) -> Layer {

            if let layer = layers[name] {
                return layer
            }

            let rawValue = 1 << layers.count
            let layer = Layer(rawValue: rawValue)
            layers[name] = layer

            return layer
        }

        public func isPart(of bitMaskRawValue: Int) -> Bool {
            return Layer(rawValue: bitMaskRawValue).contains(self)
        }
    }
}
