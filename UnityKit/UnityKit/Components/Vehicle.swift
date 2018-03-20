
import SceneKit

public typealias Wheel = SCNPhysicsVehicleWheel

public class Vehicle: Component {

    private(set) public var wheelNames = [String]()
    private var vehicle: SCNPhysicsVehicle?
    private var physicsWorld: SCNPhysicsWorld?

    @discardableResult public func set(wheelNames: [String], physicsWorld: SCNPhysicsWorld) -> Vehicle {

        self.physicsWorld = physicsWorld
        self.wheelNames = wheelNames

        updateVehicule()

        return self
    }

    public override func onDestroy() {

        guard let physicsWorld = physicsWorld,
            let vehicle = vehicle
            else { return }

        physicsWorld.removeBehavior(vehicle)
    }

    internal func updateVehicule() {

        guard let gameObject = gameObject,
            let physicsBody = gameObject.node.physicsBody,
            let physicsWorld = physicsWorld
            else { return }

        if let vehicle = self.vehicle {
            physicsWorld.removeBehavior(vehicle)
        }

        var wheels = [Wheel]()

        wheelNames.forEach {

            guard let wheel = GameObject.find(.name(.exact($0)), in: gameObject)
                else { return }

            let physicsWheel = Wheel(node: wheel.node)

            let boundingBox = wheel.node.boundingBox
            let size = Volume.boundingSize(boundingBox)
            physicsWheel.connectionPosition = wheel.node.convertPosition(.zero, to: gameObject.node) + Vector3(size.x * 0.5, 0, 0)
            wheels.append(physicsWheel)
        }

        let vehicle = SCNPhysicsVehicle(chassisBody: physicsBody, wheels: wheels)
        physicsWorld.addBehavior(vehicle)
        physicsWorld.speed = 4.0

        self.vehicle = vehicle
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
