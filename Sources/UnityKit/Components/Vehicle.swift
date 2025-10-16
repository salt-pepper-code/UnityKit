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
        self.parameters.suspensionStiffness.map { wheel.suspensionStiffness = $0.toCGFloat() }
        self.parameters.suspensionCompression.map { wheel.suspensionCompression = $0.toCGFloat() }
        self.parameters.suspensionDamping.map { wheel.suspensionDamping = $0.toCGFloat() }
        self.parameters.maximumSuspensionTravel.map { wheel.maximumSuspensionTravel = $0.toCGFloat() }
        self.parameters.frictionSlip.map { wheel.frictionSlip = $0.toCGFloat() }
        self.parameters.maximumSuspensionForce.map { wheel.maximumSuspensionForce = $0.toCGFloat() }
        self.parameters.connectionPosition.map { wheel.connectionPosition = $0 }
        self.parameters.steeringAxis.map { wheel.steeringAxis = $0 }
        self.parameters.axle.map { wheel.axle = $0 }
        self.parameters.radius.map { wheel.radius = $0.toCGFloat() }
        self.parameters.suspensionRestLength.map { wheel.suspensionRestLength = $0.toCGFloat() }
        return wheel
    }
}

/**
 The Vehicles module implements vehicle physics simulation through the Wheel component.
 */
public class Vehicle: Component {
    override var order: ComponentOrder {
        return .vehicle
    }

    public private(set) var wheels = [Wheel]()
    private var parameters: [Wheel.Parameters]?
    private var vehicle: SCNPhysicsVehicle?
    private var physicsWorld: SCNPhysicsWorld?
    public var speedInKilometersPerHour: Float {
        guard let vehicle
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

    @discardableResult public func set(
        wheels parameters: [Wheel.Parameters],
        physicsWorld: SCNPhysicsWorld
    ) -> Vehicle {
        self.physicsWorld = physicsWorld
        self.parameters = parameters

        guard let gameObject,
              let physicsBody = gameObject.node.physicsBody
        else { return self }

        self.wheels = parameters.compactMap { parameter -> Wheel? in
            guard let wheel = GameObject.find(.name(.exact(parameter.nodeName)), in: gameObject)
            else { return nil }

            return Wheel(gameObject: wheel, parameter: parameter)
        }

        let vehicle = SCNPhysicsVehicle(
            chassisBody: physicsBody,
            wheels: wheels.map { wheel -> SCNPhysicsVehicleWheel in return wheel.scnWheel() }
        )
        physicsWorld.addBehavior(vehicle)

        self.vehicle = vehicle

        return self
    }

    override public func onDestroy() {
        guard let physicsWorld,
              let vehicle
        else { return }

        physicsWorld.removeBehavior(vehicle)
    }

    override public func start() {
        if let physicsWorld,
           let parameters,
           vehicle == nil
        {
            self.set(wheels: parameters, physicsWorld: physicsWorld)
        }
    }

    private func wheelStride(_ vehicle: SCNPhysicsVehicle, forWheelAt index: Int?) -> StrideThrough<Int>? {
        guard vehicle.wheels.count > 0
        else { return nil }

        if let index {
            return stride(from: index, through: index, by: 1)
        }

        return stride(from: 0, through: vehicle.wheels.count - 1, by: 1)
    }

    public func applyEngineForce(_ value: Float, forWheelAt index: Int? = nil) {
        guard let vehicle,
              let stride = wheelStride(vehicle, forWheelAt: index)
        else { return }

        DispatchQueue.main.async { [weak vehicle] () in
            for i in stride {
                vehicle?.applyEngineForce(value.toCGFloat(), forWheelAt: i)
            }
        }
    }

    public func applySteeringAngle(_ value: Degree, forWheelAt index: Int? = nil) {
        guard let vehicle,
              let stride = wheelStride(vehicle, forWheelAt: index)
        else { return }

        DispatchQueue.main.async { [weak vehicle] () in
            for i in stride {
                vehicle?.setSteeringAngle(value.toCGFloat(), forWheelAt: i)
            }
        }
    }

    public func applyBrakingForce(_ value: Float, forWheelAt index: Int? = nil) {
        guard let vehicle,
              let stride = wheelStride(vehicle, forWheelAt: index)
        else { return }

        DispatchQueue.main.async { [weak vehicle] () in
            for i in stride {
                vehicle?.applyBrakingForce(value.toCGFloat(), forWheelAt: i)
            }
        }
    }
}
