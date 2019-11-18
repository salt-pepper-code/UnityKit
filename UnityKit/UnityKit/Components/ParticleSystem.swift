import SceneKit

public class ParticleSystem: Component {
    public var scnParticleSystem: SCNParticleSystem?

    public required init() {
        super.init()
        self.ignoreUpdates = true
    }

    public override func onDestroy() {
        guard let particule = scnParticleSystem
            else { return }

        particule.reset()
        scnParticleSystem = nil
        gameObject?.node.removeParticleSystem(particule)
    }

    @discardableResult public func load(fileName: String, bundle: Bundle = Bundle.main, loops: Bool) -> ParticleSystem {
        guard let modelUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
            else { return self }

        var path = modelUrl.relativePath
            .replacingOccurrences(of: bundle.bundlePath, with: "")
            .replacingOccurrences(of: modelUrl.lastPathComponent, with: "")

        if path.first == "/" {
            path.removeFirst()
        }

        guard let particule = SCNParticleSystem(named: modelUrl.lastPathComponent, inDirectory: path)
            else { return self }

        particule.colliderNodes = []
        particule.loops = loops
        scnParticleSystem = particule
        gameObject?.node.addParticleSystem(particule)

        return self
    }

    @discardableResult public func execute(_ block: (SCNParticleSystem?) -> Void) -> ParticleSystem {
        block(scnParticleSystem)
        return self
    }

    @discardableResult public func executeAfter(milliseconds: Int, block: @escaping (SCNParticleSystem?) -> Void) -> ParticleSystem {
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(milliseconds)) { [weak scnParticleSystem] in
            block(scnParticleSystem)
        }
        return self
    }
}
