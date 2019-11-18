import UnityKit
import Foundation

enum PlayerType {
    case player(String)
    case ennemy(String)
}

struct TankProperty {
    let type: PlayerType
    let spawnPosition: Vector3
    let color: Color
}

class GameManager: MonoBehaviour {
    let startDelay: TimeInterval = 3
    let endDelay: TimeInterval = 3
    let numRoundsToWin: Int = 5
    var roundNumber: Int = 0

    var roundWinners = [String: Int]()
    var roundWinner: TankManager?
    var gameWinner: TankManager?

    var tanks = [TankManager]()
    let tankProperties = [TankProperty(type: .player("Player"), spawnPosition: Vector3(0, 1, 0), color: Color(hexString: "#7ECE40")),
                          TankProperty(type: .ennemy("Ennemy1"), spawnPosition: Vector3(-13, 1, -5), color: Color(hexString: "#E52E28")),
                          TankProperty(type: .ennemy("Ennemy2"), spawnPosition: Vector3(3, 1, 30), color: Color(hexString: "#2A64B2"))]

    override func start() {
        Camera.main()?.addComponent(CameraControl.self)
        startGame()
        gameObject?.scene?.printGameObjectsIgnoreUpdates()
    }

    private func startGame() {
        tankProperties.forEach {
            switch $0.type {
            case let .player(name), let .ennemy(name):
                roundWinners[name] = 0
            }
        }
        gameLoop()
    }

    private func spawnAllTanks() {
        tanks.forEach { $0.gameObject?.destroy() }
        tanks.removeAll()

        for property in tankProperties {
            guard let tank = loadTank(property)?.getComponent(TankManager.self)
                else { continue }

            tank.setup()
            tanks.append(tank)
        }
    }

    private func setCameraTarget() {
        guard let camera = Camera.main(),
            let tank = tanks.first?.gameObject
            else { return }

        camera.getComponent(CameraControl.self)?.set(target: tank)
    }

    private func gameLoop() {
        roundStarting()
        roundPlaying()
        roundEnding()
    }

    private func roundStarting() {
        queueCoroutine((execute: { [weak self] in
            self?.roundNumber += 1
            self?.spawnAllTanks()
            self?.setCameraTarget()
            self?.disableTankControl()

            let message = "ROUND \(self?.roundNumber ?? 0)"
            Debug.info(message)
            }, exitCondition: { [weak self] timePassed in
                guard let startDelay = self?.startDelay
                    else { return false }

                return timePassed >= startDelay
        }))
    }

    private func roundPlaying() {
        queueCoroutine((execute: { [weak self] in
            self?.enableTankControl()
            }, exitCondition: { [weak self] timePassed in
                let numTanksLeft = self?.tanks.filter {
                    guard let gameObject = $0.gameObject
                        else { return false }
                    return gameObject.activeSelf
                }.count ?? 0

                return numTanksLeft <= 1
        }))
    }

    private func roundEnding() {
        queueCoroutine((execute: { [weak self] in
            guard let tank = self?.tanks.filter({
                guard let gameObject = $0.gameObject
                    else { return false }
                return gameObject.activeSelf
            }).first,
                let name = tank.gameObject?.name,
                let count = self?.roundWinners[name]
                else { return }

            let wins = count + 1
            self?.roundWinners[name] = wins
            self?.roundWinner = tank

            if wins == self?.numRoundsToWin {
                self?.roundWinner = tank
            }

            let message = self?.endMessage() ?? ""
            Debug.info(message)

            self?.resetAllTanks()
            self?.disableTankControl()
            }, exitCondition: { [weak self] timePassed in
                guard let endDelay = self?.endDelay
                    else { return false }

                return timePassed >= endDelay
        }))

        queueCoroutine((execute: { [weak self] in
            if self?.gameWinner != nil {
                self?.startGame()
            } else {
                self?.gameLoop()
            }
            }, exitCondition: nil))
    }

    private func endMessage() -> String {
        // By default when a round ends there are no winners so the default end message is a draw.
        var message = "DRAW!"

        // If there is a winner then change the message to reflect that.
        if let roundWinner = roundWinner, let name = roundWinner.gameObject?.name {
            message = "\(name) WINS THE ROUND!\n"
        }

        // Go through all the tanks and add each of their scores to the message.
        tanks.forEach {
            if let name = $0.gameObject?.name, let wins = roundWinners[name] {
                message += "\(name): \(wins) WINS\n"
            }
        }

        // If there is a game winner, change the entire message to reflect that.
        if let gameWinner = gameWinner, let name = gameWinner.gameObject?.name {
            message =  "\(name) WINS THE GAME!"
        }

        return message
    }

    private func resetAllTanks() {
        spawnAllTanks()
        setCameraTarget()
    }

    private func enableTankControl() {
        tanks.forEach { $0.enableControl() }
    }

    private func disableTankControl() {
        tanks.forEach { $0.disableControl() }
    }

    // TANK Creation

    @discardableResult func loadTank(_ property: TankProperty) -> GameObject? {
        guard let scene = Scene.sharedInstance,
            let tank = GameObject(fileName: "Tank.scn", nodeName: "Tank")
            else { return nil }

        tank.layer = .player

        tank.addComponent(Rigidbody.self)
            .configure {
                $0.isStatic = false
                $0.isKinematic = false
                $0.constraints = [.freezeRotationX, .freezeRotationZ]
                $0.set(property: .allowsResting(false))
                $0.set(property: .mass(80))
                $0.set(property: .restitution(0.1))
                $0.set(property: .friction(0.5))
                $0.set(property: .rollingFriction(0))
            }

        tank.addComponent(MeshCollider.self)
            .set(mesh: tank.getComponent(MeshFilter.self)?.mesh)
            .configure {
                $0.collideWithLayer = [.all]
                $0.contactWithLayer = [.projectile]
            }

        switch property.type {
        case let .player(name):
            tank.name = name
            tank.addComponent(TankMovement.self)
            tank.addComponent(TankShooting.self)
        case let .ennemy(name):
            tank.name = name
        }

        tank.getComponent(Renderer.self)?.material?.setColor(.diffuse, color: property.color)

        tank.addComponent(TankManager.self)
        tank.addComponent(TankHealth.self)
        tank.addComponent(Vehicle.self)
            .set(wheels: createWheels(), physicsWorld: scene.scnScene.physicsWorld)

        tank.transform.position = property.spawnPosition

        scene.addGameObject(tank)

        return tank
    }

    func createWheels() -> [Wheel.Parameters] {
        let positionXZ: Float = 0.56
        let positionY: Float = 0.8

        let wheels: [Wheel.Parameters] =
            [ { var wheel = Wheel.Parameters(nodeName: "Wheel_Back_R")
                wheel.connectionPosition = Vector3(positionXZ, positionY, positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }(), { var wheel = Wheel.Parameters(nodeName: "Wheel_Back_L")
                wheel.connectionPosition = Vector3(-positionXZ, positionY, positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }(), { var wheel = Wheel.Parameters(nodeName: "Wheel_Front_R")
                wheel.connectionPosition = Vector3(positionXZ, positionY, -positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }(), { var wheel = Wheel.Parameters(nodeName: "Wheel_Front_L")
                wheel.connectionPosition = Vector3(-positionXZ, positionY, -positionXZ)
                wheel.axle = Vector3(1, 0, 0)
                return wheel }()]

        return wheels
    }
}
