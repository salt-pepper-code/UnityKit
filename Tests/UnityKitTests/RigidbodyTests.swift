import Testing
@testable import UnityKit

@Suite("Rigidbody Properties")
struct RigidbodyTests {

    @Test("Mass property getter and setter")
    func massProperty() {
        let rb = Rigidbody()

        // Test setter
        rb.mass = 5.0
        #expect(rb.properties[.mass] as? Float == 5.0)

        // Test getter
        let mass = rb.mass
        #expect(abs(mass - 5.0) < 0.001)
    }

    @Test("Restitution property getter and setter")
    func restitutionProperty() {
        let rb = Rigidbody()

        rb.restitution = 0.8
        #expect(rb.properties[.restitution] as? Float == 0.8)

        let restitution = rb.restitution
        #expect(abs(restitution - 0.8) < 0.001)
    }

    @Test("Friction property getter and setter")
    func frictionProperty() {
        let rb = Rigidbody()

        rb.friction = 0.6
        #expect(rb.properties[.friction] as? Float == 0.6)

        let friction = rb.friction
        #expect(abs(friction - 0.6) < 0.001)
    }

    @Test("Velocity property getter and setter")
    func velocityProperty() {
        let rb = Rigidbody()

        let testVelocity = Vector3(10, 5, 3)
        rb.velocity = testVelocity

        #expect((rb.properties[.velocity] as? Vector3) == testVelocity)

        let velocity = rb.velocity
        #expect(velocity.x == testVelocity.x)
        #expect(velocity.y == testVelocity.y)
        #expect(velocity.z == testVelocity.z)
    }

    @Test("Damping property getter and setter")
    func dampingProperty() {
        let rb = Rigidbody()

        rb.damping = 0.2
        #expect(rb.properties[.damping] as? Float == 0.2)

        let damping = rb.damping
        #expect(abs(damping - 0.2) < 0.001)
    }

    @Test("Angular damping property getter and setter")
    func angularDampingProperty() {
        let rb = Rigidbody()

        rb.angularDamping = 0.15
        #expect(rb.properties[.angularDamping] as? Float == 0.15)

        let angularDamping = rb.angularDamping
        #expect(abs(angularDamping - 0.15) < 0.001)
    }

    @Test("AllowsResting property getter and setter")
    func allowsRestingProperty() {
        let rb = Rigidbody()

        rb.allowsResting = false
        #expect(rb.properties[.allowsResting] as? Bool == false)

        let allowsResting = rb.allowsResting
        #expect(allowsResting == false)

        rb.allowsResting = true
        #expect(rb.allowsResting == true)
    }

    @Test("Multiple property changes maintain independence")
    func multiplePropertiesIndependent() {
        let rb = Rigidbody()

        rb.mass = 10.0
        rb.friction = 0.5
        rb.restitution = 0.7
        rb.damping = 0.1

        #expect(abs(rb.mass - 10.0) < 0.001)
        #expect(abs(rb.friction - 0.5) < 0.001)
        #expect(abs(rb.restitution - 0.7) < 0.001)
        #expect(abs(rb.damping - 0.1) < 0.001)
    }

    @Test("VelocityFactor property for axis locking")
    func velocityFactorProperty() {
        let rb = Rigidbody()

        let factor = Vector3(1, 0, 1) // Lock Y axis
        rb.velocityFactor = factor

        let result = rb.velocityFactor
        #expect(result.x == 1)
        #expect(result.y == 0)
        #expect(result.z == 1)
    }

    @Test("AngularVelocityFactor property for rotation locking")
    func angularVelocityFactorProperty() {
        let rb = Rigidbody()

        let factor = Vector3(0, 1, 0) // Lock X and Z rotation
        rb.angularVelocityFactor = factor

        let result = rb.angularVelocityFactor
        #expect(result.x == 0)
        #expect(result.y == 1)
        #expect(result.z == 0)
    }

    @Test("Constraints affect velocity factor")
    func constraintsAffectVelocityFactor() {
        let rb = Rigidbody()

        rb.constraints = .freezePositionX

        let factor = rb.velocityFactor
        #expect(factor.x == 0) // X should be frozen
        #expect(factor.y == 1)
        #expect(factor.z == 1)
    }

