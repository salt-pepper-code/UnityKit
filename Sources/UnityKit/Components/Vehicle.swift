import SceneKit

/// Represents a wheel attached to a vehicle.
///
/// `Wheel` encapsulates the configuration and reference for a single wheel on a vehicle.
/// It stores the wheel's parameters and provides access to the GameObject that represents
/// the wheel in the scene hierarchy.
///
/// ## Topics
///
/// ### Creating a Wheel
/// - ``init(gameObject:parameter:)``
///
/// ### Configuring Wheels
/// - ``Parameters``
///
/// ### Accessing Properties
/// - ``gameObject``
/// - ``parameters``
///
/// ## Example
///
/// ```swift
/// // Create wheel parameters
/// var frontLeft = Wheel.Parameters(nodeName: "FrontLeftWheel")
/// frontLeft.radius = 0.35
/// frontLeft.suspensionRestLength = 0.3
/// frontLeft.frictionSlip = 2.5
///
/// // The wheel is created automatically by the Vehicle component
/// ```
public class Wheel {
    /// Configuration parameters for a vehicle wheel.
    ///
    /// `Parameters` defines all the physical properties of a wheel including suspension,
    /// friction, steering, and connection points. These parameters are used to create
    /// an `SCNPhysicsVehicleWheel` when the vehicle is initialized.
    ///
    /// ## Topics
    ///
    /// ### Creating Parameters
    /// - ``init(nodeName:)``
    ///
    /// ### Physical Properties
    /// - ``suspensionStiffness``
    /// - ``suspensionCompression``
    /// - ``suspensionDamping``
    /// - ``maximumSuspensionTravel``
    /// - ``maximumSuspensionForce``
    /// - ``frictionSlip``
    ///
    /// ### Geometric Properties
    /// - ``radius``
    /// - ``suspensionRestLength``
    /// - ``connectionPosition``
    /// - ``steeringAxis``
    /// - ``axle``
    ///
    /// ### Identification
    /// - ``nodeName``
    public struct Parameters {
        /// The name of the GameObject representing this wheel in the scene hierarchy.
        ///
        /// This name is used to locate the wheel's GameObject when setting up the vehicle.
        public let nodeName: String

        /// The stiffness coefficient of the suspension spring.
        ///
        /// Higher values create stiffer suspension. Typical values range from 20.0 to 200.0.
        public var suspensionStiffness: Float?

        /// The damping coefficient applied when the suspension is compressed.
        ///
        /// Controls how quickly the suspension compresses. Typical values range from 1.0 to 4.0.
        public var suspensionCompression: Float?

        /// The damping coefficient applied when the suspension is expanding.
        ///
        /// Controls how quickly the suspension extends. Typical values range from 1.0 to 4.0.
        public var suspensionDamping: Float?

        /// The maximum distance the suspension can travel from its rest position.
        ///
        /// Limits how far the wheel can move up and down. Typical values range from 0.1 to 1.0.
        public var maximumSuspensionTravel: Float?

        /// The coefficient of friction between the tire and the ground.
        ///
        /// Higher values provide more grip. Typical values range from 0.8 to 3.0.
        public var frictionSlip: Float?

        /// The maximum force the suspension can apply.
        ///
        /// Limits the suspension force to prevent excessive bounce. Typical values range from 1000.0 to 10000.0.
        public var maximumSuspensionForce: Float?

        /// The position where the wheel connects to the chassis in local coordinates.
        ///
        /// Defines the attachment point of the suspension to the vehicle body.
        public var connectionPosition: Vector3?

        /// The axis around which the wheel steers.
        ///
        /// Typically the Y-axis (0, 1, 0) for vertical steering. Use (0, 0, 0) for non-steering wheels.
        public var steeringAxis: Vector3?

        /// The axis around which the wheel rotates for driving.
        ///
        /// Typically the X-axis (1, 0, 0) for standard wheel rotation.
        public var axle: Vector3?

        /// The radius of the wheel in meters.
        ///
        /// Defines the wheel size. Typical values range from 0.2 to 0.5 for cars.
        public var radius: Float?

        /// The rest length of the suspension in meters.
        ///
        /// The neutral position of the suspension spring. Typical values range from 0.2 to 0.5.
        public var suspensionRestLength: Float?

        /// Creates wheel parameters with the specified node name.
        ///
        /// - Parameter nodeName: The name of the GameObject representing this wheel.
        ///
        /// ## Example
        ///
        /// ```swift
        /// var wheel = Wheel.Parameters(nodeName: "FrontLeft")
        /// wheel.radius = 0.35
        /// wheel.suspensionRestLength = 0.3
        /// wheel.frictionSlip = 2.5
        /// ```
        public init(nodeName: String) {
            self.nodeName = nodeName
        }
    }

