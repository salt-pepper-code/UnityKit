extension GameObject {
    public struct Layer: OptionSet {
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
            return layers.values.dropFirst().reduce(`default`) { prev, layer -> Layer in
                [prev, layer]
            }
        }

        private(set) public static var layers = ["default": `default`, "ground": ground, "player": player, "environment": environment, "projectile": projectile]

        public static func layer(for name: String) -> Layer {
            return layers[name] ?? `default`
        }

        public static func name(for layer: Layer) -> String {
            guard let index = layers.firstIndex(where: { _, value -> Bool in value == layer }) else { return "" }
            return layers.keys[index]
        }

        @discardableResult internal static func addLayer(with name: String) -> Layer {
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
