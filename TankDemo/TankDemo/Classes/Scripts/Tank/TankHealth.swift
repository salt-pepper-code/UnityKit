import UnityKit
import Foundation

class TankHealth: MonoBehaviour {
    let startingHealth: Float = 100
    var currentHealth: Float = 0
    let fullHealthColor = Color.green
    let zeroHealthColor = Color.red
    var fillImage: UI.Image?
    var slider: UI.Slider?

    override func onEnable() {
        currentHealth = startingHealth
        setHealthUI()
    }

    override func start() {
        // Setup Canvas
        let size: Float = 4
        // CanvasObject
        let canvas = CanvasObject(worldSize: Size(size, size))
        // Childs
        let healthSlider = GameObject()
        let background = GameObject()
        let fillArea = GameObject()

        canvas.transform.localEulerAngles = Vector3(90, 0, 0)

        canvas.addChild(healthSlider)
        healthSlider.addChild(background)
        healthSlider.addChild(fillArea)

        // Setup Image components
        background.addComponent(UI.Image.self)
            .configure {
                $0.loadImage(fileName: "HealthWheel.png", type: .filled(canvas.pixelSize()), color: Color(hexString: "#FFFFFF", alpha: 0.31))
            }

        fillImage = fillArea.addComponent(UI.Image.self)
            .configure {
                $0.fillMethod = .radial360(.top)
                $0.clockwise = false
                $0.loadImage(fileName: "HealthWheel.png", type: .filled(canvas.pixelSize()), color: fullHealthColor)
            }

        // Setup Slider component that will control how to fill the image
        slider = healthSlider.addComponent(UI.Slider.self)
            .configure {
                $0.fillImage = fillImage
                $0.minValue = 0
                $0.maxValue = startingHealth
                $0.value = currentHealth
            }

        gameObject?.addChild(canvas)
    }

    public func takeDamage(_ amount: Float) {
        // Reduce current health by the amount of damage done.
        currentHealth -= amount

        // Change the UI elements appropriately.
        setHealthUI()

        // If the current health is at or below zero and it has not yet been registered, call OnDeath.
        if currentHealth <= 0 {
            onDeath()
        }
    }

    func setHealthUI() {
        slider?.value = currentHealth
        fillImage?.color = Color.lerp(from: zeroHealthColor, to: fullHealthColor, time: (currentHealth / startingHealth).toDouble())
    }

    func onDeath() {
        gameObject?.setActive(false)
    }
}
