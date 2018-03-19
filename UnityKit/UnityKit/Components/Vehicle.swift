
import SceneKit

public typealias Wheel = SCNPhysicsVehicleWheel

public class Vehicle: Component {

    private(set) public var wheels = [Wheel]()
    private var vehicle: SCNPhysicsVehicle?

    @discardableResult public func set(wheelsNode: [String]) -> Vehicle {

        guard let gameObject = gameObject
            else { return self }

        wheels = [Wheel]()

        wheelsNode.forEach {

            guard let wheel = GameObject.find(.name(.exact($0)), in: gameObject)
                else { return }

            let physicsWheel = Wheel(node: wheel.node)
            physicsWheel.connectionPosition = wheel.transform.localPosition
            wheels.append(physicsWheel)
        }

        updateVehicule()

        return self
    }

    public override func onDestroy() {

        guard let scnScene = gameObject?.scene?.scnScene,
            let vehicle = vehicle
            else { return }

        scnScene.physicsWorld.removeBehavior(vehicle)
    }

    internal func updateVehicule() {

        guard let gameObject = gameObject,
            let physicsBody = gameObject.node.physicsBody,
            let scnScene = gameObject.scene?.scnScene else { return }

        if let vehicle = self.vehicle {
            scnScene.physicsWorld.removeBehavior(vehicle)
        }

        let vehicle = SCNPhysicsVehicle(chassisBody: physicsBody, wheels: wheels)
        scnScene.physicsWorld.addBehavior(vehicle)
        scnScene.physicsWorld.speed = 4.0

        self.vehicle = vehicle

        gameObject.createPhysicsBody()
    }

    public func applyEngineForce(_ value: Float, forWheelAt index: Int) {

        guard let vehicle = vehicle
            else { return }

        vehicle.applyEngineForce(value.toCGFloat(), forWheelAt: index)
    }

    public func setSteeringAngle(_ value: Float, forWheelAt index: Int) {

        guard let vehicle = vehicle
            else { return }

        vehicle.setSteeringAngle(value.toCGFloat(), forWheelAt: index)
    }

    public func applyBrakingForce(_ value: Float, forWheelAt index: Int) {

        guard let vehicle = vehicle
            else { return }

        vehicle.applyBrakingForce(value.toCGFloat(), forWheelAt: index)
    }
}