    /// The GameObject representing this wheel in the scene.
    ///
    /// This is the visual and physical representation of the wheel in the scene hierarchy.
    public let gameObject: GameObject

    /// The configuration parameters for this wheel.
    ///
    /// Contains all physical and geometric properties that define the wheel's behavior.
    public var parameters: Parameters

    /// Creates a wheel with the specified GameObject and parameters.
    ///
    /// - Parameters:
    ///   - gameObject: The GameObject representing the wheel.
    ///   - parameter: The configuration parameters for the wheel.
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

/// A component that simulates vehicle physics and controls.
///
/// `Vehicle` provides realistic vehicle physics simulation using SceneKit's physics engine.
/// It manages multiple wheels, applies forces for acceleration, steering, and braking, and
/// tracks vehicle speed. The component works by connecting wheel GameObjects to a chassis
/// physics body and simulating suspension, friction, and motor forces.
///
/// ## Topics
///
/// ### Configuring the Vehicle
/// - ``configure(_:)``
/// - ``set(wheels:physicsWorld:)``
///
/// ### Accessing Vehicle State
/// - ``wheels``
/// - ``speedInKilometersPerHour``
///
/// ### Controlling the Vehicle
/// - ``applyEngineForce(_:forWheelAt:)``
/// - ``applySteeringAngle(_:forWheelAt:)``
/// - ``applyBrakingForce(_:forWheelAt:)``
///
/// ### Component Lifecycle
/// - ``start()``
/// - ``onDestroy()``
///
/// ## Example
///
/// ```swift
/// // Create a car GameObject with a physics body
/// let car = GameObject(name: "Car")
/// car.node.physicsBody = SCNPhysicsBody.dynamic()
/// car.node.physicsBody?.mass = 1200  // kg
///
/// // Define wheel parameters
/// var frontLeft = Wheel.Parameters(nodeName: "FrontLeftWheel")
/// frontLeft.radius = 0.35
/// frontLeft.suspensionRestLength = 0.3
/// frontLeft.frictionSlip = 2.5
/// frontLeft.steeringAxis = Vector3(x: 0, y: 1, z: 0)
///
/// var frontRight = Wheel.Parameters(nodeName: "FrontRightWheel")
/// // ... configure other wheels
///
/// // Add vehicle component
/// car.addComponent(Vehicle.self)?
///     .set(wheels: [frontLeft, frontRight, rearLeft, rearRight],
///          physicsWorld: scene.physicsWorld)
///
/// // Control the vehicle
/// let vehicle = car.getComponent(Vehicle.self)
/// vehicle?.applyEngineForce(500, forWheelAt: nil)  // Accelerate all wheels
/// vehicle?.applySteeringAngle(30, forWheelAt: 0)   // Steer front wheels
/// vehicle?.applyBrakingForce(100, forWheelAt: nil) // Brake all wheels
///
/// // Check speed
/// print("Speed: \(vehicle?.speedInKilometersPerHour ?? 0) km/h")
/// ```
///
/// - Note: Wheel GameObjects must exist in the scene hierarchy before setting up the vehicle.
/// - Important: The chassis GameObject must have a dynamic physics body for vehicle simulation to work.
public class Vehicle: Component {
    override var order: ComponentOrder {
        return .vehicle
    }

    /// The wheels attached to this vehicle.
    ///
    /// Contains all configured wheels. This array is populated when calling ``set(wheels:physicsWorld:)``.
    public private(set) var wheels = [Wheel]()

    private var parameters: [Wheel.Parameters]?
    private var vehicle: SCNPhysicsVehicle?
    private var physicsWorld: SCNPhysicsWorld?

    /// The current speed of the vehicle in kilometers per hour.
    ///
    /// This property returns the vehicle's speed calculated by the physics engine.
    /// Returns `0.0` if the vehicle is not initialized.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Display speed in UI
    /// speedLabel.text = "\(vehicle.speedInKilometersPerHour) km/h"
    ///
    /// // Check if moving
    /// if vehicle.speedInKilometersPerHour > 0 {
    ///     print("Vehicle is moving")
    /// }
    /// ```
    public var speedInKilometersPerHour: Float {
        guard let vehicle
        else { return 0 }
        return vehicle.speedInKilometersPerHour.toFloat()
    }

