
import SceneKit

public class ParticleSystem: Component {

    public var scnParticleSystem: SCNParticleSystem?

    public override func onDestroy() {

        guard let particule = scnParticleSystem
            else { return }

        gameObject?.node.removeParticleSystem(particule)
    }

    @discardableResult public func load(fileName: String, bundle: Bundle = Bundle.main) -> ParticleSystem? {

        guard let modelUrl = searchPathForResource(for: fileName, extension: nil, bundle: bundle)
            else { return nil }

        var path = modelUrl.relativePath
            .replacingOccurrences(of: bundle.bundlePath, with: "")
            .replacingOccurrences(of: modelUrl.lastPathComponent, with: "")

        if path.first == "/" {
            path.removeFirst()
        }

        guard let particule = SCNParticleSystem(named: modelUrl.lastPathComponent, inDirectory: path)
            else { return nil }

        particule.colliderNodes = []
        scnParticleSystem = particule
        gameObject?.node.addParticleSystem(particule)

        return self
    }

    @discardableResult public func execute(_ block: (SCNParticleSystem?) -> ()) -> ParticleSystem {

        block(scnParticleSystem)
        return self
    }

    @discardableResult public func executeAfter(milliseconds: Int, block: ((SCNParticleSystem?) -> ())? = nil) -> ParticleSystem {

        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(milliseconds)) { [weak self] in
            block?(self?.scnParticleSystem)
        }
        return self
    }
}
