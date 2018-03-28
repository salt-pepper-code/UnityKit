
import UnityKit

class TankHealth: MonoBehaviour {

    let startingHealth: Float = 100
    var currentHealth: Float = 0

    override func start() {

        currentHealth = startingHealth

        // Setup Tank Canvas
        let size: Float = 3.5
        let canvas = CanvasObject(worldSize: Size(size, size))
        canvas.transform.localEulerAngles = Vector3(90, 0, 0)

        let healthSlider = GameObject()
        let background = GameObject()
        let fillArea = GameObject()

        canvas.addChild(healthSlider)
        healthSlider.addChild(background)
        healthSlider.addChild(fillArea)

        background.addComponent(UI.Image.self)?
            .configure {
                $0.loadImage(fileName: "HealthWheel.png", type: .filled(canvas.pixelSize()), color: Color(hexString: "#FFFFFF", alpha: 0.31))
        }

        let fillImage = fillArea.addComponent(UI.Image.self)?
            .configure {
                $0.fillMethod = .radial360(.top)
                $0.clockwise = false
                $0.loadImage(fileName: "HealthWheel.png", type: .filled(canvas.pixelSize()), color: Color(hexString: "#FF0000", alpha: 0.31))
        }

        healthSlider.addComponent(UI.Slider.self)?
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
        gameObject?.getComponentInChild(UI.Slider.self)?.value = currentHealth
    }

    func onDeath() {

        // Destroy tank
        gameObject?.destroy()
    }
}