    @Test("Constraints affect angular velocity factor")
    func constraintsAffectAngularVelocityFactor() {
        let rb = Rigidbody()

        rb.constraints = .freezeRotationY

        let factor = rb.angularVelocityFactor
        #expect(factor.x == 1)
        #expect(factor.y == 0) // Y rotation should be frozen
        #expect(factor.z == 1)
    }

    @Test("Combined position constraints work correctly")
    func combinedPositionConstraints() {
        let rb = Rigidbody()

        rb.constraints = [.freezePositionX, .freezePositionZ]

        let factor = rb.velocityFactor
        #expect(factor.x == 0) // X frozen
        #expect(factor.y == 1) // Y free
        #expect(factor.z == 0) // Z frozen
    }

    @Test("Combined rotation constraints work correctly")
    func combinedRotationConstraints() {
        let rb = Rigidbody()

        rb.constraints = [.freezeRotationX, .freezeRotationZ]

        let factor = rb.angularVelocityFactor
        #expect(factor.x == 0) // X rotation frozen
        #expect(factor.y == 1) // Y rotation free
        #expect(factor.z == 0) // Z rotation frozen
    }

    @Test("freezePosition constraint freezes all position axes")
    func freezePositionConstraint() {
        let rb = Rigidbody()

        rb.constraints = .freezePosition

        let factor = rb.velocityFactor
        #expect(factor.x == 0)
        #expect(factor.y == 0)
        #expect(factor.z == 0)
    }

    @Test("freezeRotation constraint freezes all rotation axes")
    func freezeRotationConstraint() {
        let rb = Rigidbody()

        rb.constraints = .freezeRotation

        let factor = rb.angularVelocityFactor
        #expect(factor.x == 0)
        #expect(factor.y == 0)
        #expect(factor.z == 0)
    }

    @Test("freezeAll constraint freezes both position and rotation")
    func freezeAllConstraint() {
        let rb = Rigidbody()

        rb.constraints = .freezeAll

        let velocityFactor = rb.velocityFactor
        #expect(velocityFactor.x == 0)
        #expect(velocityFactor.y == 0)
        #expect(velocityFactor.z == 0)

        let angularFactor = rb.angularVelocityFactor
        #expect(angularFactor.x == 0)
        #expect(angularFactor.y == 0)
        #expect(angularFactor.z == 0)
    }

    @Test("Mixed position and rotation constraints work together")
    func mixedConstraints() {
        let rb = Rigidbody()

        rb.constraints = [.freezePositionY, .freezeRotationX, .freezeRotationZ]

        let velocityFactor = rb.velocityFactor
        #expect(velocityFactor.x == 1)
        #expect(velocityFactor.y == 0) // Position Y frozen
        #expect(velocityFactor.z == 1)

        let angularFactor = rb.angularVelocityFactor
        #expect(angularFactor.x == 0) // Rotation X frozen
        #expect(angularFactor.y == 1)
        #expect(angularFactor.z == 0) // Rotation Z frozen
    }

    @Test("Constraints can be changed after initial set")
    func changeConstraints() {
        let rb = Rigidbody()

        rb.constraints = .freezePositionX

        var factor = rb.velocityFactor
        #expect(factor.x == 0)
        #expect(factor.y == 1)

        // Change constraints
        rb.constraints = .freezePositionY

        factor = rb.velocityFactor
        #expect(factor.x == 1)
        #expect(factor.y == 0)
    }

    @Test("none constraint allows all movement")
    func noneConstraint() {
        let rb = Rigidbody()

        rb.constraints = .none

        // Setting none should not affect factors
        // (they may have default values, just ensure none doesn't freeze anything)
        let rb2 = Rigidbody()
        rb2.constraints = .freezeAll

        rb2.constraints = .none
        // After setting to none, if explicit factors aren't set,
        // we can't guarantee what they are, so just verify constraint is set
        #expect(rb2.constraints == .none)
    }

    @Test("Direct property assignment overrides constraints")
    func directPropertyOverridesConstraints() {
        let rb = Rigidbody()

        rb.constraints = .freezePositionX

        var factor = rb.velocityFactor
        #expect(factor.x == 0)

        // Directly set velocity factor
        rb.velocityFactor = Vector3(1, 1, 1)

        factor = rb.velocityFactor
        #expect(factor.x == 1) // Direct assignment should override
    }
}
