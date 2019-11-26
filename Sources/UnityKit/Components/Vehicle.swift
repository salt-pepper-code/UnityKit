import SceneKit

/**
Wheel component.
*/
public class Wheel {
    public struct Parameters {
        public let nodeName: String
        public var suspensionStiffness: Float?
        public var suspensionCompression: Float?
        public var suspensionDamping: Float?
        public var maximumSuspensionTravel: Float?
        public var frictionSlip: Float?
        public var maximumSuspensionForce: Float?
        public var connectionPosition: Vector3?
        public var steeringAxis: Vector3?
        public var axle: Vector3?
        public var radius: Float?
        public var suspensionRestLength: Float?

        public init(nodeName: String) {
            self.nodeName = nodeName
        }
    }

    public let gameObject: GameObject
    public var parameters: Parameters

    public init(gameObject: GameObject, parameter: Parameters) {
        self.gameObject = gameObject
        self.parameters = parameter
    }

    fileprivate func scnWheel() -> SCNPhysicsVehicleWheel {
        let wheel = SCNPhysicsVehicleWheel(node: gameObject.node)
        parameters.suspensionStiffness.map { wheel.suspensionStiffness = $0.toCGFloat() }
        parameters.suspensionCompression.map { wheel.suspensionCompression = $0.toCGFloat() }
        parameters.suspensionDamping.map { wheel.suspensionDamping = $0.toCGFloat() }
        parameters.maximumSuspensionTravel.map { wheel.maximumSuspensionTravel = $0.toCGFloat() }
        parameters.frictionSlip.map { wheel.frictionSlip = $0.toCGFloat() }
        parameters.maximumSuspensionForce.map { wheel.maximumSuspensionForce = $0.toCGFloat() }
        parameters.connectionPosition.map { wheel.connectionPosition = $0 }
        parameters.steeringAxis.map { wheel.steeringAxis = $0 }
        parameters.axle.map { wheel.axle = $0 }
        parameters.radius.map { wheel.radius = $0.toCGFloat() }
        parameters.suspensionRestLength.map { wheel.suspensionRestLength = $0.toCGFloat() }
        return wheel
    }
}

/**
The Vehicles module implements vehicle physics simulation through the Wheel component.
*/
public class Vehicle: Component {
    override internal var order: ComponentOrder {
        return .vehicle
    }
    private(set) public var wheels = [Wheel]()
    private var parameters: [Wheel.Parameters]?
    private var vehicle: SCNPhysicsVehicle?
    private var physicsWorld: SCNPhysicsWorld?
    public var speedInKilometersPerHour: Float {
        guard let vehicle = vehicle
            else { return 0 }
        return vehicle.speedInKilometersPerHour.toFloat()
    }

    /**
     Configurable block that passes and returns itself.

     - parameters:
        - configurationBlock: block that passes itself.

     - returns: itself
     */
    @discardableResult public func configure(_ configurationBlock: (Vehicle) -> Void) -> Vehicle {
        configurationBlock(self)
        return self
    }

    @discardableResult public func set(wheels parameters: [Wheel.Parameters], physicsWorld: SCNPhysicsWorld) -> Vehicle {
        self.physicsWorld = physicsWorld
        self.parameters = parameters

        guard let gameObject = gameObject,
            let physicsBody = gameObject.node.physicsBody
            else { return self }

        wheels = parameters.compactMap { parameter -> Wheel? in
            guard let wheel = GameObject.find(.name(.exact(parameter.nodeName)), in: gameObject)
                else { return nil }

            return Wheel(gameObject: wheel, parameter: parameter)
        }

        let vehicle = SCNPhysicsVehicle(chassisBody: physicsBody, wheels: wheels.map { wheel -> SCNPhysicsVehicleWheel in return wheel.scnWheel() })
        physicsWorld.addBehavior(vehicle)

        self.vehicle = vehicle

        return self
    }

    public override func onDestroy() {
        guard let physicsWorld = physicsWorld,
            let vehicle = vehicle
            else { return }

        physicsWorld.removeBehavior(vehicle)
    }

    public override func start() {
        if let physicsWorld = physicsWorld,
            let parameters = parameters,
            vehicle == nil {
            set(wheels: parameters, physicsWorld: physicsWorld)
        }
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

        DispatchQueue.main.async { [weak vehicle] () -> Void in
            for i in stride {
                vehicle?.applyEngineForce(value.toCGFloat(), forWheelAt: i)
            }
        }
    }

    public func applySteeringAngle(_ value: Degree, forWheelAt index: Int? = nil) {
        guard let vehicle = vehicle,
            let stride = wheelStride(vehicle, forWheelAt: index)
            else { return }

        DispatchQueue.main.async { [weak vehicle] () -> Void in
            for i in stride {
                vehicle?.setSteeringAngle(value.toCGFloat(), forWheelAt: i)
            }
        }
    }

    public func applyBrakingForce(_ value: Float, forWheelAt index: Int? = nil) {
        guard let vehicle = vehicle,
            let stride = wheelStride(vehicle, forWheelAt: index)
            else { return }

        DispatchQueue.main.async { [weak vehicle] () -> Void in
            for i in stride {
                vehicle?.applyBrakingForce(value.toCGFloat(), forWheelAt: i)
            }
        }
    }
}
