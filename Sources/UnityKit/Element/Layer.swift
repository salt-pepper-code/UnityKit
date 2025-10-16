public extension GameObject {
    struct Layer: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let `default` = Layer(rawValue: 1 << 0)
        public static let ground = Layer(rawValue: 1 << 1)
        public static let player = Layer(rawValue: 1 << 2)
        public static let environment = Layer(rawValue: 1 << 3)
        public static let projectile = Layer(rawValue: 1 << 4)

        public static var all: Layer {
            return layers.values.reduce(Layer(rawValue: 0)) { prev, layer in
                [prev, layer]
            }
        }

        public private(set) static var layers = [
            "default": `default`,
            "ground": ground,
            "player": player,
            "environment": environment,
            "projectile": projectile,
        ]

        public static func layer(for name: String) -> Layer {
            return self.layers[name] ?? self.default
        }

        public static func name(for layer: Layer) -> String {
            guard let index = layers.firstIndex(where: { _, value -> Bool in value == layer }) else { return "" }
            return self.layers.keys[index]
        }

        @discardableResult static func addLayer(with name: String) -> Layer {
            if let layer = layers[name] {
                return layer
            }

            let rawValue = 1 << self.layers.count
            let layer = Layer(rawValue: rawValue)
            self.layers[name] = layer

            return layer
        }

        public func isPart(of bitMaskRawValue: Int) -> Bool {
            return Layer(rawValue: bitMaskRawValue).contains(self)
        }
    }
}