    /// Configures the vehicle using a closure.
    ///
    /// Provides a convenient way to configure the vehicle in a single chained call.
    /// The closure receives the vehicle instance for configuration.
    ///
    /// - Parameter configurationBlock: A closure that receives and configures this vehicle.
    /// - Returns: This vehicle for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// vehicle.configure { v in
    ///     v.set(wheels: wheelParams, physicsWorld: scene.physicsWorld)
    /// }
    /// ```
    @discardableResult public func configure(_ configurationBlock: (Vehicle) -> Void) -> Vehicle {
        configurationBlock(self)
        return self
    }

    /// Sets up the vehicle with wheels and physics world.
    ///
    /// Configures the vehicle by finding wheel GameObjects by name, creating `Wheel` instances
    /// with the provided parameters, and connecting them to the chassis physics body. This method
    /// must be called with a valid physics world to initialize the vehicle simulation.
    ///
    /// - Parameters:
    ///   - parameters: An array of wheel parameters defining each wheel's properties and GameObject name.
    ///   - physicsWorld: The SceneKit physics world where the vehicle will be simulated.
    ///
    /// - Returns: This vehicle for method chaining.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Define all four wheels
    /// let wheelParams = [
    ///     Wheel.Parameters(nodeName: "FrontLeft"),
    ///     Wheel.Parameters(nodeName: "FrontRight"),
    ///     Wheel.Parameters(nodeName: "RearLeft"),
    ///     Wheel.Parameters(nodeName: "RearRight")
    /// ]
    ///
    /// vehicle.set(wheels: wheelParams, physicsWorld: scene.physicsWorld)
    /// ```
    ///
    /// - Note: Wheel GameObjects must already exist in the scene hierarchy.
    /// - Important: The chassis GameObject must have a physics body.
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

    /// Called when the component is destroyed.
    ///
    /// Removes the vehicle behavior from the physics world, cleaning up all vehicle physics simulation.
    override public func onDestroy() {
        guard let physicsWorld,
              let vehicle
        else { return }

        physicsWorld.removeBehavior(vehicle)
    }

    /// Called when the component starts.
    ///
    /// If wheel parameters were set before the component started, this method initializes
    /// the vehicle with those parameters.
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

    /// Applies engine force to accelerate the vehicle.
    ///
    /// Applies a driving force to the specified wheel or all wheels. Positive values accelerate
    /// the vehicle forward, negative values in reverse. The force is applied on the main queue.
    ///
    /// - Parameters:
    ///   - value: The engine force to apply. Typical values range from -1000 to 1000.
    ///   - index: The wheel index to apply force to, or `nil` to apply to all wheels.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Accelerate forward on all wheels
    /// vehicle.applyEngineForce(500)
    ///
    /// // Apply reverse
    /// vehicle.applyEngineForce(-300)
    ///
    /// // Apply force to rear wheels only
    /// vehicle.applyEngineForce(600, forWheelAt: 2)
    /// vehicle.applyEngineForce(600, forWheelAt: 3)
    /// ```
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

    /// Applies a steering angle to turn the vehicle.
    ///
    /// Sets the steering angle for the specified wheel or all wheels. The angle is typically
    /// applied to front wheels for standard vehicle steering. The angle is applied on the main queue.
    ///
    /// - Parameters:
    ///   - value: The steering angle in degrees. Positive values turn right, negative values turn left.
    ///   - index: The wheel index to apply steering to, or `nil` to apply to all wheels.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Turn left on front wheels
    /// vehicle.applySteeringAngle(-25, forWheelAt: 0)
    /// vehicle.applySteeringAngle(-25, forWheelAt: 1)
    ///
    /// // Turn right
    /// vehicle.applySteeringAngle(25, forWheelAt: 0)
    /// vehicle.applySteeringAngle(25, forWheelAt: 1)
    ///
    /// // Reset steering to straight
    /// vehicle.applySteeringAngle(0)
    /// ```
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

    /// Applies braking force to slow down the vehicle.
    ///
    /// Applies a braking force to the specified wheel or all wheels. Higher values provide
    /// stronger braking. The force is applied on the main queue.
    ///
    /// - Parameters:
    ///   - value: The braking force to apply. Typical values range from 0 to 500.
    ///   - index: The wheel index to apply braking to, or `nil` to apply to all wheels.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Apply full brakes
    /// vehicle.applyBrakingForce(500)
    ///
    /// // Apply light braking
    /// vehicle.applyBrakingForce(100)
    ///
    /// // Release brakes
    /// vehicle.applyBrakingForce(0)
    ///
    /// // Brake rear wheels only
    /// vehicle.applyBrakingForce(300, forWheelAt: 2)
    /// vehicle.applyBrakingForce(300, forWheelAt: 3)
    /// ```
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
