
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

            if $0.hasSuffix("_L") || $0.hasSuffix("_R") {

                let boundingBox = wheel.node.boundingBox
                let size = Volume.boundingSize(boundingBox)

                if $0.hasSuffix("_R") {
                    physicsWheel.connectionPosition = wheel.node.convertPosition(.zero, to: gameObject.node) + Vector3(size.x * 0.5, 0, 0)
                    physicsWheel.axle = Vector3(1, 0, 0)
                } else {
                    physicsWheel.connectionPosition = wheel.node.convertPosition(.zero, to: gameObject.node) - Vector3(size.x * 0.5, 0, 0)
                    physicsWheel.axle = Vector3(1, 0, 0)
                }
            }
            wheels.append(physicsWheel)
        }

        let vehicle = SCNPhysicsVehicle(chassisBody: physicsBody, wheels: wheels)
        physicsWorld.addBehavior(vehicle)

        self.vehicle = vehicle
    }

    public override func fixedUpdate() {

        guard let vehicle = vehicle
            else { return }

        //print(vehicle.speedInKilometersPerHour)
    }

    private func wheelStride(_ vehicle: SCNPhysicsVehicle, forWheelAt index: Int?) -> StrideThrough<Int>? {

        guard vehicle.wheels.count > 0
            else { return nil }

        if let index = index {
            return stride(from: index, through: index, by: 1)
        }

        return stride(from: 0, through: vehicle.wheels.count - 1, by: 1)
    }

    public func applyEngineForce(_ value: Float, forWheelAt index: Int? = nil) {

        guard let vehicle = vehicle,
            let stride = wheelStride(vehicle, forWheelAt: index)
            else { return }

        for i in stride {
            vehicle.applyEngineForce(value.toCGFloat(), forWheelAt: i)
        }
    }

    public func setSteeringAngle(_ value: Float, forWheelAt index: Int? = nil) {

        guard let vehicle = vehicle,
            let stride = wheelStride(vehicle, forWheelAt: index)
            else { return }

        for i in stride {
            vehicle.setSteeringAngle(value.toCGFloat(), forWheelAt: i)
        }
    }

    public func applyBrakingForce(_ value: Float, forWheelAt index: Int? = nil) {

        guard let vehicle = vehicle,
            let stride = wheelStride(vehicle, forWheelAt: index)
            else { return }

        for i in stride {
            vehicle.applyBrakingForce(value.toCGFloat(), forWheelAt: i)
        }
    }
}
